#!/bin/bash
# ==========================================================================
# RÉFÉRENCES CROISÉES:
# - Ce fichier est référencé dans: [template/init_project.sh:538, 540]
# - Ce fichier est référencé dans: [init_project.sh:538, 540]
# - Ce fichier est référencé dans: [init_project.bat:5]
# ==========================================================================

# Script pour nettoyer les fichiers d'initialisation après leur première utilisation

# Couleurs pour l'affichage
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}===============================================${NC}"
echo -e "${BLUE}  NETTOYAGE DES FICHIERS D'INITIALISATION     ${NC}"
echo -e "${BLUE}===============================================${NC}"

# Vérifier que l'utilisateur est sûr de vouloir supprimer ces fichiers
echo -e "${YELLOW}ATTENTION : Ce script va supprimer ou archiver les fichiers d'initialisation${NC}"
echo -e "${YELLOW}qui ne sont plus nécessaires après la première configuration du projet.${NC}"
echo ""
read -p "Êtes-vous sûr de vouloir continuer ? (o/N) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[oO]$ ]]; then
    echo "Nettoyage annulé."
    exit 0
fi

# Chemin du répertoire racine du projet
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# Créer un répertoire d'archive si l'utilisateur préfère archiver plutôt que supprimer
ARCHIVE_DIRECTORY="$PROJECT_ROOT/archived_init_files"
mkdir -p "$ARCHIVE_DIRECTORY"

echo -e "${YELLOW}Voulez-vous supprimer les fichiers définitivement ou les archiver ?${NC}"
echo "1) Supprimer définitivement"
echo "2) Archiver dans $ARCHIVE_DIRECTORY"
read -p "Choisissez une option (1/2, défaut: 2): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[1]$ ]]; then
    ACTION="delete"
    echo "Les fichiers seront supprimés définitivement."
else
    ACTION="archive"
    echo "Les fichiers seront archivés dans $ARCHIVE_DIRECTORY."
fi

# Liste des fichiers à nettoyer
FILES_TO_CLEAN=(
    "bootstrap.sh"
    "init_project.sh"
    "init_project.bat"
    "setup_project.sh"
    "setup_project.bat"
    "template/"
)

# Fonction pour traiter un fichier (supprimer ou archiver)
process_file() {
    local file="$1"
    if [ ! -e "$file" ]; then
        echo -e "${YELLOW}Le fichier/répertoire '$file' n'existe pas.${NC}"
        return
    fi
    
    if [ "$ACTION" == "delete" ]; then
        if [ -d "$file" ]; then
            echo -e "${RED}Suppression du répertoire $file${NC}"
            rm -rf "$file"
        else
            echo -e "${RED}Suppression du fichier $file${NC}"
            rm -f "$file"
        fi
    else
        local dest_path="$ARCHIVE_DIRECTORY/$(basename "$file")"
        if [ -d "$file" ]; then
            echo -e "${BLUE}Archivage du répertoire $file vers $dest_path${NC}"
            cp -r "$file" "$dest_path"
            rm -rf "$file"
        else
            echo -e "${BLUE}Archivage du fichier $file vers $dest_path${NC}"
            cp "$file" "$dest_path"
            rm -f "$file"
        fi
    fi
}

# Traiter chaque fichier de la liste
echo -e "${BLUE}===============================================${NC}"
echo -e "${BLUE}      DÉBUT DU NETTOYAGE DES FICHIERS         ${NC}"
echo -e "${BLUE}===============================================${NC}"
echo ""

for file in "${FILES_TO_CLEAN[@]}"; do
    process_file "$file"
done

# Nettoyer également ce script lui-même et les scripts associés
INIT_SCRIPTS=(
    "scripts/cleanup_init_files.sh"
    "scripts/cleanup_init_files.bat"
)

echo ""
echo -e "${YELLOW}Le nettoyage des fichiers d'initialisation est terminé.${NC}"
echo -e "${YELLOW}Ce script et ses associés peuvent également être supprimés.${NC}"
read -p "Voulez-vous nettoyer ces scripts maintenant ? (o/N) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[oO]$ ]]; then
    for script in "${INIT_SCRIPTS[@]}"; do
        process_file "$script"
    done
    
    echo -e "${GREEN}Nettoyage complet des fichiers d'initialisation terminé.${NC}"
else
    echo -e "${YELLOW}Les scripts de nettoyage suivants ont été conservés :${NC}"
    for script in "${INIT_SCRIPTS[@]}"; do
        if [ -e "$script" ]; then
            echo "- $script"
        fi
    done
    echo -e "${YELLOW}Vous pouvez les supprimer manuellement plus tard.${NC}"
fi

echo ""
echo -e "${GREEN}===============================================${NC}"
echo -e "${GREEN}  NETTOYAGE DES FICHIERS TERMINÉ AVEC SUCCÈS  ${NC}"
echo -e "${GREEN}===============================================${NC}"