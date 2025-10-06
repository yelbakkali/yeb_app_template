#!/bin/bash
# ==========================================================================
# RÉFÉRENCES CROISÉES:
# - Ce fichier est créé pour être utilisé par les scripts d'installation
# ==========================================================================

# Script de vérification et configuration Git
# Ce script vérifie si Git est correctement configuré (user.name et user.email)
# et aide l'utilisateur à configurer Git si nécessaire

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Fonctions utilitaires
echo_info() {
    echo -e "${BLUE}${BOLD}[INFO]${NC} $1"
}

echo_success() {
    echo -e "${GREEN}${BOLD}[SUCCÈS]${NC} $1"
}

echo_warning() {
    echo -e "${YELLOW}${BOLD}[AVERTISSEMENT]${NC} $1"
}

echo_error() {
    echo -e "${RED}${BOLD}[ERREUR]${NC} $1"
}

# Fonction pour vérifier si Git est correctement configuré
check_git_config() {
    echo_info "Vérification de la configuration Git..."

    # Vérifier si Git est installé
    if ! command -v git &> /dev/null; then
        echo_error "Git n'est pas installé sur votre système."
        echo_info "Veuillez installer Git avant de continuer."
        return 1
    fi

    # Vérifier si user.name est configuré
    GIT_USER_NAME=$(git config --global user.name)
    if [ -z "$GIT_USER_NAME" ]; then
        echo_warning "Git user.name n'est pas configuré."
        echo_info "Configuration de Git user.name..."

        read -p "Entrez votre nom pour Git (ex: John Doe) : " git_name
        if [ -z "$git_name" ]; then
            echo_error "Aucun nom fourni. Configuration incomplète."
            return 1
        fi

        git config --global user.name "$git_name"
        echo_success "Git user.name configuré : $git_name"
    else
        echo_success "Git user.name déjà configuré : $GIT_USER_NAME"
    fi

    # Vérifier si user.email est configuré
    GIT_USER_EMAIL=$(git config --global user.email)
    if [ -z "$GIT_USER_EMAIL" ]; then
        echo_warning "Git user.email n'est pas configuré."
        echo_info "Configuration de Git user.email..."

        read -p "Entrez votre email pour Git (ex: john.doe@example.com) : " git_email
        if [ -z "$git_email" ]; then
            echo_error "Aucun email fourni. Configuration incomplète."
            return 1
        fi

        git config --global user.email "$git_email"
        echo_success "Git user.email configuré : $git_email"
    else
        echo_success "Git user.email déjà configuré : $GIT_USER_EMAIL"
    fi

    # Vérifier si la configuration par défaut de la branche est correcte
    GIT_INIT_DEFAULT_BRANCH=$(git config --global init.defaultBranch)
    if [ -z "$GIT_INIT_DEFAULT_BRANCH" ]; then
        echo_info "Configuration de la branche par défaut à 'main'..."
        git config --global init.defaultBranch main
        echo_success "Branche par défaut configurée à 'main'"
    elif [ "$GIT_INIT_DEFAULT_BRANCH" != "main" ]; then
        echo_info "La branche par défaut est actuellement '$GIT_INIT_DEFAULT_BRANCH'."
        echo_info "Pour ce projet, nous recommandons 'main'."
        read -p "Voulez-vous changer la branche par défaut à 'main'? (o/n) : " change_branch
        if [[ "$change_branch" =~ ^[oO]$ ]]; then
            git config --global init.defaultBranch main
            echo_success "Branche par défaut modifiée à 'main'"
        else
            echo_warning "Vous avez choisi de conserver '$GIT_INIT_DEFAULT_BRANCH' comme branche par défaut."
        fi
    else
        echo_success "Branche par défaut déjà configurée à 'main'"
    fi

    echo_success "Configuration Git vérifiée avec succès!"
    return 0
}

# Fonction pour créer un dépôt GitHub et le connecter au dépôt local
setup_github_repository() {
    echo_info "Configuration du dépôt GitHub..."

    # Vérifier si le projet est déjà un dépôt Git
    if [ ! -d ".git" ]; then
        echo_warning "Ce dossier n'est pas un dépôt Git."
        echo_info "Initialisation du dépôt Git..."
        git init
        echo_success "Dépôt Git initialisé localement."
    fi

    # Demander à l'utilisateur s'il souhaite créer un dépôt GitHub
    echo_info "Souhaitez-vous créer un dépôt GitHub et le connecter à ce projet?"
    read -p "Créer un dépôt GitHub? (o/n) : " create_github
    if [[ ! "$create_github" =~ ^[oO]$ ]]; then
        echo_info "Vous avez choisi de ne pas créer de dépôt GitHub."
        echo_info "Vous pourrez le faire plus tard manuellement avec les commandes:"
        echo "1. Créez un dépôt vide sur GitHub"
        echo "2. git remote add origin https://github.com/VOTRE_NOM/VOTRE_REPO.git"
        echo "3. git push -u origin main"
        echo "4. git checkout -b dev && git push -u origin dev"
        return 0
    fi

    # Demander les informations pour le dépôt GitHub
    read -p "Nom d'utilisateur GitHub : " github_username
    if [ -z "$github_username" ]; then
        echo_error "Aucun nom d'utilisateur fourni. Impossible de créer le dépôt GitHub."
        return 1
    fi

    read -p "Nom du dépôt GitHub : " github_repo
    if [ -z "$github_repo" ]; then
        echo_error "Aucun nom de dépôt fourni. Impossible de créer le dépôt GitHub."
        return 1
    fi

    read -p "Description du dépôt (optionnelle) : " github_description

    read -p "Dépôt privé? (o/n) : " is_private
    if [[ "$is_private" =~ ^[oO]$ ]]; then
        private_flag="--private"
    else
        private_flag="--public"
    fi

    echo_warning "Pour créer un dépôt GitHub, vous devez être authentifié avec un token."
    echo_info "Si vous n'avez pas de token GitHub CLI, suivez ces étapes:"
    echo "1. Installez GitHub CLI (gh): https://cli.github.com/manual/installation"
    echo "2. Exécutez 'gh auth login' et suivez les instructions"

    # Vérifier si GitHub CLI est installé
    if ! command -v gh &> /dev/null; then
        echo_error "GitHub CLI (gh) n'est pas installé."
        echo_info "Veuillez installer GitHub CLI pour créer automatiquement le dépôt:"
        echo "- Sur Linux: sudo apt install gh"
        echo "- Sur macOS: brew install gh"
        echo "- Sur Windows: winget install -e --id GitHub.cli"
        echo_info "Vous pourrez créer le dépôt manuellement plus tard."
        return 1
    fi

    # Vérifier si l'utilisateur est authentifié avec GitHub CLI
    if ! gh auth status &> /dev/null; then
        echo_warning "Vous n'êtes pas authentifié avec GitHub CLI."
        echo_info "Veuillez vous authentifier maintenant..."

        gh auth login

        if [ $? -ne 0 ]; then
            echo_error "Échec de l'authentification GitHub CLI."
            echo_info "Vous pourrez créer le dépôt manuellement plus tard."
            return 1
        fi
    fi

    # Créer le dépôt sur GitHub
    echo_info "Création du dépôt GitHub '$github_username/$github_repo'..."
    if [ -n "$github_description" ]; then
        gh repo create "$github_username/$github_repo" $private_flag --description "$github_description" --confirm
    else
        gh repo create "$github_username/$github_repo" $private_flag --confirm
    fi

    if [ $? -ne 0 ]; then
        echo_error "Échec de la création du dépôt GitHub."
        echo_info "Vous pourrez créer le dépôt manuellement plus tard."
        return 1
    fi

    echo_success "Dépôt GitHub créé avec succès!"

    # Ajouter le remote et pousser vers GitHub
    echo_info "Configuration du remote GitHub..."
    git remote add origin "https://github.com/$github_username/$github_repo.git"

    # Créer un premier commit s'il n'y en a pas
    if ! git log -1 &> /dev/null; then
        echo_info "Création d'un commit initial..."
        git add .
        git commit -m "🚀 Initial commit"
    fi

    # Renommer la branche principale en main si nécessaire
    current_branch=$(git branch --show-current)
    if [ "$current_branch" != "main" ]; then
        echo_info "Renommage de la branche '$current_branch' en 'main'..."
        git branch -m "$current_branch" main
    fi

    # Pousser vers GitHub
    echo_info "Envoi du code vers GitHub (branche main)..."
    if ! git push -u origin main; then
        echo_error "Échec de l'envoi vers GitHub."
        echo_info "Vous pourrez pousser le code manuellement plus tard avec 'git push -u origin main'"
        return 1
    fi

    # Créer et pousser la branche dev
    echo_info "Création de la branche de développement 'dev'..."
    git checkout -b dev

    echo_info "Envoi de la branche 'dev' vers GitHub..."
    if ! git push -u origin dev; then
        echo_error "Échec de l'envoi de la branche 'dev' vers GitHub."
        echo_info "Vous pourrez pousser la branche manuellement plus tard avec 'git push -u origin dev'"
        return 1
    fi

    echo_success "Dépôt GitHub configuré avec succès!"
    echo_info "URL du dépôt: https://github.com/$github_username/$github_repo"
    echo_info "Branche principale: main (stable)"
    echo_info "Branche de développement: dev (active)"

    return 0
}

# Exécuter les fonctions si ce script est appelé directement
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    check_git_config
    setup_github_repository
fi
