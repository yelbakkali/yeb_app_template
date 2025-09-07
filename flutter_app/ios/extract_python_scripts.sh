#!/bin/sh
# Script pour extraire les scripts Python des assets de Flutter pour iOS

# Répertoire des assets de Flutter
FLUTTER_ASSETS="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/Frameworks/App.framework/flutter_assets"

# Répertoire des scripts Python dans les assets
PYTHON_ASSETS="${FLUTTER_ASSETS}/assets/shared_python"

# Répertoire PythonBundle dans le bundle de l'application
PYTHON_BUNDLE="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/PythonBundle"

# Créer le répertoire PythonBundle
mkdir -p "${PYTHON_BUNDLE}"

# Si le répertoire des assets Python existe, copier son contenu
if [ -d "${PYTHON_ASSETS}" ]; then
    echo "Copie des scripts Python des assets vers PythonBundle..."
    cp -R "${PYTHON_ASSETS}/"* "${PYTHON_BUNDLE}/"
    echo "Scripts Python copiés avec succès."
else
    # Fallback: copier depuis le projet partagé
    SHARED_PYTHON="${PROJECT_DIR}/../../shared_python"
    if [ -d "${SHARED_PYTHON}" ]; then
        echo "Répertoire d'assets Python non trouvé, utilisation du répertoire partagé..."
        cp -R "${SHARED_PYTHON}/"* "${PYTHON_BUNDLE}/"
        echo "Scripts Python copiés depuis le répertoire partagé."
    else
        echo "ERREUR: Impossible de trouver les scripts Python à copier!"
        exit 1
    fi
fi

echo "Configuration Python pour iOS terminée."
