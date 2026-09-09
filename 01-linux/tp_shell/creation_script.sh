#!/usr/bin/env bash

set -Eeuo pipefail

readonly SCRIPT_NAME="$(basename "$0")"
readonly RESET='\033[0m'
readonly CYAN='\033[36m'
readonly GREEN='\033[32m'
readonly RED='\033[31m'

die() {
    printf "%bErreur :%b %s\n" "$RED" "$RESET" "$*" >&2
    exit 1
}

info() {
    printf "%b➜%b %s\n" "$CYAN" "$RESET" "$*"
}

success() {
    printf "%b✓%b %s\n" "$GREEN" "$RESET" "$*"
}

usage() {
    cat <<EOF
Utilisation :
  ./$SCRIPT_NAME [RÉPERTOIRE PRÉFIXE NOMBRE INTERVALLE_MS]

Sans argument, le script fonctionne en mode interactif.

Exemple :
  ./$SCRIPT_NAME Repo_devops git 5 120
EOF
}

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
    usage
    exit 0
fi

if (( $# == 0 )); then
    printf "%b╭─ Forge de fichiers ─────────────────────────╮%b\n" \
        "$CYAN" "$RESET"
    printf "│ Des timestamps précis, forgés à la demande. │\n"
    printf "╰──────────────────────────────────────────────╯\n"

    read -r -p "Répertoire        : " directory
    read -r -p "Préfixe            : " prefix
    read -r -p "Nombre de fichiers : " count
    read -r -p "Intervalle (ms)    : " interval_ms
elif (( $# == 4 )); then
    directory=$1
    prefix=$2
    count=$3
    interval_ms=$4
else
    usage >&2
    exit 2
fi


[[ -n $directory && $directory != "/" ]] ||
    die "Le répertoire indiqué est invalide."

[[ $prefix =~ ^[[:alnum:]][[:alnum:]_-]*$ ]] ||
    die "Le préfixe ne peut contenir que des lettres, chiffres, _ et -."

[[ $count =~ ^[1-9][0-9]*$ ]] ||
    die "Le nombre de fichiers doit être un entier strictement positif."

[[ $interval_ms =~ ^[0-9]+$ ]] ||
    die "L'intervalle doit être un entier positif ou nul."

mkdir -p -- "$directory"

info "Création de $count fichier(s) dans « $directory »..."

for ((i = 1; i <= count; i++)); do
    timestamp=$(date '+%Y-%m-%d-%H-%M-%S-%3N')
    file="$directory/${prefix}_${timestamp}.txt"

    while [[ -e $file ]]; do
        sleep 0.001
        timestamp=$(date '+%Y-%m-%d-%H-%M-%S-%3N')
        file="$directory/${prefix}_${timestamp}.txt"
    done

    
    : > "$file"

    printf "  [%0*d/%d] %s\n" \
        "${#count}" "$i" "$count" "$(basename "$file")"

    
    if (( i != count )); then
        interval_seconds=$(
            awk -v ms="$interval_ms" \
                'BEGIN { printf "%.3f", ms / 1000 }'
        )

        sleep "$interval_seconds"
    fi
done

success "$count fichier(s) créé(s)."