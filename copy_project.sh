#!/bin/sh
set -e

# Vérification des arguments
if [ $# -ne 1 ]; then
    echo "Usage: $0 <dossier_destination>"
    exit 1
fi

DEST_DIR="$1"

# Dossier où se trouve le script
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Copie du contenu de : $SCRIPT_DIR"
echo "Vers                : $DEST_DIR"
echo
echo "Appuyez sur Entrée pour continuer..."
read dummy

# Créer le dossier destination s'il n'existe pas
mkdir -p "$DEST_DIR"

# Copier TOUS les fichiers et dossiers (y compris cachés)
cp -R "$SCRIPT_DIR"/. "$DEST_DIR"/

echo "✅ Copie terminée"
