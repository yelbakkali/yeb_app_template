#!/bin/bash
# Script pour démarrer l'application en mode web avec le serveur Python intégré

# Répertoire du projet
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

# Vérifier si Poetry est installé
if ! command -v poetry &> /dev/null; then
    echo "Poetry n'est pas installé. Installation..."
    curl -sSL https://install.python-poetry.org | python3 -
fi

# Installer les dépendances avec l'extra web
echo "Installation des dépendances Python pour le web..."
cd shared_python
# Utiliser l'option --no-root pour éviter l'erreur tuple index out of range
poetry install --extras web --no-root

# Démarrer le serveur Python en arrière-plan
echo "Démarrage du serveur Python..."
poetry run python -c "from web_adapter import start_server; start_server()" &
PYTHON_SERVER_PID=$!

# Attendre que le serveur soit prêt (3 secondes)
echo "Attente du démarrage du serveur..."
sleep 3

# Démarrer l'application Flutter en mode web
echo "Démarrage de l'application Flutter en mode web..."
cd "$PROJECT_DIR/flutter_app"
flutter run -d web-server

# Arrêter le serveur Python lorsque Flutter se termine
kill $PYTHON_SERVER_PID