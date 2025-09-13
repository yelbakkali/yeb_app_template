#!/bin/bash
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
echo ""
read -p "Voulez-vous archiver les fichiers plutôt que les supprimer ? (o/N) " -n 1 -r
echo ""
ARCHIVE=false
if [[ $REPLY =~ ^[oO]$ ]]; then
    ARCHIVE=true
    ARCHIVE_DIR="$PROJECT_ROOT/.init_archive"
    mkdir -p "$ARCHIVE_DIR"
    echo -e "${GREEN}Les fichiers seront archivés dans $ARCHIVE_DIR${NC}"
fi

# Liste des fichiers d'initialisation à supprimer ou archiver
INIT_FILES=(
    "init_project.sh"
    "init_project.bat"
    "scripts/setup.sh"
    "scripts/setup.bat"
    "scripts/setup_windows.bat"
    "scripts/setup_wsl.sh"
)

echo ""
echo -e "${BLUE}Traitement des fichiers d'initialisation :${NC}"

# Supprimer ou archiver les fichiers
for file in "${INIT_FILES[@]}"; do
    if [ -f "$PROJECT_ROOT/$file" ]; then
        if [ "$ARCHIVE" = true ]; then
            # Créer les sous-répertoires nécessaires dans l'archive
            mkdir -p "$(dirname "$ARCHIVE_DIR/$file")"
            echo "Archivage de $file..."
            cp "$PROJECT_ROOT/$file" "$ARCHIVE_DIR/$file"
            rm "$PROJECT_ROOT/$file"
            echo -e "${GREEN}✓ $file archivé${NC}"
        else
            echo "Suppression de $file..."
            rm "$PROJECT_ROOT/$file"
            echo -e "${GREEN}✓ $file supprimé${NC}"
        fi
    else
        echo -e "${YELLOW}? $file non trouvé${NC}"
    fi
done

# Créer un fichier README dans le répertoire d'archive
if [ "$ARCHIVE" = true ]; then
    cat > "$ARCHIVE_DIR/README.md" << EOF
# Fichiers d'initialisation archivés

Ce répertoire contient des fichiers d'initialisation qui ont été utilisés lors de la première
configuration du projet et qui ne sont plus nécessaires pour le développement quotidien.

Ils sont conservés ici à titre de référence, mais peuvent être supprimés en toute sécurité
si vous n'en avez plus besoin.

Date d'archivage : $(date "+%Y-%m-%d %H:%M:%S")
EOF
    echo -e "${GREEN}Fichier README.md créé dans le répertoire d'archive${NC}"
fi

# Mettre à jour le .gitignore pour ignorer le répertoire d'archive si nécessaire
if [ "$ARCHIVE" = true ]; then
    if [ -f "$PROJECT_ROOT/.gitignore" ]; then
        if ! grep -q "^.init_archive/" "$PROJECT_ROOT/.gitignore"; then
            echo "" >> "$PROJECT_ROOT/.gitignore"
            echo "# Répertoire d'archive des fichiers d'initialisation" >> "$PROJECT_ROOT/.gitignore"
            echo ".init_archive/" >> "$PROJECT_ROOT/.gitignore"
            echo -e "${GREEN}Répertoire d'archive ajouté à .gitignore${NC}"
        fi
    else
        echo "# Répertoire d'archive des fichiers d'initialisation" > "$PROJECT_ROOT/.gitignore"
        echo ".init_archive/" >> "$PROJECT_ROOT/.gitignore"
        echo -e "${GREEN}Fichier .gitignore créé avec le répertoire d'archive${NC}"
    fi
fi

# Créer un script de remplacement minimal pour init_project.sh/bat
cat > "$PROJECT_ROOT/init_project.sh" << EOF
#!/bin/bash
echo "Ce script a déjà été exécuté et les fichiers d'initialisation ont été supprimés."
echo "Si vous devez réinitialiser le projet, veuillez vous référer à la documentation dans le dossier docs/."
exit 0
EOF
chmod +x "$PROJECT_ROOT/init_project.sh"

# Version Windows
cat > "$PROJECT_ROOT/init_project.bat" << EOF
@echo off
echo Ce script a déjà été exécuté et les fichiers d'initialisation ont été supprimés.
echo Si vous devez réinitialiser le projet, veuillez vous référer à la documentation dans le dossier docs/.
exit /b 0
EOF

echo -e "${GREEN}Scripts d'initialisation remplacés par des versions minimales${NC}"

# Proposer de committer les changements
echo ""
read -p "Voulez-vous committer ces changements ? (o/N) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[oO]$ ]]; then
    git add -A
    git commit -m "🧹 Nettoyage des fichiers d'initialisation"
    echo -e "${GREEN}Changements commités${NC}"
fi

echo ""
echo -e "${BLUE}===============================================${NC}"
echo -e "${BLUE}  NETTOYAGE TERMINÉ AVEC SUCCÈS               ${NC}"
echo -e "${BLUE}===============================================${NC}"
echo ""
if [ "$ARCHIVE" = true ]; then
    echo -e "Les fichiers d'initialisation ont été archivés dans ${YELLOW}$ARCHIVE_DIR${NC}"
    echo -e "Vous pouvez supprimer ce répertoire ultérieurement si vous n'en avez plus besoin."
else
    echo -e "Les fichiers d'initialisation ont été supprimés."
fi
echo -e "Des versions minimales des scripts ont été laissées en place pour informer les futurs utilisateurs."
echo ""