#!/bin/bash

# ==========================================================================
# RÉFÉRENCES CROISÉES:
# - Ce fichier est référencé dans: [README.md:151, 163]
# - Ce fichier est référencé dans: [init_project.sh:556]
# - Ce fichier est référencé dans: [setup_project.sh:203]
# - Ce fichier est référencé dans: [docs/installation.md:150, 151, 201]
# - Ce fichier est référencé dans: [docs/contributing.md:173]
# - Ce fichier est référencé dans: [docs/modes_demarrage.md:7, 44, 51]
# - Ce fichier est référencé dans: [docs/packaging_approach.md:55]
# - Ce fichier est référencé dans: [template/init_project.sh:556]
# - Ce fichier est référencé dans: [template/bootstrap.sh:227, 245]
# - Ce fichier est référencé dans: [template/setup_project.sh:203]
# ==========================================================================

# Script lanceur tout-en-un pour yeb_app_template avec l'approche de packaging
# Ce script prépare les scripts Python pour le packaging, lance le backend web et l'application Flutter

# Chemin de base du projet
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Charger la configuration d'environnement du projet
if [ -f "$BASE_DIR/.project_config/env_setup.sh" ]; then
    source "$BASE_DIR/.project_config/env_setup.sh"
fi

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

# Packager les scripts Python
print_header "Préparation des scripts Python pour le packaging"
bash "$BASE_DIR/scripts/package_python_scripts.sh"

# Définir la variable d'environnement pour le mode développement
export FLUTTER_DEV_MODE=true

# Créer une nouvelle session tmux
SESSION_NAME="yeb_app_template-dev"
tmux new-session -d -s "$SESSION_NAME"

# Diviser l'écran horizontalement
tmux split-window -h -t "$SESSION_NAME"

# Fenêtre 0, Volet 0: Backend Web FastAPI
print_header "Démarrage du backend web FastAPI"
tmux send-keys -t "${SESSION_NAME}:0.0" "cd $BASE_DIR/web_backend && FLUTTER_DEV_MODE=true python3 main.py" C-m

# Fenêtre 0, Volet 1: Frontend Flutter Web
print_header "Démarrage de l'application Flutter Web"
tmux send-keys -t "${SESSION_NAME}:0.1" "cd $BASE_DIR/flutter_app && FLUTTER_DEV_MODE=true flutter run -d chrome --web-hostname 0.0.0.0 --web-port 8080" C-m

# Attacher à la session tmux
print_header "Démarrage de l'environnement de développement yeb_app_template"
echo "Les scripts Python sont maintenant intégrés dans les assets."
echo "- Backend API: http://localhost:8000"
echo "- Frontend Flutter: http://localhost:8080"
echo ""
echo "Mode développement activé: accès direct aux scripts Python source."
echo "Pour le mode production, supprimez la variable FLUTTER_DEV_MODE=true."
echo ""
echo "Utiliser Ctrl+B puis D pour détacher de la session tmux sans arrêter les serveurs."
echo "Pour revenir à la session: tmux attach -t $SESSION_NAME"
echo ""

tmux attach -t "$SESSION_NAME"
