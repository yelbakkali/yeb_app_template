#!/bin/bash

# ==========================================================================
# RÉFÉRENCES CROISÉES:
# - Ce fichier est référencé dans: [README.md:104, 105, 108, 111, 204]
# - Ce fichier est référencé dans: [docs/installation.md:13, 83, 162]
# - Ce fichier est référencé dans: [docs/bootstrap.md:3, 19, 20, 26]
# - Ce fichier est référencé dans: [docs/copilot/template_initialization.md:15]
# - Ce fichier est référencé dans: [.copilot/chat_resume.md:58, 62]
# - Ce fichier est référencé dans: [.copilot/memoire_long_terme.md:108]
# - Ce fichier est référencé dans: [bootstrap.sh:32, 64]
# ==========================================================================

# bootstrap.sh - Script de démarrage pour initialiser un nouveau projet à partir du template yeb_app_template
# Auteur: Yassine El Bakkali
# Ce script télécharge le template yeb_app_template et configure un nouveau projet

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonctions utilitaires
print_header() {
    echo -e "${BLUE}===================================================================${NC}"
    echo -e "${BLUE} $1 ${NC}"
    echo -e "${BLUE}===================================================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Version simplifiée qui télécharge le template complet et lance le bootstrap.sh interne
main() {
    print_header "Initialisation d'un nouveau projet à partir du template yeb_app_template"

    # Vérifier si Git est installé
    if ! command -v git &> /dev/null; then
        print_error "Git n'est pas installé. Veuillez l'installer avant de continuer."
        exit 1
    fi

    # Demander le nom du projet
    echo -e "Entrez le nom de votre nouveau projet (lettres, chiffres et tirets uniquement):"
    read -p "> " project_name

    # Valider le nom du projet
    if [[ ! "$project_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        print_error "Nom de projet invalide. Utilisez uniquement des lettres, chiffres et tirets."
        exit 1
    fi

    # Créer le répertoire du projet
    mkdir -p "$project_name"
    cd "$project_name"

    print_header "Téléchargement du template"

    # Cloner le dépôt
    if git clone --depth 1 https://github.com/yelbakkali/yeb_app_template.git .; then
        print_success "Template téléchargé avec succès"

        # Exécuter le script d'initialisation interne
        # Note: Pour le moment, nous utilisons directement init_project.sh
        # Dans le futur, nous pourrons utiliser template/bootstrap.sh quand il sera disponible
        chmod +x ./init_project.sh
        ./init_project.sh "$project_name"

        print_success "Initialisation terminée"
    else
        print_error "Échec du téléchargement du template"
        exit 1
    fi
}

# Exécuter la fonction principale
main
