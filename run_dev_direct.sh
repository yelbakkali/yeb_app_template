#!/bin/bash
# Script lanceur optimisé pour le mode développement (sans synchronisation)
# Ce script configure l'environnement pour accéder directement aux scripts partagés

# Chemin de base du projet
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Fonction pour afficher les messages
print_header() {
    echo ""
    echo "====================================================="
    echo "$1"
    echo "====================================================="
    echo ""
}

# Vérifier si tmux est installé
if ! command -v tmux &> /dev/null; then
    echo "tmux n'est pas installé. Installation..."
    sudo apt-get update && sudo apt-get install -y tmux
fi

# Définir la variable d'environnement pour le mode développement
export FLUTTER_DEV_MODE=true

# Créer une nouvelle session tmux
SESSION_NAME="737calcs-direct"
tmux new-session -d -s "$SESSION_NAME"

# Diviser l'écran horizontalement
tmux split-window -h -t "$SESSION_NAME"

# Fenêtre 0, Volet 0: Backend Web FastAPI
print_header "Démarrage du backend web FastAPI (accès direct)"
tmux send-keys -t "${SESSION_NAME}:0.0" "cd $BASE_DIR/web_backend && python3 main.py" C-m

# Fenêtre 0, Volet 1: Frontend Flutter Web
print_header "Démarrage de l'application Flutter Web (accès direct)"
tmux send-keys -t "${SESSION_NAME}:0.1" "cd $BASE_DIR/flutter_app && FLUTTER_DEV_MODE=true flutter run -d chrome --web-hostname 0.0.0.0 --web-port 8080" C-m

# Attacher à la session tmux
print_header "Démarrage de l'environnement de développement 737calcs (accès direct)"
echo "L'application accède directement aux scripts Python partagés"
echo "- Backend API: http://localhost:8000"
echo "- Frontend Flutter: http://localhost:8080"
echo ""
echo "Utiliser Ctrl+B puis D pour détacher de la session tmux sans arrêter les serveurs."
echo "Pour revenir à la session: tmux attach -t $SESSION_NAME"
echo ""

tmux attach -t "$SESSION_NAME"
