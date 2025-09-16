#!/bin/bash
# ==========================================================================
# RÉFÉRENCES CROISÉES:
# - Ce fichier est référencé dans: [template/init_project.sh:13]
# - Ce fichier est référencé dans: [template/setup_project.sh:40]
# ==========================================================================

# Script de vérification et d'installation des prérequis pour le template yeb_app_template
# Ce script détecte et installe automatiquement les outils nécessaires pour le projet

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

# Détection de la plateforme
print_header "Détection de la plateforme"
OS_TYPE="unknown"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS_TYPE="linux"
    echo "Système Linux détecté"
    # Détection de la distribution Linux
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$NAME
        echo "Distribution: $DISTRO"
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS_TYPE="macos"
    echo "Système macOS détecté"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]; then
    OS_TYPE="windows"
    echo "Système Windows détecté"
else
    OS_TYPE="unix"
    echo "Système Unix non identifié détecté"
fi

# Variables pour suivre l'état d'installation
MISSING_TOOLS=()
INSTALLED_TOOLS=()

# Fonction pour installer un outil sous Linux
install_tool_linux() {
    local tool_name=$1
    local package_name=${2:-$1}
    
    print_header "Installation de $tool_name"
    
    # Déterminer le gestionnaire de paquets
    if command -v apt-get &> /dev/null; then
        echo "Utilisation de apt-get..."
        sudo apt-get update && sudo apt-get install -y "$package_name"
    elif command -v yum &> /dev/null; then
        echo "Utilisation de yum..."
        sudo yum install -y "$package_name"
    elif command -v dnf &> /dev/null; then
        echo "Utilisation de dnf..."
        sudo dnf install -y "$package_name"
    elif command -v pacman &> /dev/null; then
        echo "Utilisation de pacman..."
        sudo pacman -Sy --noconfirm "$package_name"
    elif command -v zypper &> /dev/null; then
        echo "Utilisation de zypper..."
        sudo zypper install -y "$package_name"
    else
        print_error "Impossible de détecter le gestionnaire de paquets. Veuillez installer $tool_name manuellement."
        MISSING_TOOLS+=("$tool_name")
        return 1
    fi
    
    if [ $? -eq 0 ]; then
        print_success "$tool_name installé avec succès"
        INSTALLED_TOOLS+=("$tool_name")
        return 0
    else
        print_error "Échec de l'installation de $tool_name"
        MISSING_TOOLS+=("$tool_name")
        return 1
    fi
}

# Fonction pour installer un outil sous macOS
install_tool_macos() {
    local tool_name=$1
    local package_name=${2:-$1}
    
    print_header "Installation de $tool_name"
    
    # Vérifier si Homebrew est installé
    if ! command -v brew &> /dev/null; then
        echo "Homebrew n'est pas installé. Installation de Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        if [ $? -ne 0 ]; then
            print_error "Échec de l'installation de Homebrew. Veuillez installer $tool_name manuellement."
            MISSING_TOOLS+=("$tool_name")
            return 1
        fi
        
        # Ajouter Homebrew au PATH pour la session courante (selon l'architecture)
        if [ -f "/opt/homebrew/bin/brew" ]; then
            # Pour Apple Silicon (M1/M2)
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [ -f "/usr/local/bin/brew" ]; then
            # Pour Intel Mac
            eval "$(/usr/local/bin/brew shellenv)"
        else
            # Recherche du chemin de Homebrew
            brew_path=$(find /usr/local /opt -name brew -type f 2>/dev/null | head -n 1)
            if [ -n "$brew_path" ]; then
                brew_dir=$(dirname "$brew_path")
                export PATH="$brew_dir:$PATH"
            else
                print_warning "Homebrew installé mais introuvable dans les chemins habituels."
                print_warning "Vous devrez peut-être relancer le terminal et ce script."
                MISSING_TOOLS+=("$tool_name")
                return 1
            fi
        fi
    fi
    
    echo "Utilisation de Homebrew pour installer $tool_name..."
    brew install "$package_name"
    
    if [ $? -eq 0 ]; then
        print_success "$tool_name installé avec succès"
        INSTALLED_TOOLS+=("$tool_name")
        return 0
    else
        print_error "Échec de l'installation de $tool_name"
        MISSING_TOOLS+=("$tool_name")
        return 1
    fi
}

# Fonction pour vérifier et installer un outil
check_and_install_tool() {
    local tool_name=$1
    local command_name=${2:-$1}
    local package_name=${3:-$1}
    
    echo -n "Vérification de $tool_name... "
    if command -v "$command_name" &> /dev/null; then
        print_success "Installé"
        return 0
    else
        print_warning "Non installé"
        
        read -p "Voulez-vous installer $tool_name automatiquement? (o/N) " -n 1 -r
        echo
        
        if [[ ! $REPLY =~ ^[oO]$ ]]; then
            print_warning "$tool_name sera nécessaire pour le projet. Veuillez l'installer manuellement."
            MISSING_TOOLS+=("$tool_name")
            return 1
        fi
        
        # Installation selon la plateforme
        case $OS_TYPE in
            linux)
                install_tool_linux "$tool_name" "$package_name"
                ;;
            macos)
                install_tool_macos "$tool_name" "$package_name"
                ;;
            windows)
                print_error "L'installation automatique des outils sous Windows n'est pas prise en charge."
                print_warning "Veuillez installer $tool_name manuellement."
                MISSING_TOOLS+=("$tool_name")
                return 1
                ;;
            *)
                print_error "Plateforme non prise en charge pour l'installation automatique."
                print_warning "Veuillez installer $tool_name manuellement."
                MISSING_TOOLS+=("$tool_name")
                return 1
                ;;
        esac
    fi
}

# Vérification des prérequis principaux
print_header "Vérification des prérequis principaux"

# Git
check_and_install_tool "Git" "git"

# Python
if [[ "$OS_TYPE" == "macos" ]]; then
    # Sur macOS, on vérifie si python3 est disponible via Homebrew
    if command -v brew &> /dev/null; then
        if ! command -v python3 &> /dev/null; then
            print_header "Installation de Python via Homebrew"
            brew install python3
            
            if [ $? -eq 0 ]; then
                print_success "Python installé avec succès via Homebrew"
                INSTALLED_TOOLS+=("Python")
            else
                print_error "Échec de l'installation de Python via Homebrew"
                MISSING_TOOLS+=("Python")
            fi
        else
            print_success "Python est déjà installé"
            # Afficher la version
            python3 --version
        fi
    else
        # Si Homebrew n'est pas disponible, on vérifie simplement
        check_and_install_tool "Python" "python3" "python3"
    fi
else
    # Sur Linux et autres systèmes
    check_and_install_tool "Python" "python3" "python3"
fi

# Poetry
if ! command -v poetry &> /dev/null; then
    echo -n "Vérification de Poetry... "
    print_warning "Non installé"
    
    read -p "Voulez-vous installer Poetry automatiquement? (o/N) " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[oO]$ ]]; then
        print_header "Installation de Poetry"
        
        if [[ "$OS_TYPE" == "macos" ]] && command -v brew &> /dev/null; then
            echo "Installation de Poetry via Homebrew..."
            brew install poetry
        else
            echo "Installation de Poetry via le script officiel..."
            curl -sSL https://install.python-poetry.org | python3 -
        fi
        
        if [ $? -eq 0 ]; then
            # Ajouter Poetry au PATH pour cette session selon la plateforme
            if [[ "$OS_TYPE" == "macos" ]]; then
                # macOS peut avoir des chemins différents selon la méthode d'installation
                if command -v brew &> /dev/null; then
                    print_success "Poetry installé avec succès via Homebrew"
                else
                    export PATH="$HOME/.poetry/bin:$PATH"
                fi
            else
                # Linux et autres
                export PATH="$HOME/.local/bin:$PATH"
                export PATH="$HOME/.poetry/bin:$PATH"
            fi
            
            print_success "Poetry installé avec succès"
            INSTALLED_TOOLS+=("Poetry")
        else
            print_error "Échec de l'installation de Poetry"
            MISSING_TOOLS+=("Poetry")
        fi
    else
        print_warning "Poetry sera nécessaire pour le projet. Veuillez l'installer manuellement."
        MISSING_TOOLS+=("Poetry")
    fi
else
    print_success "Poetry est déjà installé"
    poetry --version
fi

# tmux (nécessaire pour les scripts de développement sous Linux/macOS)
if [[ "$OS_TYPE" == "linux" || "$OS_TYPE" == "macos" ]]; then
    if [[ "$OS_TYPE" == "macos" ]] && command -v brew &> /dev/null; then
        echo -n "Vérification de tmux... "
        if ! command -v tmux &> /dev/null; then
            print_warning "Non installé"
            
            read -p "Voulez-vous installer tmux via Homebrew? (o/N) " -n 1 -r
            echo
            
            if [[ $REPLY =~ ^[oO]$ ]]; then
                print_header "Installation de tmux"
                brew install tmux
                
                if [ $? -eq 0 ]; then
                    print_success "tmux installé avec succès"
                    INSTALLED_TOOLS+=("tmux")
                else
                    print_error "Échec de l'installation de tmux"
                    MISSING_TOOLS+=("tmux")
                fi
            else
                print_warning "tmux sera nécessaire pour les scripts de développement."
                MISSING_TOOLS+=("tmux")
            fi
        else
            print_success "Installé"
        fi
    else
        # Pour Linux ou macOS sans Homebrew
        check_and_install_tool "tmux" "tmux"
    fi
fi

# Flutter
if ! command -v flutter &> /dev/null; then
    echo -n "Vérification de Flutter... "
    print_warning "Non installé"
    
    # Sur macOS, proposer l'installation via Homebrew
    if [[ "$OS_TYPE" == "macos" ]] && command -v brew &> /dev/null; then
        print_header "Installation de Flutter"
        echo "Flutter peut être installé via Homebrew sur macOS."
        read -p "Voulez-vous installer Flutter via Homebrew? (o/N) " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[oO]$ ]]; then
            echo "Installation de Flutter via Homebrew..."
            brew install --cask flutter
            
            if [ $? -eq 0 ]; then
                print_success "Flutter installé avec succès"
                INSTALLED_TOOLS+=("Flutter")
                
                # Vérifier la version de Flutter
                FLUTTER_VERSION=$(flutter --version | head -n 1 | awk '{print $2}')
                echo "Version de Flutter : $FLUTTER_VERSION"
            else
                print_error "Échec de l'installation de Flutter via Homebrew"
                MISSING_TOOLS+=("Flutter")
                
                # Instructions pour installation manuelle
                echo "Pour installer Flutter manuellement sur macOS :"
                echo "1. Téléchargez Flutter depuis https://docs.flutter.dev/get-started/install/macos"
                echo "2. Extrayez l'archive dans l'emplacement de votre choix"
                echo "3. Ajoutez Flutter au PATH : export PATH=\"\$PATH:\$HOME/flutter/bin\""
            fi
        else
            # Instructions pour installation manuelle
            echo "Pour installer Flutter manuellement sur macOS :"
            echo "1. Téléchargez Flutter depuis https://docs.flutter.dev/get-started/install/macos"
            echo "2. Extrayez l'archive dans l'emplacement de votre choix"
            echo "3. Ajoutez Flutter au PATH : export PATH=\"\$PATH:\$HOME/flutter/bin\""
            MISSING_TOOLS+=("Flutter")
        fi
    else
        # Sur autres systèmes ou sans Homebrew
        print_header "Installation de Flutter"
        if [[ "$OS_TYPE" == "macos" ]]; then
            echo "Flutter doit être installé manuellement sur macOS :"
            echo "1. Téléchargez Flutter depuis https://docs.flutter.dev/get-started/install/macos"
        elif [[ "$OS_TYPE" == "linux" ]]; then
            echo "Flutter doit être installé manuellement sur Linux :"
            echo "1. Téléchargez Flutter depuis https://docs.flutter.dev/get-started/install/linux"
        else
            echo "Flutter doit être installé manuellement :"
            echo "1. Téléchargez Flutter depuis https://docs.flutter.dev/get-started/install"
        fi
        echo "2. Extrayez l'archive dans l'emplacement de votre choix"
        echo "3. Ajoutez Flutter au PATH : export PATH=\"\$PATH:\$HOME/flutter/bin\""
        MISSING_TOOLS+=("Flutter")
    fi
else
    print_success "Flutter est déjà installé"
    # Vérifier la version de Flutter
    FLUTTER_VERSION=$(flutter --version | head -n 1 | awk '{print $2}')
    echo "Version de Flutter : $FLUTTER_VERSION"
fi

# VS Code (vérification seulement, pas d'installation automatique)
if ! command -v code &> /dev/null; then
    echo -n "Vérification de VS Code... "
    print_warning "Non installé ou non disponible dans le PATH"
    echo "VS Code doit être installé manuellement :"
    echo "Téléchargez VS Code depuis https://code.visualstudio.com/download"
    MISSING_TOOLS+=("VS Code")
else
    print_success "VS Code est installé"
    
    # Installation des extensions VS Code recommandées
    print_header "Installation des extensions VS Code recommandées"
    read -p "Voulez-vous installer les extensions VS Code recommandées? (o/N) " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[oO]$ ]]; then
        # Extensions Flutter/Dart
        code --install-extension Dart-Code.flutter
        code --install-extension Dart-Code.dart-code
        
        # Extensions Python
        code --install-extension ms-python.python
        code --install-extension ms-python.vscode-pylance
        code --install-extension LittleFoxTeam.vscode-python-test-adapter
        
        # Outils généraux
        code --install-extension mhutchie.git-graph
        code --install-extension eamodio.gitlens
        
        # Qualité du code
        code --install-extension dbaeumer.vscode-eslint
        code --install-extension esbenp.prettier-vscode
        
        print_success "Extensions VS Code installées"
    else
        print_warning "Les extensions seront proposées à l'ouverture du projet dans VS Code."
    fi
fi

# Résumé
print_header "Résumé des vérifications"

if [ ${#INSTALLED_TOOLS[@]} -gt 0 ]; then
    echo "Outils installés durant cette session :"
    for tool in "${INSTALLED_TOOLS[@]}"; do
        print_success "- $tool"
    done
    echo
fi

if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
    echo "Outils manquants qui nécessitent une installation manuelle :"
    for tool in "${MISSING_TOOLS[@]}"; do
        print_warning "- $tool"
    done
    echo
    print_warning "Veuillez installer les outils manquants avant de continuer."
    exit_code=1
else
    print_success "Tous les prérequis sont satisfaits ou ont été installés avec succès."
    exit_code=0
fi

exit $exit_code