#!/bin/sh
set -e

# Check arguments
if [ $# -ne 2 ]; then
    echo "Usage: $0 <destination_folder> <new_project_name>"
    echo "Example: $0 ../MyNewProjects MyNewProject"
    exit 1
fi

DEST_DIR="$1"
PROJECT_NAME="$2"

# Folder where the script is located
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Create destination folder if it does not exist
mkdir -p "$DEST_DIR"

# Safety: avoid copying into itself
case "$DEST_DIR" in
  "$SCRIPT_DIR"/*)
    echo "❌ Destination folder is inside the source folder"
    exit 1
    ;;
esac

# Copy with exclusions
rsync -a \
  --exclude='.git/' \
  --exclude='build/' \
  --exclude='copy_project.sh' \
  --exclude='.gitmodules/' \
  --exclude='DaisySP/' \
  --exclude='DaisyYMNK/' \
  --exclude='libDaisy/' \
  --exclude='stmlib/' \
  "$SCRIPT_DIR"/ "$DEST_DIR"/

echo "✅ Copy completed"

cd "$DEST_DIR"

OLD_NAME="DaisyTest"   
NEW_NAME=$PROJECT_NAME 

# Search all text files and replace occurrences
find . -type f \
  -exec perl -pi -e "s/$OLD_NAME/$NEW_NAME/g" {} +

echo "✅ Replacement completed"

echo "🔹 Renaming files and folders..."
# Rename all files and folders containing OLD_NAME
find . -depth -name "*$OLD_NAME*" | while IFS= read -r f; do
    # Compute new path
    newf=$(echo "$f" | sed "s/$OLD_NAME/$NEW_NAME/g")
    mv "$f" "$newf"
done

# Initialize git repository
git init

# Add submodules
git submodule add https://github.com/electro-smith/libDaisy.git libDaisy
git submodule add https://github.com/electro-smith/DaisySP.git DaisySP
git submodule add https://github.com/pichenettes/stmlib.git stmlib
git submodule add git@github.com:alexiszbik/DaisyYMNK.git DaisyYMNK

# Add all files and commit
git add .
git commit -m "First commit"


cd libDaisy
git fetch --tags
git checkout v5.0.0

# Initialize and update submodules recursively
git submodule update --init --recursive

