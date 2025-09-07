# Script pour copier les scripts Python partagés vers le bundle iOS

# Chemin du dossier PythonBundle dans le projet iOS
PYTHON_BUNDLE_PATH="${PROJECT_DIR}/PythonBundle"

# Chemin du dossier shared_python dans le projet Flutter
SHARED_PYTHON_PATH="${PROJECT_DIR}/../../shared_python"

# Créer le dossier PythonBundle s'il n'existe pas
mkdir -p "${PYTHON_BUNDLE_PATH}"

# Copier tous les fichiers .py du dossier shared_python vers PythonBundle
cp -R "${SHARED_PYTHON_PATH}/"* "${PYTHON_BUNDLE_PATH}/"

echo "Scripts Python partagés copiés vers ${PYTHON_BUNDLE_PATH}"
