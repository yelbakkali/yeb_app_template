#!/bin/bash
# bootstrap.sh - Script autonome pour initialiser un nouveau projet à partir du template yeb_app_template
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

# Demander le nom du projet à l'utilisateur
ask_project_name() {
    print_header "Configuration du projet"
    
    echo -e "Entrez le nom de votre nouveau projet (lettres, chiffres et tirets uniquement):"
    read -p "> " project_name
    
    # Valider le nom du projet
    if [[ ! "$project_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        print_error "Nom de projet invalide. Utilisez uniquement des lettres, chiffres et tirets."
        ask_project_name
        return
    fi
    
    echo -e "Entrez une brève description de votre projet:"
    read -p "> " project_description
    
    echo -e "Entrez votre nom ou celui de votre organisation:"
    read -p "> " project_author
    
    PROJECT_NAME=$project_name
    PROJECT_DESCRIPTION=$project_description
    PROJECT_AUTHOR=$project_author
    
    print_success "Nom du projet configuré: $PROJECT_NAME"
}

# Télécharger le template depuis GitHub
download_template() {
    print_header "Téléchargement du template"
    
    # Créer le répertoire du projet
    mkdir -p "$PROJECT_NAME"
    cd "$PROJECT_NAME"
    
    echo -e "Téléchargement du template depuis GitHub..."
    
    # Cloner le dépôt
    if git clone --depth 1 https://github.com/yelbakkali/yeb_app_template.git .; then
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
    chmod +x setup_project.sh
    chmod +x scripts/*.sh
    
    # Exécuter le script d'installation
    ./setup_project.sh
    
    if [ $? -eq 0 ]; then
        print_success "Installation terminée avec succès"
    else
        print_warning "L'installation a rencontré des problèmes. Vérifiez les logs ci-dessus."
    fi
}

# Instructions pour GitHub Copilot
create_copilot_instructions() {
    print_header "Configuration pour GitHub Copilot"
    
    echo -e "Création des instructions pour GitHub Copilot..."
    
    # Créer un fichier d'instructions pour GitHub Copilot
    cat > docs/copilot/bootstrap_instructions.md << EOL
# Instructions pour GitHub Copilot

Ce fichier contient des instructions spécifiques pour GitHub Copilot afin qu'il puisse comprendre rapidement la structure et la méthodologie du projet lorsqu'il est interrogé par l'utilisateur.

## Étapes d'initialisation automatique pour Copilot

1. **Lecture de la documentation**:
   - Lire d'abord le fichier \`docs/project_structure.md\` pour comprendre l'architecture du projet
   - Consulter \`docs/contributing.md\` pour connaître les conventions de code et le workflow
   - Vérifier \`docs/installation.md\` pour comprendre l'environnement de développement

2. **Compréhension de la méthodologie**:
   - Examiner le workflow Git dans \`docs/git_workflow.md\`
   - Comprendre comment les tests sont organisés dans \`docs/testing.md\`
   - Identifier les pratiques de développement Flutter/Python dans la documentation

3. **Adaptation au contexte de l'utilisateur**:
   - Comprendre que ce projet s'appelle \`$PROJECT_NAME\`
   - La description du projet est: \`$PROJECT_DESCRIPTION\`
   - Adapter les suggestions et réponses à ce contexte spécifique

## Rappels importants pour Copilot

- **Architecture hybride**: Ce projet utilise Flutter pour le frontend et Python pour le backend
- **Structure multi-package**: Le code Flutter est dans \`flutter_app/\`, les backends Python sont séparés
- **Chemins relatifs**: Toujours utiliser des chemins relatifs, jamais de chemins absolus
- **Automatisation**: Utiliser les scripts dans \`scripts/\` pour les tâches courantes
- **Tests**: Les tests Flutter sont dans \`flutter_app/test/\`, pas à la racine

## Commandes à connaître

- \`./setup_project.sh\`: Pour (ré)initialiser le projet
- \`./run_dev.sh\`: Pour lancer l'environnement de développement complet
- \`./scripts/git_autocommit.sh\`: Pour faciliter les commits Git
- \`cd flutter_app && flutter test\`: Pour exécuter les tests Flutter

Cette documentation sera automatiquement consultée par GitHub Copilot lorsqu'il sera interrogé sur ce projet.
EOL

    print_success "Instructions pour GitHub Copilot créées"
}

# Afficher les instructions finales
show_final_instructions() {
    print_header "Félicitations! Votre projet est prêt."
    
    echo -e "Le projet ${GREEN}$PROJECT_NAME${NC} a été créé et configuré avec succès."
    echo -e ""
    echo -e "Pour commencer à travailler sur votre projet:"
    echo -e "1. Ouvrez le projet dans VS Code:"
    echo -e "   ${YELLOW}code .${NC}"
    echo -e ""
    echo -e "2. Exécutez l'environnement de développement complet:"
    echo -e "   ${YELLOW}./run_dev.sh${NC}"
    echo -e ""
    echo -e "3. Pour travailler avec GitHub Copilot, demandez-lui simplement de vous assister."
    echo -e "   GitHub Copilot a reçu des instructions spécifiques pour ce projet."
    echo -e ""
    echo -e "La documentation complète se trouve dans le répertoire ${YELLOW}docs/${NC}."
    echo -e ""
    echo -e "${GREEN}Bon développement!${NC}"
}

# Fonction principale
main() {
    print_header "Création d'un nouveau projet à partir du template yeb_app_template"
    
    check_prerequisites
    ask_project_name
    download_template
    customize_template
    create_copilot_instructions
    run_setup_script
    show_final_instructions
}

# Exécuter la fonction principale
main