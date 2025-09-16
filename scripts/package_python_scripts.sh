#!/bin/bash
# Script de packaging des scripts Python partagés pour toutes les plateformes
# Cette approche copie les scripts dans les assets de Flutter au lieu de faire une synchronisation manuelle

# Chemin de base du projet
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Charger la configuration d'environnement du projet
if [ -f "$BASE_DIR/.project_config/env_setup.sh" ]; then
    source "$BASE_DIR/.project_config/env_setup.sh"
fi

SHARED_PYTHON_DIR="$BASE_DIR/shared_python"
FLUTTER_DIR="$BASE_DIR/flutter_app"

echo "Préparation des scripts Python pour le packaging..."

# S'assurer que le répertoire assets existe
ASSETS_DIR="$FLUTTER_DIR/assets/shared_python"
mkdir -p "$ASSETS_DIR"
mkdir -p "$ASSETS_DIR/scripts"
mkdir -p "$ASSETS_DIR/packages"

# Copier les scripts Python partagés dans les assets de Flutter
echo "Copie des scripts Python vers les assets de Flutter..."

# Copier les fichiers à la racine (init, web_adapter, etc)
rsync -av --include="*.py" --exclude="*/" --exclude="__pycache__" "$SHARED_PYTHON_DIR/" "$ASSETS_DIR/"

# Copier les dossiers scripts et packages en préservant leur structure
rsync -av --include="*/" --include="*.py" --exclude="*" --exclude="__pycache__" "$SHARED_PYTHON_DIR/scripts/" "$ASSETS_DIR/scripts/"
rsync -av --include="*/" --include="*.py" --exclude="*" --exclude="__pycache__" "$SHARED_PYTHON_DIR/packages/" "$ASSETS_DIR/packages/"

echo "Scripts Python copiés avec succès dans les assets."

# Vérifier que le pubspec.yaml contient les assets nécessaires
if ! grep -q "assets/shared_python/" "$FLUTTER_DIR/pubspec.yaml"; then
    echo "ATTENTION: Assurez-vous que votre pubspec.yaml contient les assets suivants:"
    echo "  assets:"
    echo "    - assets/shared_python/"
fi

# Rappel pour Android
echo "Pour Android (Chaquopy):"
echo "- Les scripts sont chargés via UnifiedPythonService depuis les assets"
echo "- Assurez-vous que le build.gradle.kts est configuré pour Chaquopy"

# Rappel pour iOS
echo "Pour iOS (Python-Apple-support):"
echo "- Les scripts sont extraits au runtime avec UnifiedPythonService"
echo "- Un script de build phase copie également les scripts vers PythonBundle"

# Rappel pour Windows
echo "Pour Windows (Python embarqué):"
echo "- Les scripts sont extraits au runtime avec UnifiedPythonService"
echo "- Python embarqué est déjà configuré dans le dossier windows/python_embedded"

# Rappel pour Web
echo "Pour Web (API backend):"
echo "- Une API Flask/FastAPI gère l'exécution des scripts Python"
echo "- Assurez-vous que les scripts sont disponibles dans votre backend web"

echo ""
echo "Configuration de packaging terminée!"
echo "Vous pouvez maintenant construire votre application Flutter normalement."
echo "Les scripts Python seront automatiquement inclus dans le package."
