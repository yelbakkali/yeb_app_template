#!/bin/bash

# Script d'automatisation pour merger la branche dev vers main
# Ce script respecte les règles définies dans docs/copilot/methodologie_temp.md
# Il ne doit jamais être inclus dans la branche main

set -e  # Arrête le script en cas d'erreur

# Couleurs pour l'affichage
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}===============================================${NC}"
echo -e "${YELLOW}  FUSION AUTOMATIQUE DE DEV VERS MAIN          ${NC}"
echo -e "${YELLOW}===============================================${NC}"

echo -e "\n${GREEN}1. Vérification de l'état actuel${NC}"
# Vérifier qu'on est sur la branche dev
current_branch=$(git branch --show-current)
if [[ "$current_branch" != "dev" ]]; then
  echo -e "${RED}Erreur: Vous n'êtes pas sur la branche dev!${NC}"
  echo -e "Passage à la branche dev..."
  git checkout dev || { echo -e "${RED}Échec du passage à la branche dev.${NC}"; exit 1; }
fi

# Vérifier qu'il n'y a pas de modifications non commitées
if [[ -n $(git status --porcelain) ]]; then
  echo -e "${RED}Erreur: Il y a des modifications non commitées!${NC}"
  echo "Veuillez commiter ou stasher vos modifications d'abord."
  exit 1
fi

echo -e "\n${GREEN}2. Mise à jour de la branche dev${NC}"
git pull origin dev || { echo -e "${RED}Échec de la mise à jour de la branche dev.${NC}"; exit 1; }

echo -e "\n${GREEN}3. Création d'une branche temporaire${NC}"
temp_branch="temp_merge_to_main_$(date +%Y%m%d%H%M%S)"
git checkout -b "$temp_branch" || { echo -e "${RED}Échec de la création de la branche temporaire.${NC}"; exit 1; }
echo -e "Branche temporaire créée: ${YELLOW}$temp_branch${NC}"

echo -e "\n${GREEN}4. Exclusion des fichiers spécifiques au développement${NC}"

# Suppression de methodologie_temp.md
echo "Suppression de methodologie_temp.md..."
git rm -f docs/copilot/methodologie_temp.md || echo -e "${YELLOW}Note: methodologie_temp.md n'existe pas ou n'est pas suivi par Git.${NC}"

# Ne pas inclure ce script
echo "Suppression de ce script d'automatisation..."
git rm -f scripts/merge_to_main.sh || { echo -e "${YELLOW}Note: Le script merge_to_main.sh n'est pas sous contrôle de version.${NC}"; }

# Vider chat_resume.md
echo "Vidage de chat_resume.md..."
echo "# Résumé des sessions de travail avec GitHub Copilot" > docs/chat_resume.md
echo "" >> docs/chat_resume.md
echo "Ce document résume les sessions de travail avec GitHub Copilot pour faciliter la reprise du contexte." >> docs/chat_resume.md
git add docs/chat_resume.md

# Vider les fichiers de sessions
echo "Vidage des fichiers de sessions..."
find docs/copilot/sessions/ -type f -name "*.md" | while read -r file; do
  filename=$(basename "$file" .md)
  echo "# Session $filename" > "$file"
  git add "$file"
done

echo -e "\n${GREEN}5. Commit des modifications${NC}"
git commit -m "Préparation de la fusion vers main - exclusion des fichiers de développement" || { 
  echo -e "${YELLOW}Aucun changement à commiter ou aucun fichier à exclure trouvé.${NC}";
  echo -e "Vérifiez si les fichiers à exclure existent déjà.";
}

echo -e "\n${GREEN}6. Fusion vers main${NC}"
git checkout main || { echo -e "${RED}Échec du passage à la branche main.${NC}"; exit 1; }
git pull origin main || { echo -e "${RED}Échec de la mise à jour de la branche main.${NC}"; exit 1; }

echo -e "\n${GREEN}7. Merge de la branche temporaire dans main${NC}"
git merge "$temp_branch" -m "Merge automatique de dev vers main" || { 
  echo -e "${RED}Conflit de fusion!${NC}"; 
  echo "Résolvez les conflits manuellement puis exécutez:";
  echo "git commit -m \"Résolution des conflits de fusion\"";
  echo "git push origin main";
  echo "git checkout dev";
  echo "git branch -D $temp_branch";
  exit 1; 
}

echo -e "\n${GREEN}8. Vérification des fichiers exclus${NC}"
if git ls-tree -r main --name-only | grep -q "docs/copilot/methodologie_temp.md"; then
  echo -e "${YELLOW}Attention: methodologie_temp.md est toujours présent dans main.${NC}"
fi

if git ls-tree -r main --name-only | grep -q "scripts/merge_to_main.sh"; then
  echo -e "${YELLOW}Attention: Le script merge_to_main.sh est toujours présent dans main.${NC}"
fi

echo -e "\n${GREEN}9. Push vers le dépôt distant${NC}"
git push origin main || { echo -e "${RED}Échec du push vers main.${NC}"; exit 1; }
echo -e "${GREEN}Push vers main réussi!${NC}"

echo -e "\n${GREEN}10. Nettoyage${NC}"
git checkout dev || { echo -e "${RED}Échec du retour à la branche dev.${NC}"; exit 1; }
echo -e "Suppression de la branche temporaire ${YELLOW}$temp_branch${NC}..."
git branch -D "$temp_branch" || { echo -e "${RED}Échec de la suppression de la branche temporaire.${NC}"; exit 1; }

echo -e "\n${GREEN}===============================================${NC}"
echo -e "${GREEN}  FUSION TERMINÉE AVEC SUCCÈS                 ${NC}"
echo -e "${GREEN}===============================================${NC}"
echo ""
echo -e "Branche actuelle: ${YELLOW}$(git branch --show-current)${NC}"
echo -e "La branche ${YELLOW}main${NC} a été mise à jour avec le contenu de ${YELLOW}dev${NC}"
echo -e "Les fichiers spécifiques au développement ont été exclus."
echo ""
