#!/bin/bash

# Ce script démarre le backend FastAPI et l'application Flutter pour le web en mode séquentiel
# sans nécessiter tmux ou sudo

echo "Démarrage du test de l'application 737calcs en mode web"

# Chemin vers le répertoire du projet
PROJECT_DIR="$(dirname "$(readlink -f "$0")")"
echo "Répertoire du projet: $PROJECT_DIR"

# Démarrer le backend FastAPI en arrière-plan
echo -e "\n\033[1;34mDémarrage du serveur FastAPI...\033[0m"
cd "$PROJECT_DIR/web_backend"
poetry run python main.py &
FASTAPI_PID=$!

# Attendre que le serveur FastAPI démarre
echo "Attente du démarrage du serveur FastAPI (5 secondes)..."
sleep 5

# Démarrer l'application Flutter en mode web
echo -e "\n\033[1;32mDémarrage de l'application Flutter en mode web...\033[0m"
cd "$PROJECT_DIR/flutter_app"
flutter run -d chrome

# Quand l'utilisateur termine avec Flutter (Ctrl+C), arrêter le serveur FastAPI
echo -e "\n\033[1;31mArrêt du serveur FastAPI...\033[0m"
kill $FASTAPI_PID
echo "Test terminé."
