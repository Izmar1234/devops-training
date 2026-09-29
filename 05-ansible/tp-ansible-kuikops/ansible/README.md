# TP Ansible — Déploiement d’une infrastructure AWS avec GLPI et Jenkins

## 1. Objectif du TP

L’objectif de ce TP est de construire une infrastructure AWS avec Terraform, puis de configurer automatiquement les serveurs avec Ansible.

Le projet permet de mettre en place :

- Deux serveurs Front Apache
- Un serveur applicatif GLPI
- Un serveur MariaDB privé pour GLPI
- Un serveur Jenkins installé sur `front-01`
- Des utilisateurs SSH avec leurs clés publiques
- Des volumes EBS séparés pour les fichiers web et les logs Apache
- Une rotation automatique des logs avec Logrotate
- Une gestion sécurisée des mots de passe avec Ansible Vault
- Un réseau AWS séparé en subnet public et subnet privé

L’Application Load Balancer ne fait pas partie de cette réalisation.

---

## 2. Architecture générale
L’infrastructure est déployée dans la région AWS de Paris (`eu-west-3`).

Le schéma suivant présente les composants, les flux réseau, les règles de
sécurité et les emplacements des logs :

![Architecture technique GLPI sur AWS](docs/archi.png)

L’infrastructure est déployée dans la région AWS de Paris :

```text
Région : eu-west-3
VPC    : 10.0.0.0/16
```

### Subnet public

```text
CIDR : 10.0.20.0/24
```

Il contient :

- `front-01`
- `front-02`
- `glpi-app`

Ces machines possèdent une adresse IP publique temporaire.

### Subnet privé

```text
CIDR : 10.0.21.0/24
```

Il contient :

- `glpi-db`

Le serveur MariaDB ne possède aucune adresse IP publique.

Il accède à Internet uniquement en sortie, à travers le NAT Gateway, pour installer les paquets et effectuer les mises à jour.

---

## 3. Ressources AWS existantes utilisées

Le TP réutilise les ressources AWS suivantes :

| Ressource | Nom | Identifiant |
|---|---|---|
| VPC | `techmind_vpc` | `vpc-02855c98755e6b058` |
| Internet Gateway | `tech_mind_igw` | `igw-0fed3cfd38607d94b` |
| NAT Gateway | `tech_mind_general_use` | `nat-1522f5fbe634d3413` |
| Région | Paris | `eu-west-3` |
| Profil AWS SSO | `tech-mind` | — |

Ces ressources sont récupérées par des blocs Terraform `data`. Elles ne sont pas recréées par le projet.

---

## 4. Machines EC2

| Machine | Rôle | Subnet | Adresse privée | Adresse publique |
|---|---|---|---|---|
| `front-01` | Apache et Jenkins | Public | `10.0.20.6` | Dynamique |
| `front-02` | Apache | Public | `10.0.20.57` | Dynamique |
| `glpi-app` | Apache, PHP et GLPI | Public | `10.0.20.164` | Dynamique |
| `glpi-db` | MariaDB | Privé | `10.0.21.140` | Aucune |

> Les adresses publiques changent lorsque les instances sont arrêtées puis redémarrées, car aucune Elastic IP n’est utilisée.

Pour récupérer les adresses actuelles :

```bash
aws ec2 describe-instances \
  --profile tech-mind \
  --region eu-west-3 \
  --filters \
    "Name=tag:Name,Values=tech-mind-izmar-abderrahim-tp-ansible-*" \
    "Name=instance-state-name,Values=running" \
  --query 'Reservations[].Instances[].{
    Name:Tags[?Key==`Name`]|[0].Value,
    InstanceId:InstanceId,
    PrivateIP:PrivateIpAddress,
    PublicIP:PublicIpAddress,
    State:State.Name
  }' \
  --output table
```

---

## 5. Organisation du projet

```text
tp-ansible-kuikops/
├── .gitignore
├── README.md
├── terraform/
│   ├── compute.tf
│   ├── data.tf
│   ├── environments/
│   │   └── dev.tfvars
│   ├── locals.tf
│   ├── network.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── security_groups.tf
│   ├── storage.tf
│   ├── variables.tf
│   └── versions.tf
└── ansible/
    ├── ansible.cfg
    ├── group_vars/
    │   └── all/
    │       ├── main.yml
    │       └── vault.yml
    ├── host_vars/
    ├── inventory/
    │   └── hosts.yml
    ├── roles/
    │   ├── apache/
    │   ├── filesystems/
    │   ├── glpi/
    │   ├── jenkins/
    │   ├── logrotate/
    │   ├── mariadb/
    │   └── ssh_keys/
    └── site.yml
```

---

# Partie Terraform

## 6. Rôle de Terraform

Terraform prépare l’infrastructure AWS :

- Les subnets public et privé
- Les tables de routage
- La route Internet du subnet public
- La route NAT du subnet privé
- Les Security Groups
- La clé publique SSH
- Les quatre instances EC2
- Les quatre volumes EBS
- Les attachements des volumes aux serveurs Front

Terraform ne configure pas les applications dans les machines. Cette partie est gérée par Ansible.

---

## 7. Préparation de la session AWS SSO

Les variables suivantes doivent être exportées dans le terminal :

```bash
export AWS_PROFILE="tech-mind"
export AWS_REGION="eu-west-3"
export AWS_DEFAULT_REGION="eu-west-3"
export AWS_SDK_LOAD_CONFIG="1"
```

Si la session SSO est expirée :

```bash
aws sso login --profile tech-mind
```

Vérification de l’identité AWS :

```bash
aws sts get-caller-identity --profile tech-mind
```

---

## 8. Initialisation et validation de Terraform

Se placer dans le répertoire Terraform :

```bash
cd terraform
```

Initialiser Terraform :

```bash
terraform init
```

Formater les fichiers :

```bash
terraform fmt -recursive
```

Vérifier la configuration :

```bash
terraform validate
```

Créer un plan :

```bash
terraform plan \
  -var-file=environments/dev.tfvars \
  -out=tfplan
```

Il faut lire le résumé avant de continuer :

```text
Plan: X to add, Y to change, Z to destroy
```

En particulier, vérifier qu’aucune destruction inattendue n’est proposée.

Appliquer exactement le plan sauvegardé :

```bash
terraform apply tfplan
```

> Le plan et l’application doivent utiliser la même version de Terraform. Un fichier `tfplan` créé avec une version différente ne peut pas être appliqué.

En cas de changement de version, recréer le plan :

```bash
terraform plan \
  -var-file=environments/dev.tfvars \
  -out=tfplan

terraform apply tfplan
```

---

## 9. Routage réseau

### Subnet public

La table de routage publique contient :

```text
0.0.0.0/0 → Internet Gateway
```

Cela permet aux machines publiques de communiquer directement avec Internet.

### Subnet privé

La table de routage privée contient :

```text
0.0.0.0/0 → NAT Gateway
```

Le NAT autorise une machine privée à démarrer une connexion vers Internet.

Il n’autorise pas Internet à démarrer une connexion vers `glpi-db`.

---

## 10. Security Groups

### Security Group des Fronts

Il autorise notamment :

- SSH sur le port `22` depuis l’adresse IP d’administration
- HTTP sur le port `80`

### Security Group de GLPI

Il autorise :

- HTTP sur le port `80`
- SSH sur le port `22` depuis l’adresse autorisée

### Security Group de MariaDB

Il autorise uniquement :

- MariaDB sur le port `3306` depuis le Security Group de `glpi-app`
- SSH sur le port `22` depuis le Security Group des Fronts

MariaDB n’est donc pas accessible directement depuis Internet.

### Security Group de Jenkins

Il autorise :

- Jenkins sur le port `8080` uniquement depuis l’adresse publique de l’administrateur

Récupération de l’adresse publique actuelle :

```bash
curl -4 --silent https://checkip.amazonaws.com
```

Si cette adresse change, la variable Terraform correspondante doit être mise à jour, puis un nouveau plan doit être appliqué.

---

## 11. Volumes EBS

Chaque serveur Front possède deux volumes EBS chiffrés :

| Volume | Point de montage | Utilisation |
|---|---|---|
| Web | `/var/www` | Contenu des sites Apache |
| Logs | `/var/log/apache2` | Logs Apache |

Les volumes sont de type `gp3` et sont chiffrés.

Ils permettent de séparer :

- Le système d’exploitation
- Les données web
- Les logs

Cette séparation facilite :

- L’administration du stockage
- L’augmentation de capacité
- La sauvegarde
- La persistance des données
- La surveillance de l’espace disque

Sur les instances Nitro, `/dev/sdf` et `/dev/sdg` apparaissent généralement comme des périphériques NVMe.

Le rôle Ansible `filesystems` identifie donc les volumes grâce à leur identifiant EBS présent dans leur numéro de série, et non avec un nom NVMe supposé.

---

# Partie Ansible

## 12. Rôle d’Ansible

Ansible configure les systèmes après leur création par Terraform.

Il est utilisé pour :

- Créer les utilisateurs SSH
- Installer les clés publiques
- Préparer et monter les volumes
- Installer Apache
- Générer les pages web
- Configurer Logrotate
- Installer et configurer MariaDB
- Installer et configurer GLPI
- Installer Jenkins
- Vérifier le bon fonctionnement des services

---

## 13. Inventaire Ansible

L’inventaire contient les groupes suivants :

```text
fronts
├── front-01
└── front-02

glpi_app
└── glpi-app

glpi_db
└── glpi-db

jenkins
└── front-01
```

`front-01` appartient donc à deux groupes :

- `fronts`
- `jenkins`

Le serveur `glpi-db` étant privé, Ansible l’atteint avec un ProxyJump passant par `front-01`.

Exemple :

```yaml
glpi-db:
  ansible_host: 10.0.21.140
  ansible_ssh_common_args: >-
    -o ProxyJump=ubuntu@ADRESSE_PUBLIQUE_FRONT_01
    -o IdentitiesOnly=yes
```

Après un arrêt et un redémarrage des instances, il faut mettre à jour :

- L’adresse de `front-01`
- L’adresse de `front-02`
- L’adresse de `glpi-app`
- L’adresse du ProxyJump de `glpi-db`

Une amélioration future consiste à utiliser l’inventaire dynamique AWS EC2.

---

## 14. Vérification de l’inventaire

Se placer dans le répertoire Ansible :

```bash
cd ansible
```

Afficher le graphe :

```bash
ansible-inventory --graph
```

Afficher les variables de `glpi-db` :

```bash
ansible-inventory --host glpi-db
```

Tester les Fronts :

```bash
ansible fronts -m ansible.builtin.ping
```

Tester le serveur GLPI :

```bash
ansible glpi_app -m ansible.builtin.ping
```

Tester MariaDB à travers le bastion :

```bash
ansible glpi_db -m ansible.builtin.ping
```

---

## 15. Ansible Facts

Les `ansible_facts` sont des informations collectées automatiquement sur les machines distantes.

Exemples :

- Nom de la machine
- Adresse IP
- Distribution Linux
- Version du système
- Mémoire disponible
- Processeurs
- Interfaces réseau
- Disques
- Points de montage

Le TP utilise ces Facts pour générer automatiquement la page Apache avec :

- Le nom du serveur
- Son adresse IP privée
- Son système d’exploitation
- Sa mémoire totale

Ils sont collectés avec :

```yaml
gather_facts: true
```

---

## 16. Rôle `ssh_keys`

Ce rôle :

1. Vérifie la définition des utilisateurs
2. Crée les comptes Linux
3. Crée leurs répertoires `.ssh`
4. Installe leurs clés publiques dans `authorized_keys`

Les clés privées ne doivent jamais être copiées sur les serveurs ni ajoutées à Git.

Un utilisateur peut ensuite se connecter avec sa propre clé :

```bash
ssh \
  -i ~/.ssh/SA_CLE_PRIVEE \
  utilisateur@ADRESSE_PUBLIQUE
```

---

## 17. Rôle `filesystems`

Ce rôle prépare les volumes EBS des Fronts.

Pour chaque volume, il :

1. Identifie le disque grâce au numéro de série EBS
2. Vérifie qu’un seul disque correspond
3. Refuse d’utiliser le disque système
4. Vérifie si un filesystem existe déjà
5. Crée un filesystem `ext4` uniquement si nécessaire
6. Ajoute un label au filesystem
7. Crée le point de montage
8. Ajoute une entrée persistante dans `/etc/fstab`
9. Monte le volume

Les labels utilisés sont :

```text
web_data
apache_logs
```

Les entrées `/etc/fstab` ressemblent à :

```text
LABEL=web_data /var/www ext4 defaults,nofail 0 2
LABEL=apache_logs /var/log/apache2 ext4 defaults,nofail 0 2
```

L’option `nofail` évite qu’un problème sur un volume secondaire bloque complètement le démarrage du système.

Vérification :

```bash
ansible fronts \
  -b \
  -m ansible.builtin.command \
  -a 'findmnt --verify --verbose'
```

Vérifier les montages :

```bash
ansible fronts \
  -b \
  -m ansible.builtin.command \
  -a 'findmnt /var/www'
```

```bash
ansible fronts \
  -b \
  -m ansible.builtin.command \
  -a 'findmnt /var/log/apache2'
```

---

## 18. Protection systemd d’Apache

Apache dépend des répertoires :

```text
/var/www
/var/log/apache2
```

Une surcharge systemd utilise :

```ini
[Unit]
RequiresMountsFor=/var/www /var/log/apache2
After=local-fs.target
```

Cette configuration demande à systemd de vérifier que les volumes nécessaires sont montés avant de démarrer Apache.

Cela empêche Apache d’écrire accidentellement dans les répertoires présents sur le disque système lorsqu’un volume EBS attendu n’est pas monté.

---

## 19. Rôle `apache`

Ce rôle :

- Installe Apache
- Active et démarre le service
- Génère une page HTML personnalisée
- Utilise les Ansible Facts
- Vérifie que le service répond

Exemple de page :

```text
Hello World from front-01, 10.0.20.6,
I have a Ubuntu OS and a total of 1.9 GB of memory
```

Vérification :

```bash
curl --fail http://ADRESSE_PUBLIQUE_FRONT_01
```

```bash
curl --fail http://ADRESSE_PUBLIQUE_FRONT_02
```

---

## 20. Rôle `logrotate`

Apache écrit ses logs dans :

```text
/var/log/apache2/
```

Comme ce répertoire est monté sur un volume EBS séparé, les logs ne remplissent pas le disque système.

La configuration Logrotate applique :

```text
daily
rotate 14
compress
delaycompress
missingok
notifempty
create 0640 root adm
```

Cela signifie :

- Rotation quotidienne
- Conservation de 14 rotations
- Compression des anciens logs
- Compression différée de la première archive
- Absence de fichier acceptée
- Aucun fichier vide archivé
- Création avec des permissions limitées

Après rotation, Apache est rechargé pour qu’il écrive dans les nouveaux fichiers.

Afficher la configuration :

```bash
ansible fronts \
  -b \
  -m ansible.builtin.command \
  -a 'cat /etc/logrotate.d/apache2'
```

Vérifier le timer :

```bash
ansible fronts \
  -b \
  -m ansible.builtin.command \
  -a 'systemctl is-active logrotate.timer'
```

Vérifier que le fichier de log est sur le volume EBS :

```bash
ansible fronts \
  -b \
  -m ansible.builtin.command \
  -a 'findmnt --target /var/log/apache2/access.log'
```

---

# Déploiement de MariaDB

## 21. Rôle `mariadb`

MariaDB est installé sur `glpi-db`.

La base de données est privée et écoute sur :

```text
10.0.21.140:3306
```

Le rôle effectue les opérations suivantes :

1. Installation de MariaDB
2. Installation du connecteur Python
3. Activation du service
4. Configuration de l’adresse d’écoute privée
5. Configuration de `utf8mb4`
6. Création de la base `glpi`
7. Chargement des fuseaux horaires
8. Création de l’utilisateur GLPI
9. Attribution des privilèges sur la base

L’utilisateur MariaDB est limité à l’adresse du serveur applicatif :

```text
glpi@10.0.20.164
```

Ce contrôle complète celui du Security Group.

---

## 22. Ansible Vault

Les mots de passe ne sont pas stockés en clair.

Le fichier chiffré est :

```text
group_vars/all/vault.yml
```

Il contient notamment :

```yaml
vault_glpi_db_password: "mot-de-passe-secret"
vault_glpi_admin_password: "mot-de-passe-administrateur-secret"
```

Le contenu réel est chiffré avec Ansible Vault.

Créer ou modifier le fichier :

```bash
ansible-vault edit group_vars/all/vault.yml
```

Forcer l’utilisation de Nano :

```bash
EDITOR=nano ansible-vault edit group_vars/all/vault.yml
```

Vérifier que le fichier est chiffré :

```bash
head -n 1 group_vars/all/vault.yml
```

Résultat attendu :

```text
$ANSIBLE_VAULT;1.1;AES256
```

Le mot de passe du Vault ne doit jamais être commité ni communiqué.

---

## 23. Vérification de MariaDB

Service actif :

```bash
ansible glpi_db \
  --ask-vault-pass \
  -b \
  -m ansible.builtin.command \
  -a 'systemctl is-active mariadb'
```

Service activé au démarrage :

```bash
ansible glpi_db \
  --ask-vault-pass \
  -b \
  -m ansible.builtin.command \
  -a 'systemctl is-enabled mariadb'
```

Port d’écoute :

```bash
ansible glpi_db \
  --ask-vault-pass \
  -b \
  -m ansible.builtin.command \
  -a 'ss -lntp'
```

Vérifier la base :

```bash
ansible glpi_db \
  --ask-vault-pass \
  -b \
  -m ansible.builtin.command \
  -a "mariadb --protocol=socket -uroot -NBe \"SHOW DATABASES LIKE 'glpi';\""
```

Tester le port depuis `glpi-app` :

```bash
ansible glpi_app \
  --ask-vault-pass \
  -m ansible.builtin.wait_for \
  -a 'host=10.0.21.140 port=3306 state=started timeout=10'
```

---

# Déploiement de GLPI

## 24. Rôle de GLPI

GLPI est une application libre de gestion de parc informatique et de centre de services.

Elle permet notamment de gérer :

- Les ordinateurs et équipements
- Les utilisateurs
- Les logiciels
- Les incidents
- Les demandes d’assistance
- Les contrats
- Les fournisseurs
- Les licences
- Les SLA
- L’inventaire

L’architecture utilise deux machines :

```text
glpi-app → Apache + PHP + GLPI
glpi-db  → MariaDB
```

Cette séparation protège la base de données et facilite l’administration.

---

## 25. Rôle `glpi`

Le rôle GLPI effectue les opérations suivantes :

1. Installation d’Apache
2. Installation de PHP 8.3
3. Installation des extensions PHP
4. Vérification de la connexion MariaDB
5. Téléchargement de GLPI 11.0.9
6. Extraction dans `/var/www/glpi`
7. Configuration des permissions
8. Installation du VirtualHost Apache
9. Utilisation de `/var/www/glpi/public` comme `DocumentRoot`
10. Initialisation de la base par la console GLPI
11. Modification du mot de passe administrateur
12. Désactivation des comptes par défaut inutiles
13. Suppression du script d’installation
14. Configuration des tâches automatiques GLPI

Les comptes désactivés sont :

```text
tech
normal
post-only
```

Le compte administrateur reste actif avec le mot de passe sécurisé contenu dans Ansible Vault.

---

## 26. Permissions GLPI

Le code source principal est protégé :

```text
root:www-data
```

Les répertoires qui doivent être modifiables par Apache sont :

```text
/var/www/glpi/config
/var/www/glpi/files
/var/www/glpi/marketplace
/var/www/glpi/plugins
```

Ils appartiennent à :

```text
www-data:www-data
```

Cette séparation évite de donner inutilement à Apache la permission de modifier tout le code de l’application.

---

## 27. Tâches automatiques GLPI

GLPI doit exécuter régulièrement ses actions automatiques :

- Notifications
- SLA
- Nettoyage
- Tâches différées
- Traitement de certaines files d’attente

Le fichier créé est :

```text
/etc/cron.d/glpi
```

Son contenu :

```cron
* * * * * www-data /usr/bin/php /var/www/glpi/front/cron.php >/dev/null 2>&1
```

Vérification :

```bash
ansible glpi_app \
  --ask-vault-pass \
  -b \
  -m ansible.builtin.command \
  -a 'cat /etc/cron.d/glpi'
```

```bash
ansible glpi_app \
  --ask-vault-pass \
  -b \
  -m ansible.builtin.command \
  -a 'systemctl is-active cron'
```

---

## 28. Logs GLPI

### Logs Apache

```text
/var/log/apache2/glpi_access.log
/var/log/apache2/glpi_error.log
```

### Logs applicatifs GLPI

```text
/var/www/glpi/files/_log/
```

Ils peuvent notamment contenir :

```text
php-errors.log
sql-errors.log
cron.log
```

### Logs MariaDB

Le service peut être examiné avec :

```bash
journalctl -u mariadb
```

Selon la configuration, certains fichiers peuvent également être présents dans :

```text
/var/log/mysql/
```

---

## 29. Vérification de GLPI

Version de GLPI :

```bash
ansible glpi_app \
  --ask-vault-pass \
  -b \
  -m ansible.builtin.shell \
  -a 'sudo -u www-data php /var/www/glpi/bin/console --version'
```

Prérequis :

```bash
ansible glpi_app \
  --ask-vault-pass \
  -b \
  -m ansible.builtin.shell \
  -a 'sudo -u www-data php /var/www/glpi/bin/console glpi:system:check_requirements'
```

Service Apache :

```bash
ansible glpi_app \
  --ask-vault-pass \
  -b \
  -m ansible.builtin.command \
  -a 'systemctl is-active apache2'
```

Réponse HTTP :

```bash
curl -I http://ADRESSE_PUBLIQUE_GLPI_APP
```

L’interface GLPI est accessible à :

```text
http://ADRESSE_PUBLIQUE_GLPI_APP
```

Cette adresse utilise HTTP pour le TP. En production, il faudrait ajouter :

- Un nom de domaine
- HTTPS
- Un certificat TLS
- Une sauvegarde de la base
- Une supervision
- Une stratégie de haute disponibilité

---

# Déploiement de Jenkins

## 30. Rôle de Jenkins

Jenkins est un serveur d’automatisation CI/CD.

Il peut être utilisé pour :

- Exécuter des tests
- Construire une application
- Déployer une application
- Lancer des scripts
- Exécuter Terraform ou Ansible dans une chaîne contrôlée

Dans ce TP, Jenkins est installé sur `front-01`.

---

## 31. Rôle `jenkins`

Le rôle effectue les opérations suivantes :

1. Installation de Java 21
2. Installation de la clé officielle Jenkins
3. Ajout du dépôt Jenkins LTS au format Deb822
4. Installation de Jenkins
5. Activation du service
6. Vérification du port `8080`
7. Vérification de la page `/login`

La vérification utilise :

```text
http://127.0.0.1:8080/login
```

La racine `/` peut retourner `403 Forbidden` avant authentification. Cela ne signifie pas que Jenkins est arrêté.

---

## 32. Vérification de Jenkins

Service :

```bash
ansible front-01 \
  --ask-vault-pass \
  -b \
  -m ansible.builtin.command \
  -a 'systemctl is-active jenkins'
```

Port :

```bash
ansible front-01 \
  --ask-vault-pass \
  -b \
  -m ansible.builtin.command \
  -a 'ss -lntp'
```

Version Java :

```bash
ansible front-01 \
  --ask-vault-pass \
  -b \
  -m ansible.builtin.command \
  -a 'java -version'
```

Page de connexion locale :

```bash
ansible front-01 \
  --ask-vault-pass \
  -b \
  -m ansible.builtin.uri \
  -a 'url=http://127.0.0.1:8080/login status_code=200'
```

Jenkins est accessible à :

```text
http://ADRESSE_PUBLIQUE_FRONT_01:8080
```

Pour la première connexion, récupérer le mot de passe temporaire :

```bash
ansible front-01 \
  --ask-vault-pass \
  -b \
  -m ansible.builtin.command \
  -a 'cat /var/lib/jenkins/secrets/initialAdminPassword'
```

Ce mot de passe ne doit pas être partagé ni ajouté au dépôt Git.

---

# Exécution des playbooks

## 33. Vérification de la syntaxe

```bash
ansible-playbook site.yml \
  --syntax-check \
  --ask-vault-pass
```

---

## 34. Exécuter toute la configuration

```bash
ansible-playbook site.yml \
  --ask-vault-pass \
  --diff
```

---

## 35. Exécuter uniquement les Fronts

```bash
ansible-playbook site.yml \
  --limit fronts \
  --ask-vault-pass \
  --diff
```

---

## 36. Exécuter uniquement MariaDB

```bash
ansible-playbook site.yml \
  --limit glpi_db \
  --ask-vault-pass \
  --diff
```

---

## 37. Exécuter uniquement GLPI

```bash
ansible-playbook site.yml \
  --limit glpi_app \
  --ask-vault-pass \
  --diff
```

---

## 38. Exécuter uniquement Jenkins

Comme `front-01` appartient aussi au groupe `fronts`, un tag permet de sélectionner uniquement Jenkins :

```bash
ansible-playbook site.yml \
  --limit front-01 \
  --tags jenkins \
  --ask-vault-pass \
  --diff
```

---

## 39. Mode simulation

Le mode `--check` simule les changements :

```bash
ansible-playbook site.yml \
  --check \
  --diff \
  --ask-vault-pass
```

Certaines opérations ne peuvent pas être totalement simulées, notamment lorsqu’une tâche dépend du résultat d’une commande ou de la création réelle d’un filesystem.

---

## 40. Idempotence

Un playbook est idempotent lorsqu’un second passage ne produit aucun changement si le système est déjà correctement configuré.

Premier passage possible :

```text
changed > 0
```

Deuxième passage attendu :

```text
changed=0
failed=0
unreachable=0
```

Test :

```bash
ansible-playbook site.yml --ask-vault-pass
ansible-playbook site.yml --ask-vault-pass
```

L’idempotence permet d’exécuter régulièrement la configuration sans reproduire inutilement les opérations.

---

# Procédure après un arrêt des EC2

## 41. Redémarrer les instances

Après un arrêt manuel, récupérer leurs identifiants puis les démarrer :

```bash
aws ec2 start-instances \
  --profile tech-mind \
  --region eu-west-3 \
  --instance-ids \
    i-0cd638c9c88b478da \
    i-01dbb91203d7d52fe \
    i-0905e017b3ae667a4 \
    i-0a865e510b16b9848
```

Attendre qu’elles soient démarrées :

```bash
aws ec2 wait instance-running \
  --profile tech-mind \
  --region eu-west-3 \
  --instance-ids \
    i-0cd638c9c88b478da \
    i-01dbb91203d7d52fe \
    i-0905e017b3ae667a4 \
    i-0a865e510b16b9848
```

---

## 42. Contrôler Terraform

```bash
cd terraform

terraform plan \
  -var-file=environments/dev.tfvars \
  -out=tfplan
```

Si le plan propose uniquement des corrections attendues, comme le rattachement des volumes EBS :

```bash
terraform apply tfplan
```

Terraform affiche ensuite les nouvelles adresses publiques dans ses outputs.

---

## 43. Mettre à jour l’inventaire

Reporter les nouvelles adresses dans :

```text
ansible/inventory/hosts.yml
```

Il faut également mettre à jour l’adresse du ProxyJump de `glpi-db`.

Ensuite :

```bash
cd ../ansible
ansible all -m ansible.builtin.ping
```

Il n’est normalement pas nécessaire de réappliquer Ansible uniquement parce que les adresses publiques ont changé.

Il faut le réappliquer si :

- Une configuration a été modifiée
- Une machine a été recréée
- Un volume a été remplacé
- Un service ne fonctionne plus correctement
- On souhaite vérifier l’idempotence

---

# Validation finale

## 44. Contrôle des services

```bash
ansible fronts \
  -b \
  -m ansible.builtin.command \
  -a 'systemctl is-active apache2'
```

```bash
ansible glpi_app \
  --ask-vault-pass \
  -b \
  -m ansible.builtin.command \
  -a 'systemctl is-active apache2'
```

```bash
ansible glpi_db \
  --ask-vault-pass \
  -b \
  -m ansible.builtin.command \
  -a 'systemctl is-active mariadb'
```

```bash
ansible front-01 \
  --ask-vault-pass \
  -b \
  -m ansible.builtin.command \
  -a 'systemctl is-active jenkins'
```

---

## 45. Contrôle des ports

```bash
ansible all \
  --ask-vault-pass \
  -b \
  -m ansible.builtin.command \
  -a 'ss -lntp'
```

Résultats attendus :

| Serveur | Port | Service |
|---|---:|---|
| Fronts | 22 | SSH |
| Fronts | 80 | Apache |
| `glpi-app` | 80 | Apache/GLPI |
| `glpi-db` | 3306 privé | MariaDB |
| `front-01` | 8080 | Jenkins |

---

## 46. Contrôle des pages web

```bash
curl --fail http://ADRESSE_PUBLIQUE_FRONT_01
curl --fail http://ADRESSE_PUBLIQUE_FRONT_02
curl -I http://ADRESSE_PUBLIQUE_GLPI_APP
curl -I http://ADRESSE_PUBLIQUE_FRONT_01:8080/login
```

---

## 47. Contrôle des volumes

```bash
ansible fronts \
  -b \
  -m ansible.builtin.command \
  -a 'lsblk -o NAME,SIZE,FSTYPE,LABEL,UUID,MOUNTPOINTS,SERIAL'
```

```bash
ansible fronts \
  -b \
  -m ansible.builtin.command \
  -a 'findmnt --verify --verbose'
```

---

## 48. Contrôle de la base GLPI

Compter les tables :

```bash
ansible glpi_db \
  --ask-vault-pass \
  -b \
  -m ansible.builtin.command \
  -a "mariadb --protocol=socket -uroot -NBe \"SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='glpi';\""
```

Le résultat doit être supérieur à zéro après l’installation de GLPI.

---

## 49. Contrôle des logs

Apache :

```bash
ansible fronts \
  -b \
  -m ansible.builtin.command \
  -a 'tail -n 10 /var/log/apache2/access.log'
```

GLPI :

```bash
ansible glpi_app \
  --ask-vault-pass \
  -b \
  -m ansible.builtin.command \
  -a 'find /var/www/glpi/files/_log -maxdepth 1 -type f'
```

MariaDB :

```bash
ansible glpi_db \
  --ask-vault-pass \
  -b \
  -m ansible.builtin.command \
  -a 'journalctl -u mariadb -n 20 --no-pager'
```

Jenkins :

```bash
ansible front-01 \
  --ask-vault-pass \
  -b \
  -m ansible.builtin.command \
  -a 'journalctl -u jenkins -n 20 --no-pager'
```

---

# Sécurité et bonnes pratiques

## 50. Bonnes pratiques appliquées

Le projet applique les pratiques suivantes :

- Infrastructure déclarée avec Terraform
- Configuration système déclarée avec Ansible
- Séparation entre infrastructure et configuration
- Variables d’environnement dans `dev.tfvars`
- Utilisation de blocs `data` pour les ressources existantes
- Noms et tags cohérents
- Base de données placée dans un subnet privé
- Aucun accès public à MariaDB
- Filtrage par Security Groups
- Accès Jenkins limité à une adresse `/32`
- Clés SSH individuelles
- Aucun mot de passe dans le dépôt
- Secrets chiffrés avec Ansible Vault
- Volumes EBS chiffrés
- Données web et logs séparés du disque système
- Montages persistants
- Protection systemd des montages Apache
- Rotation et compression des logs
- Permissions GLPI limitées
- Suppression du script d’installation GLPI
- Désactivation des comptes GLPI inutiles
- Contrôles de syntaxe
- Vérification des services
- Playbooks idempotents

---

## 51. Fichiers à ne pas commiter

Le `.gitignore` doit notamment exclure :

```gitignore
# Terraform
**/.terraform/*
*.tfstate
*.tfstate.*
*.tfplan
tfplan
.terraform.lock.hcl.crash
crash.log
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Variables locales ou sensibles
terraform.tfvars
*.auto.tfvars

# Ansible Vault et mots de passe
ansible/group_vars/all/vault.yml
*.vault_pass
.vault_password

# Clés SSH
*.pem
*.key
id_rsa
id_rsa.pub
id_ed25519
id_ed25519.pub

# Éditeur et système
.vscode/
.idea/
*.swp
.DS_Store
```

> Selon la politique du projet, `.terraform.lock.hcl` peut être commité afin de figer la version du provider. Il ne faut alors pas l’ajouter au `.gitignore`.

---

## 52. Améliorations possibles

Pour rapprocher ce projet d’une architecture de production, il serait possible d’ajouter :

- Un inventaire dynamique AWS EC2
- Des Elastic IP ou un DNS
- HTTPS avec un certificat
- Un Application Load Balancer
- Plusieurs zones de disponibilité
- Une base Amazon RDS
- Des sauvegardes automatiques
- Des snapshots EBS
- AWS Systems Manager à la place de SSH
- CloudWatch pour les métriques et logs
- Une gestion centralisée des secrets
- Une pipeline Jenkins
- Molecule pour tester les rôles Ansible
- `ansible-lint`
- `terraform fmt`, `validate` et `tflint` dans une CI
- Un backend distant pour le state Terraform
- Un mécanisme de verrouillage du state

---

## 53. Résultat final

À la fin du TP :

- L’infrastructure AWS est créée avec Terraform
- Les quatre machines sont accessibles selon leur rôle
- MariaDB reste privée
- Apache fonctionne sur les deux Fronts
- Les données web et les logs utilisent des volumes EBS distincts
- Les logs Apache sont automatiquement archivés
- GLPI est installé et connecté à MariaDB
- Les mots de passe sont chiffrés avec Ansible Vault
- Les tâches automatiques GLPI sont actives
- Jenkins fonctionne sur `front-01`
- Les playbooks sont idempotents
- Les principaux contrôles de fonctionnement sont automatisables

Ce projet démontre la complémentarité entre :

```text
Terraform → création de l’infrastructure
Ansible   → configuration des systèmes et applications
GLPI      → gestion du parc et du support informatique
Jenkins   → automatisation CI/CD
```