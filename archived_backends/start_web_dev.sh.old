#!/bin/bash

# Ce script démarre l'application Flutter en mode web et le backend FastAPI

# Chemin vers le répertoire du projet
PROJECT_DIR="$(dirname "$(readlink -f "$0")")"
echo "Répertoire du projet: $PROJECT_DIR"

# Charger la configuration d'environnement du projet
if [ -f "$PROJECT_DIR/.project_config/env_setup.sh" ]; then
    source "$PROJECT_DIR/.project_config/env_setup.sh"
fi

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
tmux send-keys "cd $PROJECT_DIR/flutter_app && flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080" C-m

# Afficher l'adresse IP de WSL pour faciliter l'accès depuis Windows
WSL_IP=$(ip addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

# Afficher les informations de connexion
echo "============================================================"
echo "Informations de connexion pour le développement avec WSL Remote:"
echo "- Backend FastAPI: http://$WSL_IP:8000"
echo "- Frontend Flutter: http://$WSL_IP:8080"
echo "============================================================"
echo "Pour accéder à ces services depuis Windows, utilisez les adresses ci-dessus."
echo "Pour détacher de la session tmux sans arrêter les serveurs: Ctrl+B puis D"
echo "Pour revenir à la session: tmux attach -t yeb_app_template"

# Attacher à la session tmux
tmux attach-session -t yeb_app_template
