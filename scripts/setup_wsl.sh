#!/bin/bash
# Script d'installation des dépendances pour WSL (Ubuntu/Debian)
# Ce script installe tous les outils nécessaires pour le développement du projet yeb_app_template dans WSL

set -e  # Arrête le script si une erreur se produit

# Fonctions utilitaires
echo_info() {
    echo -e "\e[1;34m[INFO]\e[0m $1"
}

echo_success() {
    echo -e "\e[1;32m[SUCCÈS]\e[0m $1"
}

echo_warning() {
    echo -e "\e[1;33m[AVERTISSEMENT]\e[0m $1"
}

echo_error() {
    echo -e "\e[1;31m[ERREUR]\e[0m $1"
}

# Vérifier que nous sommes bien dans WSL
if ! grep -q Microsoft /proc/version && ! grep -q microsoft /proc/version; then
    echo_warning "Ce script est conçu pour être exécuté dans un environnement WSL."
    echo "Voulez-vous continuer quand même? (o/n)"
    read -r response
    if [[ "$response" != "o" && "$response" != "O" ]]; then
        echo_info "Installation annulée."
        exit 0
    fi
fi

# Mise à jour des paquets
echo_info "Mise à jour des paquets..."
sudo apt update && sudo apt upgrade -y

# Installation des dépendances de base
echo_info "Installation des dépendances de base..."
sudo apt install -y \
    curl \
    git \
    unzip \
    zip \
    wget \
    python3 \
    python3-pip \
    python3-venv \
    libsqlite3-dev

# Installation de Poetry (gestionnaire de dépendances Python)
echo_info "Installation de Poetry..."
if ! command -v poetry &> /dev/null; then
    curl -sSL https://install.python-poetry.org | python3 -
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    source ~/.bashrc
    echo_success "Poetry installé avec succès."
else
    echo_info "Poetry est déjà installé."
fi

# Installation de Flutter
echo_info "Vérification de l'installation de Flutter..."
if ! command -v flutter &> /dev/null; then
    echo_info "Installation de Flutter..."

    # Créer un dossier pour Flutter dans /opt
    FLUTTER_PATH="$HOME/development"
    mkdir -p "$FLUTTER_PATH"

    # Télécharger Flutter
    cd "$FLUTTER_PATH"
    wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.19.4-stable.tar.xz
    tar xf flutter_linux_3.19.4-stable.tar.xz
    rm flutter_linux_3.19.4-stable.tar.xz

    # Ajouter Flutter au PATH
    echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.bashrc

    # Activer la prise en charge du développement web
    cd flutter
    export PATH="$PATH:$HOME/development/flutter/bin"
    flutter config --enable-web

    echo_success "Flutter installé avec succès."
else
    echo_info "Flutter est déjà installé."
    flutter config --enable-web
fi

# Installation de Chrome (nécessaire pour le développement web Flutter)
echo_info "Vérification de l'installation de Google Chrome..."
if ! command -v google-chrome &> /dev/null; then
    echo_info "Installation de Google Chrome..."
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo apt install -y ./google-chrome-stable_current_amd64.deb
    rm google-chrome-stable_current_amd64.deb
    echo_success "Google Chrome installé avec succès."
else
    echo_info "Google Chrome est déjà installé."
fi

# Installation des extensions VS Code recommandées
echo_info "Vérification de l'installation de VS Code..."
if command -v code &> /dev/null; then
    echo_info "Installation des extensions VS Code recommandées..."
    code --install-extension ms-python.python
    code --install-extension ms-python.vscode-pylance
    code --install-extension dart-code.flutter
    code --install-extension dart-code.dart-code
    code --install-extension github.vscode-pull-request-github
    echo_success "Extensions VS Code installées avec succès."
else
    echo_warning "VS Code n'est pas disponible dans le terminal. Extensions non installées."
    echo_info "Installez manuellement les extensions depuis VS Code ou installez VS Code dans WSL."
fi

# Configurer le projet
echo_info "Installation des dépendances Python du projet..."
cd "$(dirname "$0")/.."  # Revenir à la racine du projet

# Installer les dépendances Python avec Poetry
cd python_backend
if [ -f "pyproject.toml" ]; then
    poetry install
    echo_success "Dépendances Python installées avec succès."
else
    echo_warning "Fichier pyproject.toml non trouvé. Dépendances Python non installées."
fi

cd ..
cd web_backend
if [ -f "pyproject.toml" ]; then
    poetry install
    echo_success "Dépendances Python installées avec succès."
else
    echo_warning "Fichier pyproject.toml non trouvé. Dépendances Python non installées."
fi

cd ..

# Installer les dépendances Flutter
cd flutter_app
if [ -f "pubspec.yaml" ]; then
    echo_info "Installation des dépendances Flutter..."
    flutter pub get
    echo_success "Dépendances Flutter installées avec succès."
else
    echo_warning "Fichier pubspec.yaml non trouvé. Dépendances Flutter non installées."
fi

cd ..

# Configuration de l'optimisation VS Code pour WSL
echo_info "Configuration du lanceur optimisé VS Code pour WSL..."
SCRIPT_PATH="$(pwd)/scripts/start_vscode_wsl.sh"
chmod +x "$SCRIPT_PATH"

# Ajout d'un alias dans le profil bash
PROFILE_FILE=""
if [ -f "$HOME/.bashrc" ]; then
    PROFILE_FILE="$HOME/.bashrc"
elif [ -f "$HOME/.bash_profile" ]; then
    PROFILE_FILE="$HOME/.bash_profile"
elif [ -f "$HOME/.profile" ]; then
    PROFILE_FILE="$HOME/.profile"
fi

if [ -n "$PROFILE_FILE" ]; then
    # Vérifier si l'alias existe déjà
    if grep -q "alias code-wsl=" "$PROFILE_FILE"; then
        # Mettre à jour l'alias existant
        sed -i "s|alias code-wsl=.*|alias code-wsl='$SCRIPT_PATH'|g" "$PROFILE_FILE"
    else
        # Ajouter le nouvel alias
        echo -e "\n# Alias pour lancer VS Code avec des paramètres optimisés pour WSL" >> "$PROFILE_FILE"
        echo "alias code-wsl='$SCRIPT_PATH'" >> "$PROFILE_FILE"
    fi
    echo_success "Alias 'code-wsl' configuré dans $PROFILE_FILE"
    echo_info "Utilisez la commande 'code-wsl' pour lancer VS Code avec des paramètres optimisés pour WSL"
else
    echo_warning "Aucun fichier de profil bash trouvé. L'alias code-wsl n'a pas été configuré."
    echo_info "Vous pouvez toujours utiliser le script manuellement : $SCRIPT_PATH"
fi

echo_success "Installation terminée avec succès!"
echo_info "Veuillez redémarrer votre terminal ou exécuter 'source $PROFILE_FILE' pour appliquer les changements."
echo_info "Pour démarrer le développement web, exécutez: cd flutter_app && flutter run -d chrome"
echo_info "Pour lancer VS Code avec les optimisations WSL, utilisez: code-wsl"
