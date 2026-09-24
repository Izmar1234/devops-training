#!/usr/bin/env bash

set -Eeuo pipefail

# Enregistrer toute l'exécution dans un fichier de logs.
exec > >(tee /var/log/user-data.log \
  | logger -t user-data -s 2>/dev/console) 2>&1

echo "===== Début de la configuration Node.js ====="

# Installer Node.js, npm et garantir la présence de SSM Agent.
dnf install -y nodejs npm amazon-ssm-agent

# Activer SSM Agent au démarrage et le démarrer immédiatement.
systemctl enable --now amazon-ssm-agent

echo "===== Vérification de Node.js ====="

node --version
npm --version

echo "===== Vérification de SSM Agent ====="

amazon-ssm-agent -version
systemctl is-enabled amazon-ssm-agent
systemctl is-active amazon-ssm-agent

echo "===== Configuration Node.js terminée ====="
