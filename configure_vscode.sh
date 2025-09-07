#!/bin/bash

# Script pour configurer VSCode avec l'environnement Poetry

# Chemin vers le répertoire du projet
PROJECT_DIR="$(dirname "$(readlink -f "$0")")"
echo "Répertoire du projet: $PROJECT_DIR"

# Aller dans le répertoire web_backend
cd "$PROJECT_DIR/web_backend"

# Installer les dépendances avec Poetry
echo "Installation des dépendances avec Poetry..."
poetry install

# Obtenir le chemin de l'environnement virtuel
VENV_PATH=$(poetry env info --path)
echo "Chemin de l'environnement virtuel: $VENV_PATH"

# Obtenir la version de Python
PYTHON_VERSION=$(ls -la "$VENV_PATH/lib/" | grep "python" | grep -o "python[0-9]\.[0-9]*" | head -n 1)
echo "Version de Python: $PYTHON_VERSION"

# Créer ou mettre à jour le fichier .vscode/settings.json
mkdir -p "$PROJECT_DIR/.vscode"
cat > "$PROJECT_DIR/.vscode/settings.json" << EOF
{
    "python.defaultInterpreterPath": "$VENV_PATH/bin/python",
    "python.analysis.extraPaths": [
        "$VENV_PATH/lib/$PYTHON_VERSION/site-packages"
    ],
    "python.linting.enabled": true,
    "python.linting.pylintEnabled": true,
    "[python]": {
        "editor.formatOnSave": true,
        "editor.defaultFormatter": "ms-python.python"
    }
}
EOF

# Créer le fichier .env pour le web_backend
cat > "$PROJECT_DIR/web_backend/.env" << EOF
PYTHONPATH=$VENV_PATH/lib/$PYTHON_VERSION/site-packages
EOF

echo "Configuration VSCode terminée. Veuillez redémarrer VSCode pour appliquer les changements."
echo "Vous pouvez exécuter 'code --reload-window' pour recharger VSCode."
