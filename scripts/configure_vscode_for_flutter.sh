#!/bin/bash

# Ce script modifie le fichier .vscode/settings.json pour exécuter automatiquement
# le script d'installation des dépendances lors de l'ouverture du projet dans VS Code

# Couleurs pour l'affichage
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Configuration de VS Code pour l'installation automatique des dépendances...${NC}"

# Chemin du répertoire racine du projet
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SETTINGS_FILE="$PROJECT_ROOT/.vscode/settings.json"

# Créer le répertoire .vscode s'il n'existe pas
mkdir -p "$PROJECT_ROOT/.vscode"

# Créer ou modifier le fichier settings.json
if [ ! -f "$SETTINGS_FILE" ]; then
    echo "{}" > "$SETTINGS_FILE"
fi

# Créer un fichier temporaire pour les paramètres modifiés
TMP_FILE=$(mktemp)

# Utilisation de jq pour ajouter la configuration si jq est disponible
if command -v jq &> /dev/null; then
    jq '.["dart.runPubGetOnPubspecChanges"] = true | 
        .["flutter.autoInstallPubDeps"] = true' "$SETTINGS_FILE" > "$TMP_FILE"
    mv "$TMP_FILE" "$SETTINGS_FILE"
    echo -e "${GREEN}Configuration VS Code mise à jour avec succès.${NC}"
else
    # Si jq n'est pas disponible, utiliser un script Python
    if command -v python &> /dev/null || command -v python3 &> /dev/null; then
        PYTHON_CMD="python"
        if ! command -v python &> /dev/null; then
            PYTHON_CMD="python3"
        fi
        
        $PYTHON_CMD -c '
import json
import sys
import os

settings_file = sys.argv[1]
with open(settings_file, "r") as f:
    try:
        settings = json.load(f)
    except json.JSONDecodeError:
        settings = {}

# Ajouter ou mettre à jour les configurations
settings["dart.runPubGetOnPubspecChanges"] = True
settings["flutter.autoInstallPubDeps"] = True

# Écrire les modifications
with open(settings_file, "w") as f:
    json.dump(settings, f, indent=4)
        ' "$SETTINGS_FILE"
        
        echo -e "${GREEN}Configuration VS Code mise à jour avec succès.${NC}"
    else
        echo -e "${RED}Ni jq ni Python ne sont disponibles. Veuillez installer l'un d'entre eux ou modifier manuellement $SETTINGS_FILE${NC}"
        echo -e "Ajoutez les lignes suivantes à votre fichier .vscode/settings.json :"
        echo -e '"dart.runPubGetOnPubspecChanges": true,'
        echo -e '"flutter.autoInstallPubDeps": true,'
    fi
fi

echo -e "\n${GREEN}Configuration terminée !${NC}"
echo -e "VS Code exécutera automatiquement 'flutter pub get' lorsque le fichier pubspec.yaml est modifié."