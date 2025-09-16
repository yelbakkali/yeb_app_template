#!/bin/bash
# Script de synchronisation des scripts Python partagés vers chaque plateforme

# Chemin de base du projet
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHARED_PYTHON_DIR="$BASE_DIR/shared_python"
FLUTTER_DIR="$BASE_DIR/flutter_app"

echo "Synchronisation des scripts Python partagés vers les différentes plateformes..."

# Fonction pour synchroniser les fichiers Python vers une destination
sync_python_scripts() {
  local dest_dir="$1"
  local source_dir="$SHARED_PYTHON_DIR"
  
  echo "Synchronisation vers $dest_dir..."
  
  # Créer le répertoire de destination et ses sous-dossiers
  mkdir -p "$dest_dir"
  mkdir -p "$dest_dir/scripts"
  mkdir -p "$dest_dir/packages"
  
  # Copier les fichiers de base
  rsync -av --include="*.py" --exclude="*/" --exclude="__pycache__" "$source_dir/" "$dest_dir/"
  
  # Copier les scripts et packages en préservant la structure
  rsync -av --include="*/" --include="*.py" --exclude="*" --exclude="__pycache__" "$source_dir/scripts/" "$dest_dir/scripts/"
  rsync -av --include="*/" --include="*.py" --exclude="*" --exclude="__pycache__" "$source_dir/packages/" "$dest_dir/packages/"
  
  echo "Synchronisation terminée pour $dest_dir"
}

# 1. Synchroniser vers Android
ANDROID_PYTHON_DIR="$FLUTTER_DIR/android/app/src/main/python"
sync_python_scripts "$ANDROID_PYTHON_DIR"

# 2. Synchroniser vers iOS
IOS_PYTHON_DIR="$FLUTTER_DIR/ios/PythonBundle"
sync_python_scripts "$IOS_PYTHON_DIR"

# 3. Synchroniser vers Windows
WINDOWS_PYTHON_DIR="$FLUTTER_DIR/windows/python_embedded"
sync_python_scripts "$WINDOWS_PYTHON_DIR"

# 4 & 5. Les backends web et Python ont été unifiés dans shared_python
# Donc ces synchronisations ne sont plus nécessaires
echo "Remarque: Les backends web et Python ont été archivés et remplacés par shared_python"

echo "Synchronisation terminée avec succès pour toutes les plateformes!"
echo ""
echo "IMPORTANT: Pensez à exécuter ce script à chaque fois que vous modifiez un script Python partagé."
