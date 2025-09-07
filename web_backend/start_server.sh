#!/bin/bash

# Ce script installe les dépendances du web_backend et lance le serveur FastAPI

# Chemin vers le répertoire du projet web_backend
WEB_BACKEND_DIR="$(dirname "$(readlink -f "$0")")"
echo "Répertoire du web_backend: $WEB_BACKEND_DIR"

# Vérifier si Poetry est installé
if ! command -v poetry &> /dev/null; then
    echo "Poetry n'est pas installé. Installation en cours..."
    curl -sSL https://install.python-poetry.org | python3 -
fi

# Naviguer vers le répertoire du projet web_backend
cd "$WEB_BACKEND_DIR"

# Installer les dépendances avec Poetry
echo "Installation des dépendances..."
poetry install

# Lancer le serveur FastAPI avec uvicorn
echo "Démarrage du serveur FastAPI..."
poetry run python main.py
