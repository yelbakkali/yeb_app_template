#!/bin/bash
# ==========================================================================
# RÉFÉRENCES CROISÉES:
# - Ce fichier est référencé dans: [template/entry-points/init_project.sh:360, 371, 382]
# - Ce fichier est référencé dans: [docs/project_structure.md:80]
# ==========================================================================

# Script d'installation intelligent - Détecte l'environnement et exécute le script approprié

set -e  # Arrête le script si une erreur se produit

# Fonctions utilitaires
echo_info() {
    echo -e "\033[1;34m[INFO]\033[0m $1"
}

echo_success() {
    echo -e "\033[1;32m[SUCCÈS]\033[0m $1"
}

echo_warning() {
    echo -e "\033[1;33m[AVERTISSEMENT]\033[0m $1"
}

echo_error() {
    echo -e "\033[1;31m[ERREUR]\033[0m $1"
}

# Déterminer l'environnement d'exécution
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    if grep -q Microsoft /proc/version || grep -q microsoft /proc/version; then
        echo_info "Environnement WSL détecté."
        SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
        if [ -f "$SCRIPT_DIR/setup_wsl.sh" ]; then
            echo_info "Exécution du script d'installation pour WSL..."
            bash "$SCRIPT_DIR/setup_wsl.sh"
        else
            echo_error "Script d'installation WSL non trouvé: $SCRIPT_DIR/setup_wsl.sh"
            exit 1
        fi
    else
        echo_info "Environnement Linux natif détecté."
        echo_info "Utilisation du script d'installation WSL (compatible)..."
        SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
        if [ -f "$SCRIPT_DIR/setup_wsl.sh" ]; then
            bash "$SCRIPT_DIR/setup_wsl.sh"
        else
            echo_error "Script d'installation non trouvé: $SCRIPT_DIR/setup_wsl.sh"
            exit 1
        fi
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    echo_info "Environnement macOS détecté."
    SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
    if [ -f "$SCRIPT_DIR/setup_macos.sh" ]; then
        echo_info "Exécution du script d'installation pour macOS..."
        bash "$SCRIPT_DIR/setup_macos.sh"
    else
        echo_error "Script d'installation macOS non trouvé: $SCRIPT_DIR/setup_macos.sh"
        echo_warning "Veuillez installer manuellement les dépendances suivantes:"
        echo "- Flutter (https://docs.flutter.dev/get-started/install/macos)"
        echo "- Python 3 (https://www.python.org/downloads/macos/)"
        echo "- Poetry (https://python-poetry.org/docs/#installation)"
        echo "- VS Code (https://code.visualstudio.com/download)"
        exit 1
    fi
elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    # Windows
    echo_warning "Environnement Windows détecté."
    echo_warning "Veuillez exécuter le script setup_windows.bat en tant qu'administrateur."
    echo_warning "Le script est disponible dans le dossier 'template/utils' du projet."
else
    # Environnement non reconnu
    echo_error "Système d'exploitation non reconnu: $OSTYPE"
    echo_warning "Veuillez installer manuellement les dépendances nécessaires."
    exit 1
fi
