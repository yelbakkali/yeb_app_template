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
  
  # Créer le répertoire de destination s'il n'existe pas
  mkdir -p "$dest_dir"
  
  # Copier les fichiers .py et les dossiers
  rsync -av --include="*/" --include="*.py" --exclude="*" "$source_dir/" "$dest_dir/"
  
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

# 4. Synchroniser vers le backend web
WEB_BACKEND_PYTHON_DIR="$BASE_DIR/web_backend/python_modules"
sync_python_scripts "$WEB_BACKEND_PYTHON_DIR"

# 5. Synchroniser vers python_backend pour le développement
PYTHON_BACKEND_DIR="$BASE_DIR/python_backend"
sync_python_scripts "$PYTHON_BACKEND_DIR"

echo "Synchronisation terminée avec succès pour toutes les plateformes!"
echo ""
echo "IMPORTANT: Pensez à exécuter ce script à chaque fois que vous modifiez un script Python partagé."
