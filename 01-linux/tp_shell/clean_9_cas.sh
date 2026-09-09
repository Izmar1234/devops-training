#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(
    cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &&
    pwd -P
)"

cd -- "$SCRIPT_DIR"

echo "========================================"
echo "      NETTOYAGE DES 9 CAS DU TP"
echo "========================================"
echo

targets=(
    "Repo_data"
    "Repo_devops"
    "Repo_fonctionnel"
    "Root"
)

deleted=0

for target in "${targets[@]}"; do
    if [[ -e "$target" ]]; then
        echo "Nettoyage de : $target"

    
        chmod -R u+rwX -- "$target" 2>/dev/null || true

        rm -rf -- "$target"

        if [[ ! -e "$target" ]]; then
            echo "✓ Supprimé : $target"
            ((++deleted))
        else
            echo "✗ Impossible de supprimer : $target" >&2
        fi
    else
        echo "– Absent : $target"
    fi
done

echo

if (( deleted == 0 )); then
    echo "Aucun dossier des 9 cas n'était présent."
else
    echo "✓ Nettoyage terminé : $deleted dossier(s) supprimé(s)."
fi