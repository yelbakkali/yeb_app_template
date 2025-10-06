#!/bin/bash

# ==========================================================================
# RÉFÉRENCES CROISÉES:
# - Ce fichier est référencé dans: [template/utils/setup.sh:58]
# ==========================================================================

# Script d'installation des dépendances pour macOS
# Ce script installe tous les outils nécessaires pour le développement du projet yeb_app_template sous macOS

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

# Vérifier si le script s'exécute avec les droits nécessaires
if [[ $EUID -eq 0 ]]; then
    echo_warning "Ce script ne devrait pas être exécuté en tant que root/sudo."
    echo_info "Les commandes nécessitant des privilèges élevés vous demanderont votre mot de passe."
    read -p "Voulez-vous continuer? (o/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Oo]$ ]]; then
        exit 1
    fi
fi

echo_info "Démarrage du script d'installation pour macOS..."

# Vérifier si Homebrew est installé, sinon l'installer
if ! command -v brew &> /dev/null; then
    echo_info "Installation de Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Vérifier la réussite de l'installation
    if ! command -v brew &> /dev/null; then
        echo_error "L'installation de Homebrew a échoué. Veuillez l'installer manuellement."
        exit 1
    fi

    # Configurer le PATH pour Homebrew si nécessaire
    if [[ "$(uname -m)" == "arm64" ]]; then
        # Pour Apple Silicon (M1, M2...)
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        # Pour Intel
        echo 'eval "$(/usr/local/bin/brew shellenv)"' >> $HOME/.zprofile
        eval "$(/usr/local/bin/brew shellenv)"
    fi

    echo_success "Homebrew installé avec succès."
else
    echo_info "Homebrew est déjà installé."
    brew update
fi

# Installation de Git
echo_info "Vérification de l'installation de Git..."
if ! command -v git &> /dev/null; then
    echo_info "Installation de Git..."
    brew install git
    echo_success "Git installé avec succès."
else
    echo_info "Git est déjà installé."
fi

# Installation de Python
echo_info "Vérification de l'installation de Python..."
if ! command -v python3 &> /dev/null; then
    echo_info "Installation de Python 3..."
    brew install python
    echo_success "Python installé avec succès."
else
    echo_info "Python est déjà installé."
fi

# Installation de Poetry
echo_info "Vérification de l'installation de Poetry..."
if ! command -v poetry &> /dev/null; then
    echo_info "Installation de Poetry..."
    curl -sSL https://install.python-poetry.org | python3 -

    # Ajouter Poetry au PATH
    POETRY_PATH="$HOME/.local/bin"
    if [[ -d "$POETRY_PATH" ]]; then
        if ! echo "$PATH" | grep -q "$POETRY_PATH"; then
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zprofile
            export PATH="$HOME/.local/bin:$PATH"
        fi
    fi

    # Vérifier la réussite de l'installation
    if ! command -v poetry &> /dev/null; then
        echo_error "L'installation de Poetry a échoué. Veuillez l'installer manuellement."
        echo_info "Vous pouvez l'installer avec: curl -sSL https://install.python-poetry.org | python3 -"
    else
        echo_success "Poetry installé avec succès."
    fi
else
    echo_info "Poetry est déjà installé."
fi

# Installation de Flutter
echo_info "Vérification de l'installation de Flutter..."
if ! command -v flutter &> /dev/null; then
    echo_info "Installation de Flutter..."

    # Créer un dossier pour Flutter
    if [ ! -d "$HOME/development" ]; then
        mkdir -p "$HOME/development"
    fi

    # Télécharger Flutter
    echo_info "Téléchargement de Flutter..."
    cd "$HOME/development"
    git clone https://github.com/flutter/flutter.git -b stable

    # Ajouter Flutter au PATH
    FLUTTER_PATH="$HOME/development/flutter/bin"
    if ! echo "$PATH" | grep -q "$FLUTTER_PATH"; then
        echo 'export PATH="$HOME/development/flutter/bin:$PATH"' >> ~/.zprofile
        export PATH="$HOME/development/flutter/bin:$PATH"
    fi

    # Accepter les licences Android SDK
    flutter doctor --android-licenses

    # Activer la prise en charge du développement web
    flutter config --enable-web

    echo_success "Flutter installé avec succès."
else
    echo_info "Flutter est déjà installé."
    flutter config --enable-web
    flutter upgrade
fi

# Installation de VS Code
echo_info "Vérification de l'installation de VS Code..."
if ! command -v code &> /dev/null; then
    echo_info "Installation de Visual Studio Code..."
    brew install --cask visual-studio-code
    echo_success "VS Code installé avec succès."
else
    echo_info "Visual Studio Code est déjà installé."
fi

# Installation des extensions VS Code recommandées
echo_info "Installation des extensions VS Code recommandées..."
code --install-extension ms-python.python
code --install-extension ms-python.vscode-pylance
code --install-extension dart-code.flutter
code --install-extension dart-code.dart-code
code --install-extension github.vscode-pull-request-github

# Installation de Google Chrome (pour Flutter web)
echo_info "Vérification de l'installation de Google Chrome..."
if ! ls /Applications/Google\ Chrome.app &> /dev/null; then
    echo_info "Installation de Google Chrome..."
    brew install --cask google-chrome
    echo_success "Google Chrome installé avec succès."
else
    echo_info "Google Chrome est déjà installé."
fi

# Configuration Poetry pour shared_python
echo_info "Configuration de l'environnement Poetry pour shared_python..."
if [ -d "shared_python" ]; then
    cd shared_python
    if command -v poetry &> /dev/null; then
        poetry install
        POETRY_ENV_PATH=$(poetry env info --path)
        if [ -n "$POETRY_ENV_PATH" ]; then
            echo_success "Environnement Poetry configuré dans: $POETRY_ENV_PATH"

            # Mettre à jour settings.json pour pointer vers l'environnement Poetry
            mkdir -p ../.vscode
            if [ -f "../.vscode/settings.json" ]; then
                # Utiliser la syntaxe sed compatible avec macOS
                # Extraire la version de Python (3.x)
                PYTHON_VERSION=$(ls $POETRY_ENV_PATH/lib/ | grep python3 | head -n 1)

                # Mettre à jour le chemin de l'interpréteur Python
                sed -i '' "s|\"python.defaultInterpreterPath\": \".*\"|\"python.defaultInterpreterPath\": \"$POETRY_ENV_PATH/bin/python\"|g" ../.vscode/settings.json
                sed -i '' "s|\"python.analysis.extraPaths\": \\[.*\\]|\"python.analysis.extraPaths\": [\"$POETRY_ENV_PATH/lib/$PYTHON_VERSION/site-packages\"]|g" ../.vscode/settings.json

                echo_success "Configuration VS Code mise à jour pour utiliser l'environnement Poetry"
            else
                echo_warning "Fichier settings.json non trouvé. La configuration VS Code n'a pas été mise à jour."
            fi
        else
            echo_error "Impossible de déterminer le chemin de l'environnement Poetry"
        fi
    else
        echo_error "Poetry n'est pas disponible dans le PATH actuel."
        echo_info "Essayez de redémarrer votre terminal ou d'exécuter 'source ~/.zprofile'."
    fi
    cd ..
else
    echo_warning "Dossier shared_python non trouvé. La configuration Poetry a été ignorée."
fi

# Gestion des spécificités macOS pour le développement Flutter
echo_info "Configuration des spécificités macOS pour Flutter..."

# Installer les dépendances iOS (si Xcode est installé)
if [ -d "/Applications/Xcode.app" ]; then
    echo_info "Xcode détecté, configuration des dépendances iOS..."

    # Vérifier si Ruby Gems est disponible
    if command -v gem &> /dev/null; then
        echo_info "Installation de CocoaPods..."
        sudo gem install cocoapods
        echo_success "CocoaPods installé avec succès."
    else
        echo_warning "Ruby Gems non trouvé. Veuillez installer CocoaPods manuellement."
    fi

    # Vérifier l'installation du simulateur iOS
    xcrun simctl list devices | grep -q "iPhone"
    if [ $? -eq 0 ]; then
        echo_info "Simulateur iOS détecté."
    else
        echo_warning "Simulateur iOS non détecté. Exécutez 'open -a Simulator' pour l'installer."
    fi

    # Créer un wrapper pour iOS
    mkdir -p scripts
    cat > scripts/flutter_wrapper_macos.sh << 'EOF'
#!/bin/bash
# Script wrapper pour faciliter le développement Flutter sur macOS

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Fonction pour afficher le menu
show_menu() {
    echo -e "${GREEN}=== Flutter Development Helper ===${NC}"
    echo "1. Lancer l'application sur Chrome"
    echo "2. Lancer l'application sur le Simulateur iOS"
    echo "3. Lancer l'application sur Android Emulator"
    echo "4. Construire l'application web"
    echo "5. Construire l'application iOS"
    echo "6. Construire l'application Android"
    echo "7. Nettoyer le projet"
    echo "8. Mettre à jour les dépendances"
    echo "q. Quitter"
    echo
    read -p "Choix: " choice

    case $choice in
        1) flutter run -d chrome ;;
        2) open -a Simulator && flutter run -d ios ;;
        3) flutter run -d android ;;
        4) flutter build web ;;
        5) flutter build ios ;;
        6) flutter build apk ;;
        7) flutter clean ;;
        8) flutter pub get ;;
        q) exit 0 ;;
        *) echo -e "${YELLOW}Choix invalide${NC}" ;;
    esac

    echo
    read -p "Appuyez sur Entrée pour continuer..."
    clear
    show_menu
}

# Vérifier si on est dans un projet Flutter
if [ ! -f "pubspec.yaml" ]; then
    cd flutter_app || {
        echo "Impossible de trouver le projet Flutter"
        exit 1
    }
fi

# Démarrer le menu
clear
show_menu
EOF

    chmod +x scripts/flutter_wrapper_macos.sh
    echo_success "Script wrapper Flutter pour macOS créé dans scripts/flutter_wrapper_macos.sh"
else
    echo_warning "Xcode n'est pas installé. Pour le développement iOS, installez Xcode depuis l'App Store."
fi

echo_success "Installation de base terminée avec succès!"

# Vérification et configuration Git
echo_info "Vérification de la configuration Git..."
if [ -f "../utils/git_config_helper.sh" ]; then
    chmod +x ../utils/git_config_helper.sh
    # Exécuter uniquement la partie de vérification de la configuration Git
    source ../utils/git_config_helper.sh
    check_git_config
    
    echo_info "Souhaitez-vous configurer un dépôt GitHub pour ce projet?"
    read -p "Configurer GitHub maintenant? (o/n) : " setup_github
    if [[ "$setup_github" =~ ^[oO]$ ]]; then
        # Exécuter la partie de configuration du dépôt GitHub
        setup_github_repository
    else
        echo_info "Vous pourrez configurer le dépôt GitHub plus tard avec:"
        echo_info "bash template/utils/git_config_helper.sh"
    fi
elif [ -f "template/utils/git_config_helper.sh" ]; then
    chmod +x template/utils/git_config_helper.sh
    # Exécuter uniquement la partie de vérification de la configuration Git
    source template/utils/git_config_helper.sh
    check_git_config
    
    echo_info "Souhaitez-vous configurer un dépôt GitHub pour ce projet?"
    read -p "Configurer GitHub maintenant? (o/n) : " setup_github
    if [[ "$setup_github" =~ ^[oO]$ ]]; then
        # Exécuter la partie de configuration du dépôt GitHub
        setup_github_repository
    else
        echo_info "Vous pourrez configurer le dépôt GitHub plus tard avec:"
        echo_info "bash template/utils/git_config_helper.sh"
    fi
else
    echo_warning "Script de configuration Git non trouvé. La configuration de Git et GitHub devra être effectuée manuellement."
fi

echo_success "Installation terminée avec succès!"

# Exécuter les tests d'installation si disponibles
if [ -f "../tests/test_installation.sh" ]; then
    echo_info "Exécution des tests d'installation..."
    bash ../tests/test_installation.sh
elif [ -f "template/tests/test_installation.sh" ]; then
    echo_info "Exécution des tests d'installation..."
    bash template/tests/test_installation.sh
fi

echo_info "Veuillez ouvrir un nouveau terminal ou exécuter 'source ~/.zprofile' pour appliquer les changements au PATH."
echo_info "Pour démarrer le développement web, exécutez: cd flutter_app && flutter run -d chrome"
echo_info "Pour accéder aux outils de développement Flutter, utilisez: ./scripts/flutter_wrapper_macos.sh"
