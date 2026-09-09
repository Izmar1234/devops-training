#!/usr/bin/env bash

set -Eeuo pipefail


shopt -s nullglob

readonly SCRIPT_NAME="$(basename "$0")"
readonly RESET='\033[0m'
readonly CYAN='\033[36m'
readonly GREEN='\033[32m'
readonly RED='\033[31m'
readonly YELLOW='\033[33m'

die() {
    printf "%bErreur :%b %s\n" "$RED" "$RESET" "$*" >&2
    exit 1
}

warn() {
    printf "%b⚠%b %s\n" "$YELLOW" "$RESET" "$*" >&2
}

usage() {
    cat <<EOF
Utilisation :
  ./$SCRIPT_NAME [-n|--dry-run] [RÉPERTOIRE_SOURCE ...]

Sans répertoire source, tous les dossiers Repo_* sont traités.

Options :
  -n, --dry-run  Simule la réorganisation sans modifier les fichiers.
  -h, --help     Affiche cette aide.

Exemples :
  ./$SCRIPT_NAME
  ./$SCRIPT_NAME Repo_devops Repo_data Repo_fonctionnel
  ./$SCRIPT_NAME --dry-run Repo_devops
EOF
}

dry_run=false

case ${1:-} in
    -n|--dry-run)
        dry_run=true
        shift
        ;;
    -h|--help)
        usage
        exit 0
        ;;
esac

if (( $# > 0 )); then
    sources=("$@")
else
    sources=(Repo_*/)
fi

(( ${#sources[@]} > 0 )) ||
    die "Aucun répertoire source n'a été trouvé."

printf "%b╭─ Mission : Grande Réorganisation ─╮%b\n" \
    "$CYAN" "$RESET"

if $dry_run; then
    warn "Mode simulation : aucune modification ne sera effectuée."
fi

moved=0
skipped=0

for source in "${sources[@]}"; do
   
    source=${source%/}

    if [[ ! -d $source ]]; then
        warn "« $source » ignoré : ce n'est pas un répertoire."
        ((++skipped))
        continue
    fi

    source_name=$(basename "$source")

    for old_path in "$source"/*.txt; do
        old_name=$(basename "$old_path")

       
        if [[ $old_name =~ ^(.+)_([0-9]{4})-([0-9]{2})-([0-9]{2})-([0-9]{2})-([0-9]{2})-([0-9]{2})-([0-9]{3})\.txt$ ]]
        then
            prefix=${BASH_REMATCH[1]}
            year=${BASH_REMATCH[2]}
            month=${BASH_REMATCH[3]}
            day=${BASH_REMATCH[4]}
            hour=${BASH_REMATCH[5]}
            minute=${BASH_REMATCH[6]}
            second=${BASH_REMATCH[7]}
            millisecond=${BASH_REMATCH[8]}
        else
            warn "Format inconnu, fichier ignoré : $old_path"
            ((++skipped))
            continue
        fi

        destination_dir="Root/$source_name/$prefix/$year/$month/$day/$hour"

        
        destination="$destination_dir/${minute}${second}${millisecond}.dat"

        [[ ! -e $destination ]] ||
            die "Collision détectée : $destination existe déjà."

        printf "  %s  →  %s\n" "$old_path" "$destination"

        if ! $dry_run; then
            mkdir -p -- "$destination_dir"

            
            original_path=$(realpath -m -- "$old_path")

            
            mv -- "$old_path" "$destination"

            
            printf '%s\n%s\n%s\n' \
                "$old_name" \
                "$original_path" \
                "creation_script.sh" > "$destination"

          
            chmod 400 -- "$destination"
        fi

        ((++moved))
    done
done

printf "%b✓ Terminé :%b %d fichier(s) traité(s), %d ignoré(s).\n" \
    "$GREEN" "$RESET" "$moved" "$skipped"