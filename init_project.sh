#!/bin/bash
# Script d'initialisation du projet après l'utilisation du template

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

# Vérifier si git est disponible
if ! command -v git &> /dev/null; then
    print_error "Git n'est pas installé. Veuillez l'installer pour continuer."
    exit 1
fi

# Détecter le nom du projet à partir du dossier racine
REPO_PATH=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -z "$REPO_PATH" ]; then
    REPO_PATH=$(pwd)
fi
PROJECT_NAME=$(basename "$REPO_PATH")

# Si le nom du projet est toujours yeb_app_template, demander à l'utilisateur de le personnaliser
if [ "$PROJECT_NAME" == "yeb_app_template" ]; then
    print_warning "Le nom du dossier racine est encore 'yeb_app_template'."
    read -p "Entrez un nom personnalisé pour votre projet (sans espaces ni caractères spéciaux) : " CUSTOM_NAME
    if [ -n "$CUSTOM_NAME" ]; then
        PROJECT_NAME="$CUSTOM_NAME"
    fi
fi

print_header "Initialisation du projet '$PROJECT_NAME'"
echo "Ce script va personnaliser le template pour votre projet."

# Créer un fichier de configuration central pour le nom du projet
echo "Création du fichier de configuration du projet..."
mkdir -p .project_config
cat > .project_config/project_info.sh << EOF
#!/bin/bash
# Informations sur le projet - générées automatiquement
PROJECT_NAME="$PROJECT_NAME"
PROJECT_CREATED_DATE="$(date +"%Y-%m-%d")"
EOF
chmod +x .project_config/project_info.sh

# Version Windows
cat > .project_config/project_info.bat << EOF
@echo off
REM Informations sur le projet - générées automatiquement
set PROJECT_NAME=$PROJECT_NAME
set PROJECT_CREATED_DATE=$(date +"%Y-%m-%d")
EOF

# Création d'un fichier Dart pour les constantes du projet
mkdir -p flutter_app/lib/config
cat > flutter_app/lib/config/project_config.dart << EOF
// Fichier généré automatiquement - Contient les informations de base du projet
class ProjectConfig {
  static const String projectName = '$PROJECT_NAME';
  static const String projectCreatedDate = '$(date +"%Y-%m-%d")';
}
EOF

print_success "Fichier de configuration créé avec le nom du projet : $PROJECT_NAME"

# Remplacer toutes les occurrences de "yeb_app_template" par le nom du projet
print_header "Renommage du projet dans tous les fichiers"

# Fonction pour remplacer dans les fichiers
replace_in_files() {
    find_cmd="find . -type f -not -path '*/\.*' -not -path '*/build/*' -not -path '*/\node_modules/*' -not -path '*/.dart_tool/*' -not -path '*/\venv/*' -not -path '*/.github/*' -not -path '*/init_project.*'"
    
    # Extensions textuelles courantes
    for ext in md dart py yaml yml json txt sh bat toml html css js iml; do
        files=$(eval "$find_cmd -name '*.$ext'" | xargs grep -l "yeb_app_template" 2>/dev/null)
        if [ -n "$files" ]; then
            echo "$files" | while read file; do
                echo "Renommage dans $file"
                sed -i "s/yeb_app_template/$PROJECT_NAME/g" "$file"
            done
        fi
    done
}

# Fonction pour renommer les fichiers contenant "yeb_app_template" dans leur nom
rename_files() {
    echo "Recherche de fichiers contenant 'yeb_app_template' dans leur nom..."
    find . -name "*yeb_app_template*" -not -path "*/\.*" -not -path "*/build/*" -not -path "*/\node_modules/*" -not -path "*/.dart_tool/*" -not -path "*/\venv/*" | while read file; do
        new_file=$(echo "$file" | sed "s/yeb_app_template/$PROJECT_NAME/g")
        if [ "$file" != "$new_file" ]; then
            echo "Renommage du fichier: $file -> $new_file"
            mv "$file" "$new_file"
        fi
    done
}

replace_in_files
rename_files
print_success "Renommage terminé"

# Mettre à jour le pubspec.yaml pour Flutter
if [ -f "flutter_app/pubspec.yaml" ]; then
    echo "Mise à jour de pubspec.yaml..."
    sed -i "s/name: flutter_app/name: ${PROJECT_NAME}_flutter/g" flutter_app/pubspec.yaml
    sed -i "s/description: A new Flutter project./description: $PROJECT_NAME - Application Flutter avec backend Python/g" flutter_app/pubspec.yaml
    print_success "pubspec.yaml mis à jour"
fi

# Installer les dépendances
print_header "Installation des dépendances"

# Choix du script d'installation selon la plateforme
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]; then
    # Windows
    echo "Système Windows détecté"
    if [ -f "scripts/setup.bat" ]; then
        echo "Exécution de scripts/setup.bat..."
        cmd.exe /c "scripts\\setup.bat"
        print_success "Configuration Windows terminée"
    else
        print_error "Le script setup.bat n'a pas été trouvé"
    fi
else
    # Linux/macOS
    echo "Système Unix détecté (Linux/macOS)"
    if [ -f "scripts/setup.sh" ]; then
        echo "Exécution de scripts/setup.sh..."
        chmod +x scripts/setup.sh
        ./scripts/setup.sh
        print_success "Configuration Unix terminée"
    else
        print_error "Le script setup.sh n'a pas été trouvé"
    fi
fi

# Installation des dépendances Flutter
if command -v flutter &> /dev/null; then
    echo "Installation des dépendances Flutter..."
    (cd flutter_app && flutter pub get)
    print_success "Dépendances Flutter installées"
else
    print_warning "Flutter non trouvé dans le PATH. Veuillez l'installer manuellement."
fi

# Installation des dépendances Python si Poetry est installé
if command -v poetry &> /dev/null; then
    echo "Installation des dépendances Python pour le backend local..."
    (cd python_backend && poetry install)
    echo "Installation des dépendances Python pour le backend web..."
    (cd web_backend && poetry install)
    print_success "Dépendances Python installées"
else
    print_warning "Poetry non trouvé. Veuillez installer Poetry et exécuter manuellement 'poetry install' dans les dossiers python_backend et web_backend."
fi

# Préparation du premier commit Git
print_header "Configuration Git"
if [ -d .git ]; then
    echo "Préparation du premier commit..."
    git add .
    git commit -m "🚀 Initialisation du projet $PROJECT_NAME à partir du template yeb_app_template"
    print_success "Premier commit créé"
else
    print_warning "Ce dossier n'est pas un dépôt Git. Veuillez initialiser Git manuellement."
fi

# Instructions finales
print_header "Projet initialisé avec succès !"
echo "Votre projet '$PROJECT_NAME' est maintenant configuré et prêt à l'emploi."
echo ""
echo "Prochaines étapes recommandées :"
echo "1. Consultez la documentation dans le dossier 'docs/' pour plus d'informations"
echo "2. Lancez votre application en développement avec './run_dev.sh' (Unix) ou 'run_dev.bat' (Windows)"
echo "3. Pour le développement web, utilisez './start_web_dev.sh' (Unix) ou 'start_web_dev.bat' (Windows)"
echo ""
echo "Si vous utilisez VS Code avec GitHub Copilot, demandez à l'assistant de 'lire la documentation dans docs/' pour vous aider à personnaliser davantage votre projet."
echo ""
print_success "Bon développement !"
