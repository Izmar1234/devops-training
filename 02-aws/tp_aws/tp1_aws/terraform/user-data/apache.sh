#!/usr/bin/env bash

set -Eeuo pipefail

exec > >(tee /var/log/user-data.log \
  | logger -t user-data -s 2>/dev/console) 2>&1

echo "===== Début de la configuration Apache ====="

dnf install -y httpd python3.12 amazon-ssm-agent

cat > /var/www/html/index.html <<'HTML'
<!doctype html>
<html lang="fr">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Serveur Apache - TP AWS</title>
</head>
<body>
  <h1>Apache fonctionne correctement</h1>
  <p>Serveur privé du TP AWS.</p>
  <p>Propriétaire : Izmar Abderrahim</p>
  <p>Ressource gérée avec Terraform.</p>
</body>
</html>
HTML

apachectl configtest

systemctl enable httpd
systemctl restart httpd

systemctl enable amazon-ssm-agent
systemctl restart amazon-ssm-agent

echo "===== Vérification d'Apache ====="
httpd -v
systemctl --no-pager status httpd

echo "===== Vérification de Python ====="
python3.12 --version

echo "===== Vérification de SSM Agent ====="
amazon-ssm-agent -version
systemctl --no-pager status amazon-ssm-agent

echo "===== Configuration Apache terminée ====="