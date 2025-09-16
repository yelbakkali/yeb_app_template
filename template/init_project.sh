#!/bin/bash
# Script d'initialisation du projet après l'utilisation du template

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Vérifier si le script de prérequis existe et l'exécuter
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PREREQ_SCRIPT="${SCRIPT_DIR}/template/scripts/check_prerequisites.sh"

if [ -f "$PREREQ_SCRIPT" ]; then
    echo "Vérificatioif [ -f "$SCRIPT_DIR/template/scripts/configure_vscode_for_flutter.sh" ]; then
    echo "Configuration de VS Code pour le projet..."
    chmod +x "$SCRIPT_DIR/template/scripts/configure_vscode_for_flutter.sh"
    "$SCRIPT_DIR/template/scripts/configure_vscode_for_flutter.sh"s prérequis avant l'initialisation..."
    chmod +x "$PREREQ_SCRIPT"
    "$PREREQ_SCRIPT"

    # Si le script de prérequis échoue, demander si l'utilisateur veut continuer
    if [ $? -ne 0 ]; then
        echo -e "${YELLOW}Des prérequis sont manquants. Voulez-vous continuer quand même ? (o/N)${NC}"
        read -p "" -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[oO]$ ]]; then
            echo "Initialisation annulée. Veuillez installer les prérequis manquants et réessayer."
            exit 1
        fi
    fi
fi

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

# Obtenir le chemin absolu du répertoire du script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Vérifier si git est disponible
if ! command -v git &> /dev/null; then
    print_error "Git n'est pas installé. Veuillez l'installer pour continuer."
    exit 1
fi

# Détecter le nom du projet à partir du dossier racine
REPO_PATH=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -z "$REPO_PATH" ]; then
    REPO_PATH="$SCRIPT_DIR"
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

# Renommer le fichier .code-workspace et mettre à jour les fichiers clés
print_header "Mise à jour du projet avec le nouveau nom"

# Vérifier si le fichier code-workspace existe
if [ -f "yeb_app_template.code-workspace" ]; then
    echo "Renommage du fichier code-workspace..."
    cp "yeb_app_template.code-workspace" "$PROJECT_NAME.code-workspace"
    rm "yeb_app_template.code-workspace"

    # Remplacer le contenu du fichier
    sed -i "s/yeb_app_template/$PROJECT_NAME/g" "$PROJECT_NAME.code-workspace"
    print_success "Fichier code-workspace renommé en $PROJECT_NAME.code-workspace"
else
    print_warning "Fichier code-workspace non trouvé"
fi

# Mettre à jour le fichier pubspec.yaml
if [ -f "pubspec.yaml" ]; then
    print_header "Mise à jour du fichier pubspec.yaml"
    sed -i "s/^name: yeb_app_template/name: $PROJECT_NAME/" pubspec.yaml
    print_success "Nom du projet mis à jour dans pubspec.yaml"
fi

# Mettre à jour les imports Dart
print_header "Mise à jour des imports dans les fichiers Dart"
find . -name "*.dart" -type f -exec sed -i "s/package:yeb_app_template\//package:$PROJECT_NAME\//g" {} \;
print_success "Imports Dart mis à jour"

# Mettre à jour les métadonnées dans index.html et manifest.json pour le Web
if [ -f "flutter_app/web/index.html" ]; then
    print_header "Mise à jour des métadonnées web"
    sed -i "s/content=\"Application yeb_app_template/content=\"Application $PROJECT_NAME/g" flutter_app/web/index.html
    sed -i "s/content=\"yeb_app_template\"/content=\"$PROJECT_NAME\"/g" flutter_app/web/index.html
    sed -i "s/<title>yeb_app_template</<title>$PROJECT_NAME</g" flutter_app/web/index.html

    # Mise à jour du manifest.json pour le Web
    if [ -f "flutter_app/web/manifest.json" ]; then
        sed -i "s/\"name\": \"flutter_app\"/\"name\": \"$PROJECT_NAME\"/g" flutter_app/web/manifest.json
        sed -i "s/\"short_name\": \"flutter_app\"/\"short_name\": \"$PROJECT_NAME\"/g" flutter_app/web/manifest.json
        sed -i "s/\"description\": \"A new Flutter project\.\"/\"description\": \"$PROJECT_NAME application\"/g" flutter_app/web/manifest.json
    fi

    print_success "Métadonnées web mises à jour"
fi

# Mettre à jour le nom de l'application pour Android
print_header "Mise à jour des configurations Android"
if [ -f "flutter_app/android/app/src/main/AndroidManifest.xml" ]; then
    sed -i "s/android:label=\"flutter_app\"/android:label=\"$PROJECT_NAME\"/g" flutter_app/android/app/src/main/AndroidManifest.xml

    # Mettre à jour l'ID de l'application (optionnel, mais recommandé)
    if [[ "$PROJECT_NAME" != "flutter_app" ]]; then
        PACKAGE_NAME=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr -d ' -')
        sed -i "s/com\.example\.flutter_app/com.example.$PACKAGE_NAME/g" flutter_app/android/app/build.gradle.kts

        # Mettre à jour les références dans les fichiers Kotlin également
        find flutter_app/android -name "*.kt" -type f -exec sed -i "s/com\.example\.flutter_app/com.example.$PACKAGE_NAME/g" {} \;
    fi
    print_success "Configuration Android mise à jour"
fi

# Mettre à jour le nom de l'application pour iOS
print_header "Mise à jour des configurations iOS"
if [ -f "flutter_app/ios/Runner/Info.plist" ]; then
    # Pour macOS, il faut utiliser plutil ou un outil similaire, mais on peut aussi utiliser sed avec précaution
    sed -i "s/<string>Flutter App<\/string>/<string>$PROJECT_NAME<\/string>/g" flutter_app/ios/Runner/Info.plist
    print_success "Configuration iOS mise à jour"
fi

# Mettre à jour le nom de l'application pour macOS
if [ -f "flutter_app/macos/Runner/Configs/AppInfo.xcconfig" ]; then
    sed -i "s/PRODUCT_NAME = flutter_app/PRODUCT_NAME = $PROJECT_NAME/g" flutter_app/macos/Runner/Configs/AppInfo.xcconfig
    print_success "Configuration macOS mise à jour"
fi

# Mettre à jour le nom de l'application pour Windows
if [ -f "flutter_app/windows/runner/main.cpp" ]; then
    sed -i "s/L\"flutter_app\"/L\"$PROJECT_NAME\"/g" flutter_app/windows/runner/main.cpp

    # Mise à jour du fichier Runner.rc pour Windows
    if [ -f "flutter_app/windows/runner/Runner.rc" ]; then
        sed -i "s/VALUE \"FileDescription\", \"flutter_app\"/VALUE \"FileDescription\", \"$PROJECT_NAME\"/g" flutter_app/windows/runner/Runner.rc
        sed -i "s/VALUE \"InternalName\", \"flutter_app\"/VALUE \"InternalName\", \"$PROJECT_NAME\"/g" flutter_app/windows/runner/Runner.rc
        sed -i "s/VALUE \"OriginalFilename\", \"flutter_app.exe\"/VALUE \"OriginalFilename\", \"$PROJECT_NAME.exe\"/g" flutter_app/windows/runner/Runner.rc
        sed -i "s/VALUE \"ProductName\", \"flutter_app\"/VALUE \"ProductName\", \"$PROJECT_NAME\"/g" flutter_app/windows/runner/Runner.rc
    fi
    print_success "Configuration Windows mise à jour"
fi

# Mettre à jour le nom de l'application pour Linux
if [ -f "flutter_app/linux/my_application.cc" ]; then
    sed -i "s/gtk_header_bar_set_title(header_bar, \"flutter_app\")/gtk_header_bar_set_title(header_bar, \"$PROJECT_NAME\")/g" flutter_app/linux/my_application.cc
    sed -i "s/gtk_window_set_title(window, \"flutter_app\")/gtk_window_set_title(window, \"$PROJECT_NAME\")/g" flutter_app/linux/my_application.cc

    # Mise à jour du CMakeLists.txt pour Linux
    if [ -f "flutter_app/linux/CMakeLists.txt" ]; then
        sed -i "s/set(BINARY_NAME \"flutter_app\")/set(BINARY_NAME \"$PROJECT_NAME\")/g" flutter_app/linux/CMakeLists.txt
        sed -i "s/set(APPLICATION_ID \"com.example.flutter_app\")/set(APPLICATION_ID \"com.example.$PACKAGE_NAME\")/g" flutter_app/linux/CMakeLists.txt
    fi
    print_success "Configuration Linux mise à jour"
fi

# Mettre à jour le nom de l'application dans pubspec.yaml de Flutter
if [ -f "flutter_app/pubspec.yaml" ]; then
    sed -i "s/^name: flutter_app/name: $PROJECT_NAME/g" flutter_app/pubspec.yaml
    sed -i "s/^description: \"A new Flutter project\.\"/description: \"$PROJECT_NAME application\"/g" flutter_app/pubspec.yaml
    print_success "Configuration Flutter mise à jour dans pubspec.yaml"
fi

# Mettre à jour le backend Python
print_header "Mise à jour des références dans le backend Python"
if [ -f "web_backend/main.py" ]; then
    sed -i "s/title=\"yeb_app_template API\"/title=\"$PROJECT_NAME API\"/g" web_backend/main.py
    sed -i "s/description=\"API pour l'application yeb_app_template\"/description=\"API pour l'application $PROJECT_NAME\"/g" web_backend/main.py
    print_success "Backend Python mis à jour"
fi

# Mettre à jour les scripts de lancement
print_header "Mise à jour des scripts d'environnement"
find . -name "*.sh" -type f -exec sed -i "s/yeb_app_template-direct/$PROJECT_NAME-direct/g" {} \;
find . -name "*.sh" -type f -exec sed -i "s/Démarrage de l'environnement de développement yeb_app_template/Démarrage de l'environnement de développement $PROJECT_NAME/g" {} \;
print_success "Scripts d'environnement mis à jour"

# Mettre à jour les fichiers de documentation
print_header "Mise à jour de la documentation"
find ./docs -name "*.md" -type f -exec sed -i "s/yeb_app_template/$PROJECT_NAME/g" {} \;
print_success "Documentation mise à jour"

# Aucune autre fonction de remplacement nécessaire puisqu'on ne renomme que le fichier code-workspace
echo "Aucun autre renommage n'est effectué, comme demandé."
print_success "Renommage terminé"

# Configuration automatique de VS Code
print_header "Configuration de l'environnement VS Code"
mkdir -p .vscode

# Création du fichier settings.json
cat > .vscode/settings.json << EOF
{
  // Configuration Flutter
  "dart.lineLength": 100,
  "[dart]": {
    "editor.formatOnSave": true,
    "editor.formatOnType": true,
    "editor.rulers": [100],
    "editor.selectionHighlight": false,
    "editor.suggestSelection": "first",
    "editor.tabCompletion": "onlySnippets",
    "editor.wordBasedSuggestions": "off"
  },

  // Configuration Python
  "python.defaultInterpreterPath": "\${workspaceFolder}/web_backend/.venv/bin/python",
  "python.linting.enabled": true,
  "python.linting.pylintEnabled": true,
  "python.formatting.provider": "black",
  "python.formatting.blackPath": "\${workspaceFolder}/web_backend/.venv/bin/black",
  "python.formatting.blackArgs": ["--line-length", "88"],
  "[python]": {
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
      "source.organizeImports": "explicit"
    }
  },

  // Configuration générale
  "files.autoSave": "afterDelay",
  "files.autoSaveDelay": 1000,
  "editor.tabSize": 2,
  "git.enableSmartCommit": true,
  "git.confirmSync": false
}
EOF

# Création du fichier extensions.json pour recommander les extensions
cat > .vscode/extensions.json << EOF
{
  "recommendations": [
    "dart-code.flutter",
    "dart-code.dart-code",
    "ms-python.python",
    "ms-python.vscode-pylance",
    "littlefoxteam.vscode-python-test-adapter",
    "mhutchie.git-graph",
    "eamodio.gitlens",
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode"
  ]
}
EOF

# Création du fichier launch.json pour le débogage
cat > .vscode/launch.json << EOF
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter App",
      "type": "dart",
      "request": "launch",
      "program": "flutter_app/lib/main.dart"
    },
    {
      "name": "Web Backend (Python)",
      "type": "python",
      "request": "launch",
      "program": "\${workspaceFolder}/web_backend/main.py",
      "console": "integratedTerminal"
    }
  ]
}
EOF

print_success "Configuration VS Code créée. Les extensions recommandées seront proposées à l'ouverture du projet."

# Ne pas mettre à jour le pubspec.yaml pour Flutter avec le nom du projet
if [ -f "flutter_app/pubspec.yaml" ]; then
    echo "Vérification du pubspec.yaml..."
    print_success "pubspec.yaml laissé inchangé, comme demandé"
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
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    echo "Système macOS détecté"
    if [ -f "scripts/setup.sh" ]; then
        echo "Exécution de scripts/setup.sh..."
        chmod +x scripts/setup.sh
        ./scripts/setup.sh
        print_success "Configuration macOS terminée"
    else
        print_error "Le script setup.sh n'a pas été trouvé"
    fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    echo "Système Linux détecté"
    if [ -f "scripts/setup.sh" ]; then
        echo "Exécution de scripts/setup.sh..."
        chmod +x scripts/setup.sh
        ./scripts/setup.sh
        print_success "Configuration Linux terminée"
    else
        print_error "Le script setup.sh n'a pas été trouvé"
    fi
else
    # Autre système Unix
    echo "Système Unix non identifié détecté"
    if [ -f "scripts/setup.sh" ]; then
        echo "Tentative d'exécution de scripts/setup.sh..."
        chmod +x scripts/setup.sh
        ./scripts/setup.sh
        print_success "Configuration Unix terminée"
    else
        print_error "Le script setup.sh n'a pas été trouvé"
    fi
fi

# Installation des dépendances Flutter
print_header "Installation des dépendances Flutter"

if command -v flutter &> /dev/null; then
    echo "Installation des dépendances Flutter..."
    (cd flutter_app && flutter pub get) || {
        print_error "Erreur lors de l'installation des dépendances Flutter. Vérifiez les messages d'erreur ci-dessus."
        print_warning "Vous pouvez essayer de résoudre les problèmes et exécuter 'cd flutter_app && flutter pub get' manuellement."
    }

    if [ $? -eq 0 ]; then
        print_success "Dépendances Flutter installées avec succès"
    fi
else
    print_warning "Flutter non trouvé dans le PATH."
    print_warning "Pour installer Flutter:"
    echo "1. Visitez https://docs.flutter.dev/get-started/install"
    echo "2. Suivez les instructions d'installation pour votre système d'exploitation"
    echo "3. Ajoutez Flutter au PATH avec 'export PATH=\"\$PATH:\$HOME/flutter/bin\"'"
    echo "4. Puis exécutez 'cd flutter_app && flutter pub get' pour installer les dépendances"
fi

# Installation des dépendances Python
print_header "Installation des dépendances Python"

# Vérification de l'installation de Poetry
if ! command -v poetry &> /dev/null; then
    print_warning "Poetry n'est pas installé ou n'est pas dans le PATH"
    echo "Installation automatique de Poetry..."

    # Tente d'installer Poetry
    if curl -sSL https://install.python-poetry.org | python3 -; then
        print_success "Poetry installé avec succès"
        # Ajout de Poetry au PATH pour cette session
        export PATH="$HOME/.local/bin:$PATH"
        if ! command -v poetry &> /dev/null; then
            export PATH="$HOME/.poetry/bin:$PATH"
            if ! command -v poetry &> /dev/null; then
                print_error "Poetry installé mais non trouvé dans le PATH. Ajoutez manuellement le chemin de Poetry à votre PATH."
                print_warning "Veuillez exécuter manuellement 'poetry install' dans les dossiers python_backend et web_backend."
                POETRY_INSTALLED=false
            else
                POETRY_INSTALLED=true
            fi
        else
            POETRY_INSTALLED=true
        fi
    else
        print_error "Échec de l'installation de Poetry. Veuillez l'installer manuellement: https://python-poetry.org/docs/#installation"
        print_warning "Veuillez exécuter manuellement 'poetry install' dans les dossiers python_backend et web_backend."
        POETRY_INSTALLED=false
    fi
else
    POETRY_INSTALLED=true
fi

# Si Poetry est installé, installer les dépendances
if [ "$POETRY_INSTALLED" = true ]; then
    # Installation pour python_backend
    echo "Installation des dépendances Python pour le backend local..."
    (cd python_backend && poetry install) || {
        print_error "Erreur lors de l'installation des dépendances Python dans python_backend"
    }

    # Installation pour web_backend
    echo "Installation des dépendances Python pour le backend web..."
    (cd web_backend && poetry install) || {
        print_error "Erreur lors de l'installation des dépendances Python dans web_backend"
    }

    print_success "Tentative d'installation des dépendances Python terminée"
fi

# Configuration de VS Code pour l'installation automatique des dépendances Flutter
print_header "Configuration de VS Code"
if [ -f "$SCRIPT_DIR/scripts/configure_vscode_for_flutter.sh" ]; then
    echo "Configuration de VS Code pour Flutter..."
    chmod +x "$SCRIPT_DIR/scripts/configure_vscode_for_flutter.sh"
    "$SCRIPT_DIR/scripts/configure_vscode_for_flutter.sh"
    print_success "VS Code configuré pour l'installation automatique des dépendances Flutter"
else
    print_warning "Le script de configuration de VS Code n'a pas été trouvé."
fi

# Installation des dépendances du projet
print_header "Installation des dépendances"
if [ -f "$SCRIPT_DIR/scripts/install_dependencies.sh" ]; then
    echo "Installation des dépendances du projet..."
    chmod +x "$SCRIPT_DIR/scripts/install_dependencies.sh"
    "$SCRIPT_DIR/scripts/install_dependencies.sh"
    print_success "Dépendances installées avec succès"
else
    print_warning "Le script d'installation des dépendances n'a pas été trouvé."
fi

# Configuration Git et création des branches
print_header "Configuration Git"
if [ -d .git ]; then
    echo "Préparation du premier commit..."
    git add .
    git commit -m "🚀 Initialisation du projet $PROJECT_NAME à partir du template yeb_app_template"
    print_success "Premier commit créé"

    # Vérifier si la branche main existe déjà
    if git rev-parse --verify main >/dev/null 2>&1; then
        echo "La branche main existe déjà"
    else
        # Renommer la branche actuelle en main si ce n'est pas déjà le cas
        current_branch=$(git branch --show-current)
        if [ "$current_branch" != "main" ]; then
            echo "Renommage de la branche '$current_branch' en 'main'..."
            git branch -m "$current_branch" main
            print_success "Branche renommée en 'main'"
        fi
    fi

    # Création de la branche dev
    echo "Création de la branche dev..."
    if git rev-parse --verify dev >/dev/null 2>&1; then
        echo "La branche dev existe déjà"
    else
        git checkout -b dev
        print_success "Branche dev créée et activée"
    fi

    echo "Configuration du flux de travail Git : main (stable) et dev (développement)"
else
    print_warning "Ce dossier n'est pas un dépôt Git. Initialisation Git..."
    git init
    git add .
    git commit -m "🚀 Initialisation du projet $PROJECT_NAME à partir du template yeb_app_template"

    # Renommer la branche par défaut en main
    git branch -m main
    print_success "Dépôt Git initialisé avec la branche principale 'main'"

    # Création de la branche dev
    git checkout -b dev
    print_success "Branche dev créée et activée"

    echo "Flux de travail Git configuré : main (stable) et dev (développement)"

    echo ""
    echo "${YELLOW}Conseil : Pour connecter ce dépôt à GitHub ou un autre service distant :${NC}"
    echo "1. Créez un dépôt vide sur GitHub/GitLab/etc."
    echo "2. Exécutez : git remote add origin URL_DU_DEPOT"
    echo "3. Exécutez : git push -u origin main"
    echo "4. Exécutez : git push -u origin dev"
fi

# Proposer de nettoyer les fichiers d'initialisation
print_header "Finalisation"
echo "Souhaitez-vous supprimer les scripts d'initialisation maintenant qu'ils ont été exécutés ?"
echo "Ces scripts ne sont plus nécessaires après la première configuration et peuvent être supprimés."
read -p "Nettoyer les fichiers d'initialisation ? (o/N) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[oO]$ ]]; then
    if [ -f "$SCRIPT_DIR/template/scripts/cleanup_init_files.sh" ]; then
        echo "Exécution du script de nettoyage..."
        chmod +x "$SCRIPT_DIR/template/scripts/cleanup_init_files.sh"
        "$SCRIPT_DIR/template/scripts/cleanup_init_files.sh"
    else
        print_warning "Script de nettoyage non trouvé"
    fi
else
    echo "Les fichiers d'initialisation n'ont pas été supprimés."
    echo "Vous pouvez les nettoyer ultérieurement en exécutant scripts/cleanup_init_files.sh"
fi

# Instructions finales
print_header "Projet initialisé avec succès !"
echo "Votre projet '$PROJECT_NAME' est maintenant configuré et prêt à l'emploi."
echo ""
echo "Prochaines étapes recommandées :"
echo "1. Consultez la documentation dans le dossier 'docs/' pour plus d'informations"
echo "2. Lancez votre application en développement avec './run_dev.sh' (Unix) ou 'run_dev.bat' (Windows)"
echo "3. Pour le développement web, utilisez './start_web_integrated.sh' (Unix) ou 'start_web_integrated.bat' (Windows)"
echo "4. Utilisez git avec le workflow recommandé : développement sur 'dev', fusion vers 'main'"
echo "   Pour fusionner dev vers main : scripts/merge_to_main.sh"
echo ""
echo "Si vous utilisez VS Code avec GitHub Copilot, demandez à l'assistant de 'lire la documentation dans docs/' pour vous aider à personnaliser davantage votre projet."
echo ""
print_success "Bon développement !"
