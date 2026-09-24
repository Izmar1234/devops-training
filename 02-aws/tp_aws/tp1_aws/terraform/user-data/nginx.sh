#!/usr/bin/env bash

set -Eeuo pipefail

exec > >(tee /var/log/user-data.log \
  | logger -t user-data -s 2>/dev/console) 2>&1

echo "===== Début de la configuration Nginx ====="

dnf install -y nginx python3.12 amazon-ssm-agent

cat > /usr/share/nginx/html/index.html <<'HTML'
<!doctype html>
<html lang="fr">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Serveur Nginx - TP AWS</title>
</head>
<body>
  <h1>Nginx fonctionne correctement</h1>
  <p>Serveur public du TP AWS.</p>
  <p>Propriétaire : Izmar Abderrahim</p>
  <p>Ressource gérée avec Terraform.</p>
</body>
</html>
HTML

nginx -t

systemctl enable nginx
systemctl restart nginx

systemctl enable amazon-ssm-agent
systemctl restart amazon-ssm-agent

echo "===== Vérification de Nginx ====="
nginx -v
systemctl --no-pager status nginx

echo "===== Vérification de Python ====="
python3.12 --version

echo "===== Vérification de SSM Agent ====="
amazon-ssm-agent -version
systemctl --no-pager status amazon-ssm-agent

echo "===== Configuration Nginx terminée ====="