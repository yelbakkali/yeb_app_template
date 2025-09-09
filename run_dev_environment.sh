#!/bin/bash
# Script lanceur tout-en-un pour yeb_app_template
# Ce script synchronise les scripts Python, lance le backend web et l'application Flutter

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

# Synchroniser les scripts Python
print_header "Synchronisation des scripts Python partagés"
bash "$BASE_DIR/sync_python_scripts.sh"

# Créer une nouvelle session tmux
SESSION_NAME="yeb_app_template"
tmux new-session -d -s "$SESSION_NAME"

# Diviser l'écran horizontalement
tmux split-window -h -t "$SESSION_NAME"

# Fenêtre 0, Volet 0: Backend Web FastAPI
print_header "Démarrage du backend web FastAPI"
tmux send-keys -t "${SESSION_NAME}:0.0" "cd $BASE_DIR/web_backend && python3 main.py" C-m

# Fenêtre 0, Volet 1: Frontend Flutter Web
print_header "Démarrage de l'application Flutter Web"
tmux send-keys -t "${SESSION_NAME}:0.1" "cd $BASE_DIR/flutter_app && flutter run -d chrome --web-hostname 0.0.0.0 --web-port 8080" C-m

# Attacher à la session tmux
print_header "Démarrage de l'environnement de développement 737calcs"
echo "L'application sera accessible sur:"
echo "- Backend API: http://localhost:8000"
echo "- Frontend Flutter: http://localhost:8080"
echo ""
echo "Utiliser Ctrl+B puis D pour détacher de la session tmux sans arrêter les serveurs."
echo "Pour revenir à la session: tmux attach -t $SESSION_NAME"
echo ""

tmux attach -t "$SESSION_NAME"
