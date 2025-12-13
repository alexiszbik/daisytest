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
echo "Exclusions : .git DaisySP libDaisy stmlib"
echo
echo "Appuyez sur Entrée pour continuer..."
read dummy

# Créer le dossier destination s'il n'existe pas
mkdir -p "$DEST_DIR"

# Protection : éviter copier dans soi-même
case "$DEST_DIR" in
  "$SCRIPT_DIR"/*)
    echo "❌ Le dossier destination est dans le dossier source"
    exit 1
    ;;
esac

# Copie avec exclusions
rsync -a \
  --exclude='.git/' \
  --exclude='build/' \
  --exclude='.gitmodules/' \
  --exclude='DaisySP/' \
  --exclude='libDaisy/' \
  --exclude='stmlib/' \
  "$SCRIPT_DIR"/ "$DEST_DIR"/

echo "✅ Copie terminée"

cd $DEST_DIR

OLD_NAME="DaisyTest"             # mot à remplacer
NEW_NAME="MonNouveauProjet"      # nouveau mot

# Cherche tous les fichiers texte et remplace
find . -type f \
  -exec perl -pi -e "s/$OLD_NAME/$NEW_NAME/g" {} +


echo "✅ Remplacement terminé"

echo "🔹 Renommage des fichiers et dossiers..."
# Renommer tous les fichiers et dossiers contenant OLD_NAME
find . -depth -name "*$OLD_NAME*" | while IFS= read -r f; do
    # Calcul du nouveau chemin
    newf=$(echo "$f" | sed "s/$OLD_NAME/$NEW_NAME/g")
    mv "$f" "$newf"
done


git init

git submodule add https://github.com/electro-smith/libDaisy.git libDaisy
git submodule add https://github.com/electro-smith/DaisySP.git DaisySP
git submodule add https://github.com/pichenettes/stmlib.git stmlib

git add .
git commit -m "First commit"

git submodule update --init --recursive
