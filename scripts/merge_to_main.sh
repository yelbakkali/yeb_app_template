#!/bin/bash

# ==========================================================================
# RÉFÉRENCES CROISÉES:
# - Ce fichier est référencé dans: [.github/copilot-instructions.md:19]
# - Ce fichier est référencé dans: [.copilot/methodologie_temp.md:53, 73, 81]
# - Ce fichier est référencé dans: [.copilot/chat_resume.md:57]
# - Ce fichier est référencé dans: [.copilot/sessions/session_20250914_auto_doc.md:34]
# - Ce fichier est référencé dans: [docs/contributing.md:121, 169]
# - Ce fichier est référencé dans: [docs/git_workflow.md:140, 148]
# ==========================================================================

# Script d'automatisation pour fusionner la branche 'dev' vers 'main'
# Ce script implémente les règles définies dans .copilot/methodologie_temp.md
# en excluant automatiquement certains fichiers lors de la fusion.
#
# ⚠️ ATTENTION: Ce script ne doit JAMAIS être inclus dans la branche main ⚠️

# Arrêter le script en cas d'erreur
set -e

# Couleurs pour l'affichage
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Fonction pour afficher un message d'en-tête
print_header() {
    echo -e "${BLUE}===============================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}===============================================${NC}"
}

# Fonction pour afficher un message de succès
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Fonction pour afficher un message d'erreur
print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Fonction pour afficher un avertissement
print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Fonction pour afficher une étape
print_step() {
    echo -e "\n${BOLD}$1${NC}"
}

# Fonction pour vérifier l'existence d'un fichier
check_file_exists() {
    if [ -f "$1" ]; then
        return 0
    else
        return 1
    fi
}

# Fonction pour vérifier l'existence d'un répertoire
check_dir_exists() {
    if [ -d "$1" ]; then
        return 0
    else
        return 1
    fi
}

# Fonction pour vérifier si un fichier est suivi par git
is_git_tracked() {
    if git ls-files --error-unmatch "$1" &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Affichage du message d'introduction
print_header "FUSION AUTOMATIQUE DE DEV VERS MAIN"

print_step "ÉTAPE 1: Vérification de l'état actuel"

# Vérifier qu'on est sur la branche dev
current_branch=$(git branch --show-current)
if [[ "$current_branch" != "dev" ]]; then
    print_warning "Vous n'êtes pas sur la branche 'dev' (branche actuelle: $current_branch)"
    read -p "Voulez-vous basculer sur la branche 'dev' ? (o/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Oo]$ ]]; then
        git checkout dev || { print_error "Échec du passage à la branche dev."; exit 1; }
        print_success "Basculé sur la branche 'dev'"
    else
        print_error "Le script doit être exécuté depuis la branche 'dev'"
        exit 1
    fi
fi

# Vérifier qu'il n'y a pas de modifications non commitées
if [[ -n $(git status --porcelain) ]]; then
    print_error "Il y a des modifications non commitées!"
    echo -e "Liste des fichiers modifiés:"
    git status --short

    read -p "Voulez-vous continuer en commitant ces modifications? (o/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Oo]$ ]]; then
        read -p "Message de commit: " commit_message
        git add .
        git commit -m "$commit_message"
        print_success "Modifications commitées"
    else
        print_warning "Veuillez commiter ou stasher vos modifications d'abord"
        exit 1
    fi
fi

print_step "ÉTAPE 2: Mise à jour des branches"

# Synchroniser la branche dev avec le dépôt distant
echo "Synchronisation de la branche 'dev' avec le dépôt distant..."
git pull origin dev || { print_error "Échec de la mise à jour de la branche dev."; exit 1; }
print_success "Branche 'dev' synchronisée"

print_step "ÉTAPE 3: Création d'une branche temporaire"

# Créer une branche temporaire pour la fusion
temp_branch="temp_merge_to_main_$(date +%Y%m%d%H%M%S)"
git checkout -b "$temp_branch" || { print_error "Échec de la création de la branche temporaire."; exit 1; }
print_success "Branche temporaire '$temp_branch' créée"

print_step "ÉTAPE 4: Exclusion des fichiers spécifiques au développement"

# Liste des fichiers à exclure complètement
echo "Fichiers à exclure complètement:"
excluded_files=(
    ".copilot/methodologie_temp.md"
    "scripts/merge_to_main.sh"
    "scripts/merge_to_main.bat"
)

# Traitement des fichiers à exclure
for file in "${excluded_files[@]}"; do
    echo -n "• $file: "
    if check_file_exists "$file"; then
        if is_git_tracked "$file"; then
            git rm -f "$file" && echo "Exclu avec succès"
        else
            rm -f "$file" && echo "Supprimé (non suivi par git)"
        fi
    else
        echo "Non trouvé, déjà exclu"
    fi
done

# Fichier chat_resume.md à vider
echo -n "• .copilot/chat_resume.md: "
if check_file_exists ".copilot/chat_resume.md"; then
    # Créer un contenu minimal pour le fichier
    cat > .copilot/chat_resume.md << EOL
# Résumé des sessions de travail avec GitHub Copilot

Ce document résume les sessions de travail avec GitHub Copilot pour faciliter la reprise du contexte.

## Initialisation du projet

Utilisez ce fichier pour documenter vos sessions de travail avec GitHub Copilot.
EOL

    git add .copilot/chat_resume.md
    echo "Vidé avec succès"
else
    echo "Non trouvé"
fi

# Vider tous les fichiers de sessions
echo "• Fichiers dans .copilot/sessions/:"
if check_dir_exists ".copilot/sessions"; then
    find .copilot/sessions/ -type f -name "*.md" | while read -r file; do
        filename=$(basename "$file" .md)
        echo -n "  - $filename: "

        # Vider le fichier avec un contenu minimal
        cat > "$file" << EOL
# Session $filename

Cette session a été vidée lors de la fusion vers la branche main.
EOL

        git add "$file"
        echo "Vidé"
    done
else
    echo "  Répertoire non trouvé"
fi

print_step "ÉTAPE 5: Commit des modifications sur la branche temporaire"

# Commit des modifications pour l'exclusion des fichiers
git_status=$(git status --porcelain)
if [[ -n "$git_status" ]]; then
    git commit -m "Préparation de la fusion vers main - Exclusion des fichiers spécifiques au développement" || {
        print_error "Échec du commit des modifications";
        git checkout dev;
        git branch -D "$temp_branch";
        exit 1;
    }
    print_success "Modifications commitées sur la branche temporaire"
else
    print_warning "Aucun fichier à exclure n'a été trouvé ou modifié"
fi

print_step "ÉTAPE 6: Fusion vers main"

# Basculer sur la branche main
echo "Passage à la branche 'main'..."
git checkout main || { print_error "Échec du passage à la branche main."; git checkout dev; git branch -D "$temp_branch"; exit 1; }

# Synchroniser la branche main avec le dépôt distant
echo "Synchronisation de la branche 'main' avec le dépôt distant..."
git pull origin main || { print_error "Échec de la mise à jour de la branche main."; git checkout dev; git branch -D "$temp_branch"; exit 1; }

# Fusion de la branche temporaire dans main
echo "Fusion de '$temp_branch' vers 'main'..."
if ! git merge "$temp_branch" -m "Merge automatique de dev vers main avec exclusion des fichiers spécifiques"; then
    print_error "Conflit de fusion détecté!"
    echo
    echo "Suivez ces étapes pour résoudre les conflits:"
    echo "1. Résolvez les conflits manuellement dans les fichiers marqués"
    echo "2. Utilisez 'git add <fichier>' pour marquer les conflits comme résolus"
    echo "3. Exécutez 'git commit -m \"Résolution des conflits de fusion\"'"
    echo "4. Exécutez 'git push origin main'"
    echo "5. Revenez à la branche dev: 'git checkout dev'"
    echo "6. Supprimez la branche temporaire: 'git branch -D $temp_branch'"
    exit 1
fi

print_success "Fusion réussie"

print_step "ÉTAPE 7: Vérification des fichiers exclus"

# Vérifier que les fichiers critiques ont bien été exclus
echo "Vérification que les fichiers sensibles ont bien été exclus de 'main'..."
errors_found=0

# Vérifier l'exclusion des fichiers
for file in "${excluded_files[@]}"; do
    if git ls-tree -r main --name-only | grep -q "$file"; then
        print_error "Le fichier '$file' est toujours présent dans la branche main"
        errors_found=$((errors_found + 1))
    else
        print_success "Le fichier '$file' a été correctement exclu"
    fi
done

# Vérifier que chat_resume.md a été vidé
if git show main:.copilot/chat_resume.md 2>/dev/null | grep -q "Résumé des sessions de travail"; then
    print_success "Le fichier '.copilot/chat_resume.md' a été correctement vidé"
else
    print_warning "Le fichier '.copilot/chat_resume.md' n'a pas été correctement vidé ou n'existe pas"
fi

# Vérifier que les fichiers de session ont été vidés
session_files=$(git ls-tree -r main --name-only | grep -E "\.copilot/sessions/.*\.md$" | wc -l)
if [ "$session_files" -gt 0 ]; then
    sample_file=$(git ls-tree -r main --name-only | grep -E "\.copilot/sessions/.*\.md$" | head -1)
    if git show main:"$sample_file" 2>/dev/null | grep -q "Cette session a été vidée"; then
        print_success "Les fichiers de session ont été correctement vidés"
    else
        print_warning "Les fichiers de session ne semblent pas avoir été correctement vidés"
        errors_found=$((errors_found + 1))
    fi
else
    print_warning "Aucun fichier de session trouvé dans main"
fi

if [ $errors_found -gt 0 ]; then
    print_warning "Des problèmes ont été détectés avec l'exclusion des fichiers"
    read -p "Voulez-vous continuer quand même? (o/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Oo]$ ]]; then
        print_error "Fusion annulée"
        git checkout dev
        git branch -D "$temp_branch"
        exit 1
    fi
fi

print_step "ÉTAPE 8: Push vers le dépôt distant"

# Push des modifications
echo "Push des modifications vers le dépôt distant..."
read -p "Voulez-vous pusher les modifications vers la branche 'main' distante? (O/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    git push origin main || { print_error "Échec du push vers main."; git checkout dev; exit 1; }
    print_success "Les modifications ont été pushées vers 'main'"
else
    print_warning "Les modifications n'ont pas été pushées vers le dépôt distant"
fi

print_step "ÉTAPE 9: Nettoyage et retour à dev"

# Retour à la branche dev
echo "Retour à la branche 'dev'..."
git checkout dev || { print_error "Échec du retour à la branche dev."; exit 1; }

# Suppression de la branche temporaire
echo "Suppression de la branche temporaire '$temp_branch'..."
git branch -D "$temp_branch" || { print_error "Échec de la suppression de la branche temporaire."; exit 1; }

print_header "FUSION TERMINÉE"

echo -e "\nRésumé de l'opération:"
echo -e "• Branche actuelle: ${YELLOW}$(git branch --show-current)${NC}"
echo -e "• La branche ${YELLOW}main${NC} a été mise à jour avec le contenu de ${YELLOW}dev${NC}"
echo -e "• Les fichiers spécifiques au développement ont été exclus"

if [ $errors_found -gt 0 ]; then
    echo -e "\n${YELLOW}⚠ Avertissement: Des problèmes ont été détectés lors de la vérification${NC}"
    echo -e "  Vérifiez manuellement que tous les fichiers sensibles ont bien été exclus"
else
    echo -e "\n${GREEN}✓ Tous les fichiers sensibles ont été correctement exclus${NC}"
fi

echo -e "\nMerci d'avoir utilisé le script d'automatisation de fusion!"
