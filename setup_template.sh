#!/bin/bash

# ==========================================================================
# RÉFÉRENCES CROISÉES:
# - Ce fichier est référencé dans: [README.md:104, 105, 108, 111, 204]
# - Ce fichier est référencé dans: [docs/installation.md:13, 83, 162]
# - Ce fichier est référencé dans: [docs/bootstrap.md:3, 19, 20, 26]
# - Ce fichier est référencé dans: [docs/copilot/template_initialization.md:15]
# - Ce fichier est référencé dans: [.copilot/chat_resume.md:58, 62]
# - Ce fichier est référencé dans: [.copilot/memoire_long_terme.md:108]
# ==========================================================================

# setup_template.sh - Script de démarrage pour initialiser un nouveau projet à partir du template yeb_app_template
# Auteur: Yassine El Bakkali
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

    # Sauvegarder le script actuel
    cp setup_template.sh setup_template.sh.bak

    # Cloner le dépôt directement dans le répertoire courant
    if git clone --depth 1 https://github.com/yelbakkali/yeb_app_template.git .; then
        # Restaurer notre script original
        mv setup_template.sh.bak setup_template.sh
        chmod +x setup_template.sh

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
        sed -i "s/name: yeb_app_template/name: $PROJECT_NAME/g" pubspec.yaml
        sed -i "s/description: \"Template d'application Flutter\/Python par YEB\"/description: \"$PROJECT_DESCRIPTION\"/g" pubspec.yaml
        print_success "pubspec.yaml mis à jour"
    fi

    # Mettre à jour les fichiers pyproject.toml
    if [ -f "web_backend/pyproject.toml" ]; then
        sed -i "s/name = \"web_backend\"/name = \"${PROJECT_NAME}_web_backend\"/g" web_backend/pyproject.toml
        sed -i "s/description = \"API Web pour yeb_app_template\"/description = \"API Web pour $PROJECT_NAME\"/g" web_backend/pyproject.toml
        sed -i "s/authors = \[\"Votre Nom <votre.email@example.com>\"\]/authors = [\"$PROJECT_AUTHOR\"]/g" web_backend/pyproject.toml
        print_success "web_backend/pyproject.toml mis à jour"
    fi

    if [ -f "python_backend/pyproject.toml" ]; then
        sed -i "s/name = \"python_backend\"/name = \"${PROJECT_NAME}_python_backend\"/g" python_backend/pyproject.toml
        sed -i "s/description = \"Backend Python pour yeb_app_template\"/description = \"Backend Python pour $PROJECT_NAME\"/g" python_backend/pyproject.toml
        sed -i "s/authors = \[\"Votre Nom <votre.email@example.com>\"\]/authors = [\"$PROJECT_AUTHOR\"]/g" python_backend/pyproject.toml
        print_success "python_backend/pyproject.toml mis à jour"
    fi

    # Mettre à jour le README.md
    if [ -f "README.md" ]; then
        sed -i "s/# Template d'Application Flutter\/Python (YEB)\/# $PROJECT_NAME/g" README.md
        sed -i "s/Ce template fournit une base pour développer des applications Flutter avec un backend Python./$PROJECT_DESCRIPTION/g" README.md
        print_success "README.md mis à jour"
    fi

    # Mettre à jour le fichier de configuration du projet Flutter
    if [ -f "flutter_app/lib/config/project_config.dart" ]; then
        sed -i "s/static const String projectName = \"yeb_app_template\";/static const String projectName = \"$PROJECT_NAME\";/g" flutter_app/lib/config/project_config.dart
        print_success "Fichier de configuration Flutter mis à jour"
    fi

    print_success "Personnalisation terminée"
}

# Exécuter le script d'installation du projet
run_setup_script() {
    print_header "Installation du projet"

    echo -e "Exécution du script d'installation..."

    # Rendre les scripts exécutables
    chmod +x template/entry-points/*.sh
    chmod +x scripts/*.sh

    # Exécuter les scripts d'installation nécessaires
    # Note: Les scripts spécifiques peuvent être modifiés selon les besoins du template
    if [ -f "template/entry-points/setup_project.sh" ]; then
        ./template/entry-points/setup_project.sh
    fi

    if [ $? -eq 0 ]; then
        print_success "Installation terminée avec succès"
    else
        print_warning "L'installation a rencontré des problèmes. Vérifiez les logs ci-dessus."
    fi

    # Suppression du dossier template qui n'est plus nécessaire après l'installation
    if [ -d "template" ]; then
        echo -e "Suppression du dossier template qui n'est plus nécessaire..."
        rm -rf template
        print_success "Dossier template supprimé avec succès"
    fi
}

# Mise à jour des instructions pour GitHub Copilot
update_copilot_instructions() {
    print_header "Mise à jour des instructions pour GitHub Copilot"

    echo -e "Mise à jour des instructions pour GitHub Copilot..."

    # Vérifier l'existence des répertoires et fichiers
    if [ -d ".github" ] && [ -f ".github/copilot-instructions.md" ]; then
        # Remplacer le nom du projet dans les instructions Copilot
        echo -e "Mise à jour du fichier .github/copilot-instructions.md..."
        sed -i "s/YEB App Template/$PROJECT_NAME/g" .github/copilot-instructions.md
        sed -i "s/yeb_app_template/$PROJECT_NAME/g" .github/copilot-instructions.md
    else
        echo -e "${YELLOW}Avertissement:${NC} Le fichier .github/copilot-instructions.md n'a pas été trouvé."
    fi

    # Mettre à jour les informations dans le fichier de mémoire long terme
    if [ -d ".copilot" ] && [ -f ".copilot/memoire_long_terme.md" ]; then
        echo -e "Mise à jour du fichier .copilot/memoire_long_terme.md..."
        sed -i "s/YEB App Template/$PROJECT_NAME/g" .copilot/memoire_long_terme.md
        sed -i "s/yeb_app_template/$PROJECT_NAME/g" .copilot/memoire_long_terme.md
    fi

    # Créer le fichier chat_resume.md s'il n'existe pas encore
    if [ ! -f ".copilot/chat_resume.md" ]; then
        echo -e "Création du fichier .copilot/chat_resume.md..."
        mkdir -p .copilot
        cat > .copilot/chat_resume.md << EOL
# Résumé des sessions de travail - Projet $PROJECT_NAME

Ce fichier sert à maintenir un résumé chronologique des sessions de travail avec GitHub Copilot sur le projet $PROJECT_NAME.

## Initialisation du projet

- Date: $(date +"%Y-%m-%d")
- Actions:
  - Création initiale du projet à partir du template yeb_app_template
  - Personnalisation du projet avec le nom "$PROJECT_NAME"
  - Description du projet: "$PROJECT_DESCRIPTION"
  - Configuration de l'environnement de développement

## Prochaines étapes

- Personnaliser l'interface utilisateur Flutter pour répondre aux besoins du projet
- Adapter les scripts Python pour les calculs spécifiques au projet
- Mettre en place la logique métier spécifique au projet

EOL
    fi

    print_success "Instructions pour GitHub Copilot mises à jour"
}

# Afficher les instructions finales
show_final_instructions() {
    print_header "Félicitations! Votre projet est prêt."

    echo -e "Le projet ${GREEN}$PROJECT_NAME${NC} a été créé et configuré avec succès."
    echo -e ""
    echo -e "Prochaines étapes recommandées :"
    echo -e "1. Consultez la documentation dans le dossier ${YELLOW}docs/${NC} pour plus d'informations"
    echo -e "2. Lancez votre application en développement avec ${YELLOW}./run_dev.sh${NC} (Unix) ou ${YELLOW}run_dev.bat${NC} (Windows)"
    echo -e "3. Pour le développement web, utilisez ${YELLOW}./start_web_integrated.sh${NC} (Unix) ou ${YELLOW}start_web_integrated.bat${NC} (Windows)"
    echo -e "4. Créez une branche de développement avec: ${YELLOW}git checkout -b dev${NC}"
    echo -e "5. Utilisez git avec le workflow recommandé : développement sur ${YELLOW}'dev'${NC}, fusion vers ${YELLOW}'main'${NC}"
    echo -e "   Pour fusionner dev vers main : ${YELLOW}scripts/merge_to_main.sh${NC}"
    echo -e ""
    echo -e "Si vous utilisez VS Code avec GitHub Copilot, demandez à l'assistant de ${YELLOW}'lire les fichiers dans .copilot'${NC}"
    echo -e "pour vous aider à personnaliser davantage votre projet."
    echo -e ""
    echo -e "${GREEN}Bon développement!${NC}"
}

# Fonction principale
main() {
    print_header "Création d'un nouveau projet à partir du template yeb_app_template"

    check_prerequisites
    configure_project
    download_template
    customize_template
    update_copilot_instructions
    run_setup_script
    show_final_instructions
}

# Exécuter la fonction principale
main
