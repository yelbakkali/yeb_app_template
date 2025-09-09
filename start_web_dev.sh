#!/bin/bash

# Ce script démarre l'application Flutter en mode web et le backend FastAPI

# Chemin vers le répertoire du projet
PROJECT_DIR="$(dirname "$(readlink -f "$0")")"
echo "Répertoire du projet: $PROJECT_DIR"

# Vérifier si tmux est installé
if ! command -v tmux &> /dev/null; then
    echo "tmux n'est pas installé. Installation en cours..."
    sudo apt-get update && sudo apt-get install -y tmux
fi

# Créer une nouvelle session tmux
tmux new-session -d -s yeb_app_template

# Diviser la fenêtre horizontalement
tmux split-window -h

# Pane 0: Démarrer le backend FastAPI
tmux select-pane -t 0
tmux send-keys "cd $PROJECT_DIR/web_backend && ./start_server.sh" C-m

# Attendre que le serveur FastAPI démarre
echo "Démarrage du serveur FastAPI..."
sleep 5

# Pane 1: Démarrer l'application Flutter en mode web
tmux select-pane -t 1
tmux send-keys "cd $PROJECT_DIR/flutter_app && flutter run -d chrome" C-m

# Attacher à la session tmux
tmux attach-session -t yeb_app_template
