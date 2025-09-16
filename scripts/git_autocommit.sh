#!/bin/bash

# ==========================================================================
# RÉFÉRENCES CROISÉES:
# - Ce fichier est référencé dans: [.github/copilot-instructions.md:18, 115, 119, 121, 135, 138, 140]
# - Ce fichier est référencé dans: [.copilot/memoire_long_terme.md:37, 41, 43, 57, 60, 62]
# - Ce fichier est référencé dans: [.copilot/chat_resume.md:57]
# - Ce fichier est référencé dans: [.copilot/sessions/session_20250914_auto_doc.md:33]
# - Ce fichier est référencé dans: [docs/contributing.md:101, 104, 106, 109, 168]
# - Ce fichier est référencé dans: [docs/chat_resume.md:48]
# - Ce fichier est référencé dans: [template/bootstrap.sh:228]
# ==========================================================================

# git_autocommit.sh
# Script d'automatisation des opérations Git courantes (add, commit, push)
# Ce script détecte les fichiers modifiés, génère un message de commit, puis effectue toutes les actions nécessaires
#
# Utilisation:
#   ./git_autocommit.sh                   # Mode automatique (non-interactif)
#   ./git_autocommit.sh -i                # Mode interactif (questions pour le message et le push)
#   ./git_autocommit.sh --interactive     # Mode interactif (questions pour le message et le push)
#   ./git_autocommit.sh -m "Message"      # Mode automatique avec message personnalisé
#   ./git_autocommit.sh --message "Message" # Mode automatique avec message personnalisé

set -e  # Arrête le script en cas d'erreur

# Couleurs pour l'affichage
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}===============================================${NC}"
echo -e "${BLUE}  AUTOMATISATION GIT - ADD, COMMIT, PUSH       ${NC}"
echo -e "${BLUE}===============================================${NC}"
echo ""

# Vérifier l'état actuel du dépôt Git
echo -e "${GREEN}1. Vérification de l'état actuel du dépôt Git${NC}"
git_status=$(git status --porcelain)

if [ -z "$git_status" ]; then
    echo -e "${YELLOW}Aucun changement détecté dans le dépôt.${NC}"
    echo -e "Statut Git actuel:"
    git status
    exit 0
fi

# Afficher les fichiers modifiés
echo -e "\nFichiers modifiés:"
echo "$git_status"
echo ""

# Message de commit personnalisé ou automatique
if [ "$1" == "--message" ] || [ "$1" == "-m" ]; then
    commit_message="$2"
else
    # Générer un message de commit basé sur les fichiers modifiés
    modified_files=$(git status --porcelain | grep -E '^\s*[AM]' | sed 's/^[ MAD?]*//' | sed 's/^[ MAD?]*//')

    # Compter le nombre de fichiers par extension/type
    md_files=$(echo "$modified_files" | grep -c '\.md$' || true)
    sh_files=$(echo "$modified_files" | grep -c '\.sh$' || true)
    py_files=$(echo "$modified_files" | grep -c '\.py$' || true)
    dart_files=$(echo "$modified_files" | grep -c '\.dart$' || true)

    # Détecter les dossiers principaux modifiés
    docs_modified=$(echo "$modified_files" | grep -c '^docs/' || true)
    scripts_modified=$(echo "$modified_files" | grep -c '^scripts/' || true)
    flutter_modified=$(echo "$modified_files" | grep -c '^flutter_app/' || true)
    python_modified=$(echo "$modified_files" | grep -c '^python_backend\|^web_backend\|^shared_python/' || true)

    # Construire un message de commit pertinent
    commit_message="Mise à jour: "

    if [ $docs_modified -gt 0 ]; then
        if [ $md_files -gt 0 ]; then
            commit_message+="documentation "
        fi
    fi

    if [ $scripts_modified -gt 0 ]; then
        if [ $sh_files -gt 0 ]; then
            commit_message+="scripts d'automatisation "
        fi
    fi

    if [ $flutter_modified -gt 0 ]; then
        if [ $dart_files -gt 0 ]; then
            commit_message+="code Flutter "
        fi
    fi

    if [ $python_modified -gt 0 ]; then
        if [ $py_files -gt 0 ]; then
            commit_message+="code Python "
        fi
    fi

    # Si le message est trop générique, utiliser une liste de fichiers
    if [ "$commit_message" == "Mise à jour: " ]; then
        num_files=$(echo "$git_status" | wc -l)
        first_file=$(echo "$modified_files" | head -n 1)
        if [ $num_files -eq 1 ]; then
            commit_message="Mise à jour de $first_file"
        else
            commit_message="Mise à jour de $first_file et $(($num_files - 1)) autres fichiers"
        fi
    fi
fi

echo -e "${GREEN}Message de commit généré:${NC} $commit_message"
# En mode non-interactif, utilise directement le message généré
if [ "$1" == "--interactive" ] || [ "$1" == "-i" ]; then
    # Mode interactif activé avec le drapeau
    echo -e "${YELLOW}Voulez-vous utiliser ce message? [o/n/e] ${NC}"
    echo -e "(o = oui, n = non (saisir un nouveau message), e = éditer ce message)"
    read -r response

    if [ "$response" == "n" ]; then
        echo -e "${YELLOW}Entrez votre message de commit:${NC}"
        read -r commit_message
    elif [ "$response" == "e" ]; then
        echo -e "${YELLOW}Éditez le message de commit:${NC}"
        echo "$commit_message" > /tmp/commit_msg_temp
        ${EDITOR:-nano} /tmp/commit_msg_temp
        commit_message=$(cat /tmp/commit_msg_temp)
        rm /tmp/commit_msg_temp
    fi
else
    # En mode non-interactif, affiche simplement le message qui sera utilisé
    echo -e "${GREEN}Utilisation du message généré automatiquement.${NC}"
fi

# Ajouter tous les fichiers modifiés à l'index
echo -e "\n${GREEN}2. Ajout des fichiers modifiés à l'index${NC}"
git add .
echo -e "${GREEN}Fichiers ajoutés avec succès.${NC}"

# Créer le commit avec le message validé
echo -e "\n${GREEN}3. Création du commit${NC}"
git commit -m "$commit_message"
echo -e "${GREEN}Commit créé avec succès.${NC}"

# Pousser les modifications vers la branche distante
echo -e "\n${GREEN}4. Push vers le dépôt distant${NC}"

if [ "$1" == "--interactive" ] || [ "$1" == "-i" ]; then
    # Mode interactif activé avec le drapeau
    echo -e "${YELLOW}Voulez-vous pousser les changements vers le dépôt distant? [o/n]${NC}"
    read -r push_response

    if [ "$push_response" == "o" ]; then
        current_branch=$(git branch --show-current)
        git push origin "$current_branch"
        echo -e "${GREEN}Push réussi vers la branche $current_branch.${NC}"
    else
        echo -e "${YELLOW}Les changements n'ont pas été poussés.${NC}"
        echo -e "Vous pouvez les pousser plus tard avec: git push origin $(git branch --show-current)"
    fi
else
    # En mode non-interactif, push automatiquement
    current_branch=$(git branch --show-current)
    git push origin "$current_branch"
    echo -e "${GREEN}Push automatique réussi vers la branche $current_branch.${NC}"
fi

echo -e "\n${GREEN}===============================================${NC}"
echo -e "${GREEN}  OPÉRATION TERMINÉE AVEC SUCCÈS              ${NC}"
echo -e "${GREEN}===============================================${NC}"
