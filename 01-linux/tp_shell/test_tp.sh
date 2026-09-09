#!/usr/bin/env bash

set -Eeuo pipefail

project_dir=$(cd -- "$(dirname -- "$0")" && pwd)


temp_root=${TMPDIR:-"$project_dir/.tmp"}
mkdir -p -- "$temp_root"

test_dir=$(mktemp -d "$temp_root/tp-shell.XXXXXX")

cleanup() {
    rm -rf -- "$test_dir"
}

trap cleanup EXIT

cp "$project_dir"/creation_script.sh "$test_dir/"
cp "$project_dir"/reorganization_script.sh "$test_dir/"
cp "$project_dir"/lancer_les_9_cas.sh "$test_dir/"

cd "$test_dir"
chmod +x ./*.sh


./lancer_les_9_cas.sh 2 2 >/dev/null

expected=18
actual=$(find Root -type f -name '*.dat' | wc -l)

if [[ $actual -ne $expected ]]; then
    echo "ÉCHEC : $actual fichiers trouvés au lieu de $expected."
    exit 1
fi


incorrect_permission=$(
    find Root -type f ! -perm 400 -print -quit
)

if [[ -n $incorrect_permission ]]; then
    echo "ÉCHEC : permissions incorrectes pour $incorrect_permission"
    exit 1
fi


sample=$(find Root -type f -name '*.dat' -print -quit)

if [[ $(wc -l < "$sample") -ne 3 ]]; then
    echo "ÉCHEC : un fichier ne contient pas exactement trois lignes."
    exit 1
fi

echo "✓ 18 fichiers contrôlés."
echo "✓ Arborescence conforme."
echo "✓ Contenu conforme."
echo "✓ Permissions 400 conformes."