#!/usr/bin/env bash

set -Eeuo pipefail


cd -- "$(dirname -- "$0")"

count=${1:-4}
interval_ms=${2:-75}

if [[ ! $count =~ ^[1-9][0-9]*$ ]]; then
    echo "Erreur : nombre de fichiers invalide." >&2
    exit 2
fi

if [[ ! $interval_ms =~ ^[0-9]+$ ]]; then
    echo "Erreur : intervalle invalide." >&2
    exit 2
fi

declare -A families=(
    [devops]="git terraform aws"
    [data]="spark scala gcp"
    [fonctionnel]="spec postman sql"
)

echo "============================================"
echo "       LA FORGE CHRONOLOGIQUE DU SHELL"
echo "============================================"
echo
echo "Nombre de fichiers par préfixe : $count"
echo "Intervalle entre les fichiers  : $interval_ms ms"
echo

for family in devops data fonctionnel; do
    echo
    echo "----- Famille : $family -----"

    for prefix in ${families[$family]}; do
        ./creation_script.sh \
            "Repo_$family" \
            "$prefix" \
            "$count" \
            "$interval_ms"
    done
done

echo
echo "Les 9 créations sont terminées."
echo "Lancement de la réorganisation..."
echo

./reorganization_script.sh \
    Repo_devops \
    Repo_data \
    Repo_fonctionnel

echo
echo "============================================"
echo "             MISSION ACCOMPLIE"
echo "============================================"
echo "Les fichiers réorganisés se trouvent dans Root/"