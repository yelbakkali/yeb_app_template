#!/bin/bash
# Script d'automatisation pour merger la branche dev vers main
# Ce script est destiné à l'utilisateur final du projet

set -e  # Arrête le script en cas d'erreur

# Couleurs pour l'affichage
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}===============================================${NC}"
echo -e "${BLUE}  FUSION DE LA BRANCHE DEV VERS MAIN          ${NC}"
echo -e "${BLUE}===============================================${NC}"

# Fonctions utiles
confirmation() {
    # Version compatible avec macOS (sans l'option -n)
    read -p "$1 (o/N) " REPLY
    echo
    [[ $REPLY =~ ^[oO]$ ]]
}

create_version_tag() {
    echo -e "\n${GREEN}Création d'un tag de version${NC}"
    
    # Obtenir la dernière version (compatible macOS)
    if command -v sort >/dev/null 2>&1 && sort --version 2>&1 | grep -q GNU; then
        # GNU sort avec l'option -V
        LATEST_TAG=$(git tag | grep -E "^v[0-9]+\.[0-9]+\.[0-9]+$" | sort -V | tail -n 1)
    else
        # Version alternative pour macOS
        LATEST_TAG=$(git tag | grep -E "^v[0-9]+\.[0-9]+\.[0-9]+$" | python -c "import sys; print(sorted(sys.stdin.readlines(), key=lambda v: [int(x) for x in v.strip()[1:].split('.')])[-1].strip() if sys.stdin.readlines() else '')" 2>/dev/null || git tag | grep -E "^v[0-9]+\.[0-9]+\.[0-9]+$" | sort | tail -n 1)
    fi
    
    if [ -z "$LATEST_TAG" ]; then
        SUGGESTED_VERSION="v0.1.0"
        echo -e "Aucun tag de version précédent trouvé. Version suggérée : ${YELLOW}${SUGGESTED_VERSION}${NC}"
    else
        # Extraire les numéros de version
        MAJOR=$(echo $LATEST_TAG | sed -E 's/v([0-9]+)\.[0-9]+\.[0-9]+/\1/')
        MINOR=$(echo $LATEST_TAG | sed -E 's/v[0-9]+\.([0-9]+)\.[0-9]+/\1/')
        PATCH=$(echo $LATEST_TAG | sed -E 's/v[0-9]+\.[0-9]+\.([0-9]+)/\1/')
        
        # Suggérer une nouvelle version (incrémenter PATCH par défaut)
        SUGGESTED_VERSION="v$MAJOR.$MINOR.$((PATCH+1))"
        echo -e "Dernière version : ${YELLOW}${LATEST_TAG}${NC}"
        echo -e "Version suggérée : ${YELLOW}${SUGGESTED_VERSION}${NC}"
    fi
    
    echo -e "Quel type de mise à jour s'agit-il ?"
    echo -e "1) Patch (${GREEN}correctifs${NC})"
    echo -e "2) Mineur (${YELLOW}nouvelles fonctionnalités non disruptives${NC})"
    echo -e "3) Majeur (${RED}changements incompatibles${NC})"
    echo -e "4) Version personnalisée"
    echo -e "5) Ne pas créer de tag"
    
    read -p "Votre choix (1-5) : " choice
    
    case $choice in
        1)  # Patch - on garde la suggestion par défaut
            VERSION=$SUGGESTED_VERSION
            ;;
        2)  # Mineur - on incrémente MINOR et remet PATCH à 0
            VERSION="v$MAJOR.$((MINOR+1)).0"
            ;;
        3)  # Majeur - on incrémente MAJOR et remet MINOR et PATCH à 0
            VERSION="v$((MAJOR+1)).0.0"
            ;;
        4)  # Personnalisé
            read -p "Entrez la version (format vX.Y.Z) : " custom_version
            # Validation du format
            if [[ $custom_version =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                VERSION=$custom_version
            else
                echo -e "${RED}Format de version incorrect. Utilisation de la suggestion par défaut.${NC}"
                VERSION=$SUGGESTED_VERSION
            fi
            ;;
        5)  # Pas de tag
            echo -e "${YELLOW}Aucun tag ne sera créé.${NC}"
            return 0
            ;;
        *)  # Option par défaut
            VERSION=$SUGGESTED_VERSION
            echo -e "${YELLOW}Option non reconnue. Utilisation de la suggestion par défaut.${NC}"
            ;;
    esac
    
    # Créer le tag
    echo -e "Création du tag ${YELLOW}${VERSION}${NC}"
    if confirmation "Voulez-vous ajouter un message au tag ?"; then
        read -p "Message : " tag_message
        git tag -a $VERSION -m "$tag_message"
    else
        git tag -a $VERSION -m "Version $VERSION"
    fi
    
    # Pousser le tag
    if confirmation "Voulez-vous pousser le tag vers le dépôt distant ?"; then
        git push origin $VERSION
        echo -e "${GREEN}Tag ${VERSION} poussé avec succès !${NC}"
    else
        echo -e "${YELLOW}Le tag ${VERSION} a été créé localement mais n'a pas été poussé.${NC}"
        echo -e "Vous pouvez le pousser plus tard avec : git push origin $VERSION"
    fi
}

echo -e "\n${GREEN}1. Vérification de l'état actuel${NC}"
# Vérifier qu'on est sur la branche dev
current_branch=$(git branch --show-current)
if [[ "$current_branch" != "dev" ]]; then
    echo -e "${YELLOW}Vous n'êtes pas sur la branche dev (branche actuelle : $current_branch).${NC}"
    if confirmation "Voulez-vous passer à la branche dev ?"; then
        git checkout dev || { echo -e "${RED}Échec du passage à la branche dev.${NC}"; exit 1; }
    else
        exit 0
    fi
fi

# Vérifier qu'il n'y a pas de modifications non commitées
if [[ -n $(git status --porcelain) ]]; then
    echo -e "${YELLOW}Il y a des modifications non commitées.${NC}"
    git status
    if confirmation "Voulez-vous committer ces modifications avant de continuer ?"; then
        echo -e "Entrez un message de commit :"
        read commit_message
        git add .
        git commit -m "$commit_message"
    else
        echo -e "${RED}Veuillez commiter ou stasher vos modifications d'abord.${NC}"
        exit 1
    fi
fi

echo -e "\n${GREEN}2. Mise à jour de la branche dev${NC}"
echo -e "Récupération des dernières modifications..."
git pull origin dev || { 
    echo -e "${YELLOW}Il pourrait y avoir des conflits avec le dépôt distant.${NC}"
    if confirmation "Voulez-vous continuer quand même ?"; then
        echo -e "${YELLOW}Continuons sans mettre à jour depuis le dépôt distant.${NC}"
    else
        echo -e "${RED}Fusion annulée. Veuillez résoudre les conflits avant de continuer.${NC}"
        exit 1
    fi
}

# Vérification des tests si présents
if [ -d "tests" ] || [ -d "test" ]; then
    echo -e "\n${GREEN}3. Exécution des tests${NC}"
    if confirmation "Voulez-vous exécuter les tests avant de fusionner ?"; then
        # Détection du type de projet pour exécuter les tests appropriés
        if [ -f "pubspec.yaml" ]; then
            echo -e "Exécution des tests Flutter..."
            flutter test || {
                echo -e "${RED}Les tests ont échoué.${NC}"
                if confirmation "Voulez-vous continuer malgré les erreurs de test ?"; then
                    echo -e "${YELLOW}Continuons malgré les erreurs de test.${NC}"
                else
                    echo -e "${RED}Fusion annulée. Veuillez corriger les tests avant de continuer.${NC}"
                    exit 1
                fi
            }
        elif [ -f "package.json" ]; then
            echo -e "Exécution des tests Node.js..."
            npm test || {
                echo -e "${RED}Les tests ont échoué.${NC}"
                if confirmation "Voulez-vous continuer malgré les erreurs de test ?"; then
                    echo -e "${YELLOW}Continuons malgré les erreurs de test.${NC}"
                else
                    echo -e "${RED}Fusion annulée. Veuillez corriger les tests avant de continuer.${NC}"
                    exit 1
                fi
            }
        elif [ -f "pyproject.toml" ] || [ -f "requirements.txt" ]; then
            echo -e "Exécution des tests Python..."
            if command -v pytest &> /dev/null; then
                pytest || {
                    echo -e "${RED}Les tests ont échoué.${NC}"
                    if confirmation "Voulez-vous continuer malgré les erreurs de test ?"; then
                        echo -e "${YELLOW}Continuons malgré les erreurs de test.${NC}"
                    else
                        echo -e "${RED}Fusion annulée. Veuillez corriger les tests avant de continuer.${NC}"
                        exit 1
                    fi
                }
            else
                echo -e "${YELLOW}Pytest non trouvé. Skipping des tests Python.${NC}"
            fi
        else
            echo -e "${YELLOW}Aucun framework de test reconnu. Skipping des tests.${NC}"
        fi
    fi
fi

echo -e "\n${GREEN}4. Fusion vers main${NC}"
echo -e "Passage à la branche main..."
git checkout main || { echo -e "${RED}Échec du passage à la branche main.${NC}"; exit 1; }
echo -e "Récupération des dernières modifications de main..."
git pull origin main || { echo -e "${YELLOW}Warning: Impossible de mettre à jour main depuis l'origine.${NC}"; }

echo -e "\n${GREEN}5. Merge de dev vers main${NC}"
echo -e "Fusion de la branche dev dans main..."
git merge dev || { 
    echo -e "${RED}Conflit de fusion !${NC}"; 
    echo -e "Veuillez résoudre les conflits, puis exécutez les commandes suivantes :";
    echo -e "git add ."
    echo -e "git commit -m \"Résolution des conflits de fusion\""
    echo -e "git push origin main"
    echo -e "git checkout dev"
    exit 1; 
}

echo -e "\n${GREEN}6. Création de tag de version${NC}"
if confirmation "Souhaitez-vous créer un tag de version pour cette fusion ?"; then
    create_version_tag
fi

echo -e "\n${GREEN}7. Push vers le dépôt distant${NC}"
if confirmation "Voulez-vous pousser les modifications vers la branche main distante ?"; then
    git push origin main || { echo -e "${RED}Échec du push vers main.${NC}"; exit 1; }
    echo -e "${GREEN}Push vers main réussi !${NC}"
else
    echo -e "${YELLOW}Les changements n'ont pas été poussés.${NC}"
    echo -e "Vous pouvez les pousser plus tard avec: git push origin main"
fi

echo -e "\n${GREEN}8. Retour à la branche dev${NC}"
git checkout dev || { echo -e "${RED}Échec du retour à la branche dev.${NC}"; exit 1; }

echo -e "\n${BLUE}===============================================${NC}"
echo -e "${BLUE}  FUSION TERMINÉE AVEC SUCCÈS                 ${NC}"
echo -e "${BLUE}===============================================${NC}"
echo ""
echo -e "Branche actuelle: ${YELLOW}$(git branch --show-current)${NC}"
echo -e "La branche ${YELLOW}main${NC} a été mise à jour avec le contenu de ${YELLOW}dev${NC}"
echo ""