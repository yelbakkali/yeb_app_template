#!/bin/bash

# ==========================================================================
# RÉFÉRENCES CROISÉES:
# - Ce fichier est une version adaptée pour macOS de setup_template.sh
# ==========================================================================

# Script de démarrage pour initialiser un nouveau projet à partir du template yeb_app_template
# Version adaptée pour macOS
# Ce script télécharge le template yeb_app_template et configure un nouveau projet
# avec toutes les dépendances nécessaires

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

# Vérifier si les outils nécessaires sont installés
check_prerequisites() {
    print_header "Vérification des prérequis"

    local missing_tools=()

    # Vérifier Git
    if ! command -v git &> /dev/null; then
        missing_tools+=("git")
    else
        print_success "Git est installé"
    fi

    # Vérifier curl ou wget
    if command -v curl &> /dev/null; then
        print_success "curl est installé"
        DOWNLOAD_CMD="curl -LJO"
    elif command -v wget &> /dev/null; then
        print_success "wget est installé"
        DOWNLOAD_CMD="wget"
    else
        missing_tools+=("curl ou wget")
    fi

    # Afficher les erreurs si des outils sont manquants
    if [ ${#missing_tools[@]} -ne 0 ]; then
        print_error "Outils manquants: ${missing_tools[*]}"
        echo -e "Veuillez installer ces outils avant de continuer."
        exit 1
    fi
}

# Configurer le projet en utilisant le nom du dossier actuel
configure_project() {
    print_header "Configuration du projet"

    # Utiliser le nom du dossier courant comme nom du projet
    PROJECT_NAME=$(basename "$(pwd)")

    # Valider le nom du projet
    if [[ ! "$PROJECT_NAME" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        print_warning "Le nom du dossier actuel '$PROJECT_NAME' contient des caractères non supportés."
        echo -e "Pour une meilleure compatibilité, le dossier du projet devrait contenir uniquement des lettres, chiffres et tirets."
        echo -e "Voulez-vous continuer quand même ? (o/n)"
        read -p "> " confirm
        if [[ ! "$confirm" =~ ^[oO]$ ]]; then
            print_error "Installation annulée. Veuillez renommer votre dossier et réessayer."
            exit 1
        fi
    fi

    echo -e "Le nom du projet sera '${GREEN}$PROJECT_NAME${NC}' (basé sur le nom du dossier actuel)."

    echo -e "Entrez une brève description de votre projet:"
    read -p "> " project_description

    echo -e "Entrez votre nom ou celui de votre organisation:"
    read -p "> " project_author

    PROJECT_DESCRIPTION=$project_description
    PROJECT_AUTHOR=$project_author

    print_success "Projet configuré: $PROJECT_NAME"
}

# Télécharger le template depuis GitHub
download_template() {
    print_header "Téléchargement du template"

    echo -e "Téléchargement du template depuis GitHub..."

    # Vérifier si le répertoire courant est vide
    if [ "$(ls -A | grep -v 'macos_setup.sh')" ]; then
        print_error "Le répertoire courant n'est pas vide! Ce script doit être exécuté dans un répertoire vide."
        echo -e "Veuillez créer un nouveau répertoire vide, y déplacer ce script, et réessayer."
        exit 1
    fi

    # Cloner le dépôt directement dans le répertoire courant
    if git clone --depth 1 https://github.com/yelbakkali/yeb_app_template.git temp_repo; then
        # Déplacer tous les fichiers du dossier temporaire vers le répertoire courant
        mv temp_repo/* .
        mv temp_repo/.[!.]* . 2>/dev/null || true  # Déplacer les fichiers cachés
        
        # Supprimer le dossier temporaire
        rm -rf temp_repo
        
        print_success "Template téléchargé avec succès"

        # Supprimer le répertoire .git pour recommencer l'historique
        rm -rf .git

        # Initialiser un nouveau dépôt Git
        git init
        git add .
        git commit -m "Initial commit from yeb_app_template"

        print_success "Nouveau dépôt Git initialisé"
    else
        print_error "Échec du téléchargement du template"
        exit 1
    fi
}

# Personnaliser le template pour le nouveau projet
customize_template() {
    print_header "Personnalisation du template"

    echo -e "Mise à jour des fichiers de configuration..."

    # Mettre à jour le pubspec.yaml principal
    if [ -f "pubspec.yaml" ]; then
        sed -i '' "s/name: yeb_app_template/name: $PROJECT_NAME/g" pubspec.yaml
        sed -i '' "s/description: \"Template d'application Flutter\/Python par YEB\"/description: \"$PROJECT_DESCRIPTION\"/g" pubspec.yaml
        print_success "pubspec.yaml mis à jour"
    fi

    # Mettre à jour les fichiers pyproject.toml
    if [ -f "web_backend/pyproject.toml" ]; then
        sed -i '' "s/name = \"web_backend\"/name = \"${PROJECT_NAME}_web_backend\"/g" web_backend/pyproject.toml
        sed -i '' "s/description = \"API Web pour yeb_app_template\"/description = \"API Web pour $PROJECT_NAME\"/g" web_backend/pyproject.toml
        sed -i '' "s/authors = \[\"Votre Nom <votre.email@example.com>\"\]/authors = [\"$PROJECT_AUTHOR\"]/g" web_backend/pyproject.toml
        print_success "web_backend/pyproject.toml mis à jour"
    fi

    if [ -f "python_backend/pyproject.toml" ]; then
        sed -i '' "s/name = \"python_backend\"/name = \"${PROJECT_NAME}_python_backend\"/g" python_backend/pyproject.toml
        sed -i '' "s/description = \"Backend Python pour yeb_app_template\"/description = \"Backend Python pour $PROJECT_NAME\"/g" python_backend/pyproject.toml
        sed -i '' "s/authors = \[\"Votre Nom <votre.email@example.com>\"\]/authors = [\"$PROJECT_AUTHOR\"]/g" python_backend/pyproject.toml
        print_success "python_backend/pyproject.toml mis à jour"
    fi

    # Mettre à jour le README.md
    if [ -f "README.md" ]; then
        sed -i '' "s/# Template d'Application Flutter\/Python (YEB)\/# $PROJECT_NAME/g" README.md
        sed -i '' "s/Ce template fournit une base pour développer des applications Flutter avec un backend Python./$PROJECT_DESCRIPTION/g" README.md
        print_success "README.md mis à jour"
    fi

    # Mettre à jour le fichier de configuration du projet Flutter
    if [ -f "flutter_app/lib/config/project_config.dart" ]; then
        sed -i '' "s/static const String projectName = \"yeb_app_template\";/static const String projectName = \"$PROJECT_NAME\";/g" flutter_app/lib/config/project_config.dart
        print_success "Fichier de configuration Flutter mis à jour"
    fi

    print_success "Personnalisation terminée"
}

# Exécuter le script d'installation du projet
run_setup_script() {
    print_header "Installation du projet"

    echo -e "Exécution du script d'installation..."

    # Rendre les scripts exécutables
    chmod +x template/entry-points/*.sh 2>/dev/null || true
    chmod +x scripts/*.sh 2>/dev/null || true

    # Exécuter les scripts d'installation nécessaires
    # Note: Les scripts spécifiques peuvent être modifiés selon les besoins du template
    if [ -f "template/entry-points/setup_project.sh" ]; then
        ./template/entry-points/setup_project.sh
    fi

    print_success "Installation terminée"
}

# Nettoyer le projet après l'installation
cleanup_project() {
    print_header "Nettoyage du projet"

    echo -e "Suppression des fichiers temporaires et de la documentation inutile..."

    # Supprimer le dossier template qui n'est plus nécessaire
    if [ -d "template" ]; then
        rm -rf template
    fi

    # Supprimer les scripts d'installation qui ne sont plus nécessaires
    rm -f setup_template.sh setup_template.bat macos_setup.sh

    print_success "Nettoyage terminé"
}

# Fonction principale
main() {
    print_header "Installation du template yeb_app_template pour macOS"
    echo -e "Ce script va créer un nouveau projet basé sur le template yeb_app_template."
    echo -e "Veuillez vous assurer d'être dans un répertoire vide avant de continuer."
    echo -e ""
    echo -e "Voulez-vous continuer? (o/n)"
    read -p "> " confirm
    
    if [[ ! "$confirm" =~ ^[oO]$ ]]; then
        print_error "Installation annulée."
        exit 1
    fi

    check_prerequisites
    configure_project
    download_template
    customize_template
    run_setup_script
    cleanup_project

    print_header "Installation terminée avec succès!"
    echo -e "Votre projet ${GREEN}$PROJECT_NAME${NC} a été créé et configuré."
    echo -e "Pour commencer à développer, consultez le fichier ${BLUE}README.md${NC} pour plus d'informations."
    echo -e "Bonne programmation! 🚀"
}

# Exécuter la fonction principale
main