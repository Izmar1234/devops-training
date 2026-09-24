#!/usr/bin/env bash

set -Eeuo pipefail

# Enregistrer toute l'exécution dans un fichier de logs.
exec > >(tee /var/log/user-data.log \
  | logger -t user-data -s 2>/dev/console) 2>&1

echo "===== Début de la configuration Docker ====="

# Installer Docker et garantir la présence de SSM Agent.
dnf install -y docker amazon-ssm-agent

# Autoriser ec2-user à utiliser Docker sans sudo
# après une nouvelle ouverture de session.
usermod -aG docker ec2-user

# Activer Docker au démarrage et le démarrer immédiatement.
systemctl enable --now docker

# Activer SSM Agent au démarrage et le démarrer immédiatement.
systemctl enable --now amazon-ssm-agent

echo "===== Vérification de Docker ====="

docker --version
systemctl is-enabled docker
systemctl is-active docker

echo "===== Vérification de SSM Agent ====="

amazon-ssm-agent -version
systemctl is-enabled amazon-ssm-agent
systemctl is-active amazon-ssm-agent

echo "===== Configuration Docker terminée ====="
