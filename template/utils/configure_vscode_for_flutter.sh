#!/bin/bash
# ==========================================================================
# RÉFÉRENCES CROISÉES:
# - Ce fichier est référencé dans: [template/init_project.sh:456, 458, 459]
# - Ce fichier est référencé dans: [init_project.sh:456, 458, 459]
# ==========================================================================

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
    # Sauvegarder la version actuelle pour comparer
    cp "$SETTINGS_FILE" "${SETTINGS_FILE}.bak"
    
    # Modifier le fichier settings.json avec jq
    jq '. + {
        "dart.flutterSdkPath": "",
        "dart.sdkPath": "",
        "python.defaultInterpreterPath": "${command:python.interpreterPath}",
        "python.analysis.extraPaths": ["${workspaceFolder}/shared_python"]
    }' "$SETTINGS_FILE" > "$TMP_FILE"
    
    # Remplacer le fichier original
    mv "$TMP_FILE" "$SETTINGS_FILE"
    
    echo -e "${GREEN}Fichier settings.json configuré avec succès.${NC}"
else
    # Si jq n'est pas disponible, utiliser une méthode plus simple mais moins robuste
    echo -e "${YELLOW}L'outil jq n'est pas installé, utilisation d'une méthode alternative...${NC}"
    
    # Sauvegarder la version actuelle
    cp "$SETTINGS_FILE" "${SETTINGS_FILE}.bak"
    
    # Lire le contenu du fichier existant
    CONTENT=$(cat "$SETTINGS_FILE")
    
    # Supprimer l'accolade finale et ajouter nos configurations
    CONTENT=$(echo "$CONTENT" | sed 's/}$//')
    
    # Si le fichier n'est pas vide et ne se termine pas par une virgule, ajouter une virgule
    if [ -s "$SETTINGS_FILE" ] && ! echo "$CONTENT" | grep -q ',$'; then
        CONTENT="${CONTENT},"
    fi
    
    # Ajouter les nouvelles configurations
    echo "$CONTENT" > "$SETTINGS_FILE"
    cat >> "$SETTINGS_FILE" <<EOL
    "dart.flutterSdkPath": "",
    "dart.sdkPath": "",
    "python.defaultInterpreterPath": "\${command:python.interpreterPath}",
    "python.analysis.extraPaths": ["\${workspaceFolder}/shared_python"]
}
EOL
    
    echo -e "${GREEN}Fichier settings.json configuré avec succès (méthode alternative).${NC}"
fi

echo -e "${YELLOW}Configuration de VS Code terminée.${NC}"
echo -e "${GREEN}Vous pouvez maintenant ouvrir le projet dans VS Code.${NC}"