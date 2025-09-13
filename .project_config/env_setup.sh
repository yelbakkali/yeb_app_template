#!/bin/bash
# Configuration des chemins et de l'environnement du projet
# Ce fichier est chargé automatiquement par les scripts de développement

# Obtenir le chemin absolu du répertoire du script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$SCRIPT_DIR"

# Charger les informations du projet
if [ -f "$PROJECT_ROOT/.project_config/project_info.sh" ]; then
    source "$PROJECT_ROOT/.project_config/project_info.sh"
fi

# Ajouter les répertoires bin au PATH
export PATH="$PROJECT_ROOT/bin:$PATH"

# Configuration spécifique à la plateforme
if [[ "$OSTYPE" == "darwin"* ]]; then
    # Configuration spécifique à macOS
    
    # Détection de l'architecture
    if [[ $(uname -m) == "arm64" ]]; then
        # Configuration pour Apple Silicon (M1/M2)
        export MACOS_ARCH="arm64"
        
        # Configurer Flutter pour utiliser Rosetta 2 par défaut
        # Décommenter la ligne ci-dessous pour forcer l'exécution native
        # export FLUTTER_FORCE_NATIVE=1
    else
        # Configuration pour Intel Mac
        export MACOS_ARCH="x86_64"
    fi
    
    # Configurer les chemins Homebrew selon l'architecture
    if [ -f "/opt/homebrew/bin/brew" ]; then
        # Pour Apple Silicon (M1/M2)
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -f "/usr/local/bin/brew" ]; then
        # Pour Intel Mac
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    
    # Configurer les chemins Python/Poetry
    if [ -d "$HOME/.poetry/bin" ]; then
        export PATH="$HOME/.poetry/bin:$PATH"
    fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Configuration spécifique à Linux
    export PATH="$HOME/.local/bin:$PATH"
    export PATH="$HOME/.poetry/bin:$PATH"
fi

# Détecter et configurer les chemins des environnements virtuels
if command -v poetry &> /dev/null; then
    # Pour le backend web
    if [ -d "$PROJECT_ROOT/web_backend" ]; then
        WEB_BACKEND_VENV=$(cd "$PROJECT_ROOT/web_backend" && poetry env info --path 2>/dev/null)
        if [ -n "$WEB_BACKEND_VENV" ] && [ -d "$WEB_BACKEND_VENV" ]; then
            export WEB_BACKEND_VENV
            export PATH="$WEB_BACKEND_VENV/bin:$PATH"
        fi
    fi
    
    # Pour le backend Python
    if [ -d "$PROJECT_ROOT/python_backend" ]; then
        PYTHON_BACKEND_VENV=$(cd "$PROJECT_ROOT/python_backend" && poetry env info --path 2>/dev/null)
        if [ -n "$PYTHON_BACKEND_VENV" ] && [ -d "$PYTHON_BACKEND_VENV" ]; then
            export PYTHON_BACKEND_VENV
            export PATH="$PYTHON_BACKEND_VENV/bin:$PATH"
        fi
    fi
fi

# Afficher un message sur la configuration
echo "Environnement du projet configuré avec succès"
echo "Projet: $PROJECT_NAME"
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Plateforme: macOS ($MACOS_ARCH)"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Plateforme: Linux"
fi