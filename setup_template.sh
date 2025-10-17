#!/bin/bash

# ==========================================================================
# RÉFÉRENCES CROISÉES:
# - Ce fichier est référencé dans: [README.md:104, 105, 108, 111, 204]
# - Ce fichier est référencé dans: [docs/installation.md:13, 83, 162]
# - Ce fichier est référencé dans: [docs/bootstrap.md:3, 19, 20, 26]
# - Ce fichier est référencé dans: [docs/copilot/template_initialization.md:15]
# - Ce fichier est référencé dans: [.copilot/chat_resume.md:58, 62]
# - Ce fichier est référencé dans: [.copilot/memoire_long_terme.md:108]
# ==========================================================================

# setup_template.sh - Script de démarrage pour initialiser un nouveau projet à partir du template yeb_app_template
# Auteur: Yassine El Bakkali
# Version: 2.0 - Corrigée (Octobre 2025)
# Ce script télécharge le template yeb_app_template et configure un nouveau projet
# avec toutes les dépendances nécessaires

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonctions utilitaires
print_header() {
    echo -e "${BLUE}===================================================================${NC}"
    echo -e "${BLUE} $1 ${NC}"
    echo -e "${BLUE}===================================================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Vérifier si les outils nécessaires sont installés
check_prerequisites() {
    print_header "Vérification des prérequis"

    local missing_tools=()
    local optional_tools=()

    # Vérifier Git (OBLIGATOIRE)
    if ! command -v git &> /dev/null; then
        missing_tools+=("git")
    else
        print_success "Git est installé"
    fi

    # Vérifier curl ou wget (OBLIGATOIRE)
    if command -v curl &> /dev/null; then
        print_success "curl est installé"
        DOWNLOAD_CMD="curl -LJO"
    elif command -v wget &> /dev/null; then
        print_success "wget est installé"
        DOWNLOAD_CMD="wget"
    else
        missing_tools+=("curl ou wget")
    fi

    # Vérifier GitHub CLI (OPTIONNEL mais recommandé)
    if ! command -v gh &> /dev/null; then
        print_warning "GitHub CLI (gh) n'est pas installé (optionnel)"
        optional_tools+=("gh")
    else
        print_success "GitHub CLI (gh) est installé"
    fi

    # Afficher les erreurs si des outils obligatoires sont manquants
    if [ ${#missing_tools[@]} -ne 0 ]; then
        print_error "Outils obligatoires manquants: ${missing_tools[*]}"
        echo -e ""
        echo -e "${YELLOW}Instructions d'installation :${NC}"
        echo -e ""

        # Instructions pour Git
        if [[ " ${missing_tools[@]} " =~ " git " ]]; then
            echo -e "  ${BLUE}Git:${NC}"
            echo -e "    Ubuntu/Debian : ${GREEN}sudo apt install git${NC}"
            echo -e "    Fedora        : ${GREEN}sudo dnf install git${NC}"
            echo -e "    macOS         : ${GREEN}brew install git${NC}"
            echo -e ""
        fi

        # Instructions pour curl/wget
        if [[ " ${missing_tools[@]} " =~ " curl ou wget " ]]; then
            echo -e "  ${BLUE}curl:${NC}"
            echo -e "    Ubuntu/Debian : ${GREEN}sudo apt install curl${NC}"
            echo -e "    Fedora        : ${GREEN}sudo dnf install curl${NC}"
            echo -e "    macOS         : ${GREEN}brew install curl${NC}"
            echo -e ""
        fi

        echo -e "Veuillez installer ces outils avant de continuer."
        exit 1
    fi

    # Proposer l'installation de GitHub CLI si manquant
    if [ ${#optional_tools[@]} -ne 0 ]; then
        echo -e ""
        print_info "GitHub CLI n'est pas installé. Il est recommandé pour créer automatiquement le dépôt GitHub."
        echo -e ""
        echo -e "Voulez-vous installer GitHub CLI maintenant ? (o/N)"
        read -p "> " install_gh

        if [[ "$install_gh" =~ ^[oO]$ ]]; then
            print_info "Installation de GitHub CLI..."

            # Détecter le système d'exploitation
            if [[ "$OSTYPE" == "linux-gnu"* ]]; then
                # Linux
                if command -v apt &> /dev/null; then
                    # Debian/Ubuntu
                    print_info "Détection: Debian/Ubuntu"
                    sudo mkdir -p /etc/apt/keyrings
                    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
                    sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
                    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
                    sudo apt update
                    sudo apt install gh -y
                elif command -v dnf &> /dev/null; then
                    # Fedora/RHEL
                    print_info "Détection: Fedora/RHEL"
                    sudo dnf install 'dnf-command(config-manager)' -y
                    sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
                    sudo dnf install gh -y
                elif command -v yum &> /dev/null; then
                    # CentOS/RHEL (older)
                    print_info "Détection: CentOS/RHEL"
                    sudo yum-config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
                    sudo yum install gh -y
                elif command -v pacman &> /dev/null; then
                    # Arch Linux
                    print_info "Détection: Arch Linux"
                    sudo pacman -S github-cli --noconfirm
                else
                    print_warning "Gestionnaire de paquets non reconnu"
                    echo -e "Veuillez installer GitHub CLI manuellement depuis:"
                    echo -e "${BLUE}https://cli.github.com/${NC}"
                fi
            elif [[ "$OSTYPE" == "darwin"* ]]; then
                # macOS
                print_info "Détection: macOS"
                if command -v brew &> /dev/null; then
                    brew install gh
                else
                    print_warning "Homebrew n'est pas installé"
                    echo -e "Installez Homebrew depuis ${BLUE}https://brew.sh/${NC}"
                    echo -e "Puis exécutez: ${GREEN}brew install gh${NC}"
                fi
            else
                print_warning "Système d'exploitation non reconnu"
                echo -e "Veuillez installer GitHub CLI manuellement depuis:"
                echo -e "${BLUE}https://cli.github.com/${NC}"
            fi

            # Vérifier si l'installation a réussi
            if command -v gh &> /dev/null; then
                print_success "GitHub CLI installé avec succès"
                echo -e ""
                print_info "Pour utiliser GitHub CLI, vous devez vous authentifier:"
                echo -e "  ${GREEN}gh auth login${NC}"
                echo -e ""
            else
                print_warning "L'installation de GitHub CLI a échoué ou nécessite une action manuelle"
                echo -e "Vous pourrez créer le dépôt GitHub manuellement plus tard."
            fi
        else
            print_info "GitHub CLI ne sera pas installé"
            echo -e "Vous pourrez créer le dépôt GitHub manuellement plus tard."
            echo -e "Pour installer GitHub CLI ultérieurement, consultez: ${BLUE}https://cli.github.com/${NC}"
        fi
    fi
}

# Configurer le projet en utilisant le nom du dossier actuel
configure_project() {
    print_header "Configuration du projet"

    # Utiliser le nom du dossier courant comme nom du projet
    PROJECT_NAME=$(basename "$(pwd)")

    # Valider le nom du projet
    if [[ ! "$PROJECT_NAME" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        print_warning "Le nom du dossier actuel '$PROJECT_NAME' contient des caractères non supportés."
        echo -e "Pour une meilleure compatibilité, le dossier du projet devrait contenir uniquement des lettres, chiffres et tirets."
        echo -e "Voulez-vous continuer quand même ? (o/n)"
        read -p "> " confirm
        if [[ ! "$confirm" =~ ^[oO]$ ]]; then
            print_error "Installation annulée. Veuillez renommer votre dossier et réessayer."
            exit 1
        fi
    fi

    echo -e "Le nom du projet sera '${GREEN}$PROJECT_NAME${NC}' (basé sur le nom du dossier actuel)."

    echo -e "Entrez une brève description de votre projet:"
    read -p "> " project_description

    echo -e "Entrez votre nom ou celui de votre organisation:"
    read -p "> " project_author

    PROJECT_DESCRIPTION=$project_description
    PROJECT_AUTHOR=$project_author

    print_success "Projet configuré: $PROJECT_NAME"
}

# Télécharger le template depuis GitHub (VERSION CORRIGÉE)
download_template() {
    print_header "Téléchargement du template"

    echo -e "Téléchargement du template depuis GitHub..."

    # Vérifier si le répertoire est vide (en excluant ce script)
    local file_count=$(ls -A | grep -v "setup_template.sh" | wc -l)
    if [ "$file_count" -gt 0 ]; then
        print_error "Le répertoire courant n'est pas vide!"
        print_info "Ce script doit être exécuté dans un répertoire vide."
        print_info "Fichiers/dossiers détectés:"
        ls -A | grep -v "setup_template.sh"
        echo ""
        echo -e "Voulez-vous continuer quand même ? Les fichiers existants pourraient être écrasés. (o/N)"
        read -p "> " confirm
        if [[ ! "$confirm" =~ ^[oO]$ ]]; then
            print_error "Installation annulée."
            exit 1
        fi
    fi

    # Créer un dossier temporaire pour le clone
    local temp_dir="temp_template_$$"
    print_info "Clonage dans le dossier temporaire: $temp_dir"

    # Cloner le dépôt dans un dossier temporaire
    if git clone --depth 1 https://github.com/yelbakkali/yeb_app_template.git "$temp_dir"; then
        print_success "Template cloné avec succès"

        # Déplacer tous les fichiers du dossier temporaire vers le répertoire courant
        print_info "Déplacement des fichiers du template..."

        # Déplacer les fichiers visibles
        mv "$temp_dir"/* . 2>/dev/null || true

        # Déplacer les fichiers cachés (en excluant . et ..)
        find "$temp_dir" -maxdepth 1 -name ".*" ! -name "." ! -name ".." -exec mv {} . \; 2>/dev/null || true

        # Supprimer le dossier temporaire
        rm -rf "$temp_dir"
        print_success "Fichiers déplacés avec succès"

        # Supprimer le répertoire .git pour recommencer l'historique
        print_info "Réinitialisation de l'historique Git..."
        rm -rf .git

        # Initialiser un nouveau dépôt Git
        git init
        git add .
        git commit -m "Initial commit from yeb_app_template"

        print_success "Nouveau dépôt Git initialisé"
    else
        print_error "Échec du téléchargement du template"
        # Nettoyer le dossier temporaire en cas d'échec
        rm -rf "$temp_dir"
        exit 1
    fi
}

# Personnaliser le template pour le nouveau projet (VERSION CORRIGÉE)
customize_template() {
    print_header "Personnalisation du template"

    echo -e "Mise à jour des fichiers de configuration..."

    # Mettre à jour le pubspec.yaml principal
    if [ -f "pubspec.yaml" ]; then
        print_info "Mise à jour de pubspec.yaml..."
        sed -i "s/name: yeb_app_template/name: $PROJECT_NAME/g" pubspec.yaml
        sed -i "s/description: \"Template d'application Flutter\/Python par YEB\"/description: \"$PROJECT_DESCRIPTION\"/g" pubspec.yaml
        print_success "pubspec.yaml mis à jour"
    else
        print_warning "pubspec.yaml non trouvé"
    fi

    # Mettre à jour le fichier pyproject.toml de shared_python (qui existe réellement)
    if [ -f "shared_python/pyproject.toml" ]; then
        print_info "Mise à jour de shared_python/pyproject.toml..."
        sed -i "s/name = \"shared_python_scripts\"/name = \"${PROJECT_NAME}_python_scripts\"/g" shared_python/pyproject.toml
        sed -i "s/description = \"Scripts Python partagés pour l'application yeb_app_template\"/description = \"Scripts Python pour $PROJECT_NAME\"/g" shared_python/pyproject.toml
        sed -i "s/authors = \[\"Your Name <your.email@example.com>\"\]/authors = [\"$PROJECT_AUTHOR\"]/g" shared_python/pyproject.toml
        print_success "shared_python/pyproject.toml mis à jour"
    else
        print_warning "shared_python/pyproject.toml non trouvé"
    fi

    # Mettre à jour le README.md
    if [ -f "README.md" ]; then
        print_info "Mise à jour de README.md..."
        sed -i "s/# yeb_app_template - Template pour applications Flutter\/Python/# $PROJECT_NAME/g" README.md
        sed -i "s/yeb_app_template/$PROJECT_NAME/g" README.md
        print_success "README.md mis à jour"
    else
        print_warning "README.md non trouvé"
    fi

    # Mettre à jour le fichier de configuration du projet Flutter
    if [ -f "flutter_app/lib/config/project_config.dart" ]; then
        print_info "Mise à jour de la configuration Flutter..."
        sed -i "s/projectName = 'yeb_app_template'/projectName = '$PROJECT_NAME'/g" flutter_app/lib/config/project_config.dart
        print_success "Fichier de configuration Flutter mis à jour"
    else
        print_warning "flutter_app/lib/config/project_config.dart non trouvé"
    fi

    print_success "Personnalisation terminée"
}

# Exécuter le script d'installation du projet (VERSION CORRIGÉE)
run_setup_script() {
    print_header "Installation du projet"

    echo -e "Exécution du script d'installation..."

    # Rendre les scripts exécutables
    if [ -d "template/entry-points" ]; then
        chmod +x template/entry-points/*.sh 2>/dev/null || true
        print_success "Scripts template/entry-points rendus exécutables"
    fi

    if [ -d "scripts" ]; then
        chmod +x scripts/*.sh 2>/dev/null || true
        print_success "Scripts dans scripts/ rendus exécutables"
    fi

    # Exécuter le script d'installation depuis son répertoire natif
    if [ -f "template/entry-points/setup_project.sh" ]; then
        print_info "Exécution de setup_project.sh..."

        # Changer de répertoire pour exécuter le script dans son contexte
        (
            cd template/entry-points
            ./setup_project.sh
        )

        local setup_exit_code=$?

        if [ $setup_exit_code -eq 0 ]; then
            print_success "Installation terminée avec succès"
        else
            print_warning "L'installation a rencontré des problèmes (code: $setup_exit_code)"
            print_info "Vérifiez les logs ci-dessus pour plus de détails"
        fi
    else
        print_warning "Script setup_project.sh non trouvé, passage à l'étape suivante"
    fi

    # Attendre que tous les processus enfants se terminent
    wait

    # Suppression du dossier template APRÈS exécution complète
    if [ -d "template" ]; then
        print_info "Nettoyage: suppression du dossier template..."
        rm -rf template
        print_success "Dossier template supprimé avec succès"
    fi
}

# Mise à jour des instructions pour GitHub Copilot (VERSION CORRIGÉE)
update_copilot_instructions() {
    print_header "Mise à jour des instructions pour GitHub Copilot"

    echo -e "Mise à jour des instructions pour GitHub Copilot..."

    # Vérifier l'existence des répertoires et fichiers
    if [ -d ".github" ] && [ -f ".github/copilot-instructions.md" ]; then
        print_info "Mise à jour de .github/copilot-instructions.md..."
        sed -i "s/YEB App Template/$PROJECT_NAME/g" .github/copilot-instructions.md
        sed -i "s/yeb_app_template/$PROJECT_NAME/g" .github/copilot-instructions.md
        print_success "Instructions Copilot mises à jour"
    else
        print_warning "Le fichier .github/copilot-instructions.md n'a pas été trouvé"
    fi

    # Mettre à jour les informations dans le fichier de mémoire long terme
    if [ -d ".copilot" ] && [ -f ".copilot/memoire_long_terme.md" ]; then
        print_info "Mise à jour de .copilot/memoire_long_terme.md..."
        sed -i "s/YEB App Template/$PROJECT_NAME/g" .copilot/memoire_long_terme.md
        sed -i "s/yeb_app_template/$PROJECT_NAME/g" .copilot/memoire_long_terme.md
        print_success "Mémoire long terme mise à jour"
    fi

    # NETTOYER les fichiers de session du template (ils ne sont pas pertinents pour le nouveau projet)
    if [ -d ".copilot/sessions" ]; then
        print_info "Suppression des fichiers de session du template..."
        rm -rf .copilot/sessions/*
        print_success "Fichiers de session du template supprimés"
    fi

    # Créer/Vider le fichier chat_resume.md pour un nouveau projet (VERSION MINIMALISTE)
    print_info "Initialisation du fichier .copilot/chat_resume.md..."
    mkdir -p .copilot
    cat > .copilot/chat_resume.md << 'EOL'
<!--
RÉFÉRENCES CROISÉES:
- Ce fichier est référencé dans: [.github/copilot-instructions.md:13, 22, 60, 82, 156, 230, 239, 249]
- Ce fichier est référencé dans: [.copilot/README.md:22, 36]
- Ce fichier est référencé dans: [.copilot/memoire_long_terme.md:84]
-->

# Résumé des sessions de travail avec GitHub Copilot

## Résumé de la conversation sur le projet

Ce document résume les principaux points abordés dans notre conversation sur le développement du projet. Il peut être utilisé pour reprendre une conversation interrompue avec un assistant IA.

**Dernière mise à jour :** [À COMPLÉTER]

## Contexte du projet

- **Projet** : [NOM DU PROJET]
- **Objectif** : [DESCRIPTION DES OBJECTIFS]
- **État actuel** : Initialisation du projet à partir du template yeb_app_template

EOL

    # Remplacer les placeholders avec les vraies valeurs
    sed -i "s/\[NOM DU PROJET\]/$PROJECT_NAME/g" .copilot/chat_resume.md
    sed -i "s/\[DESCRIPTION DES OBJECTIFS\]/$PROJECT_DESCRIPTION/g" .copilot/chat_resume.md
    sed -i "s/\[À COMPLÉTER\]/$(date +"%d %B %Y")/g" .copilot/chat_resume.md

    print_success "chat_resume.md initialisé avec succès (format minimal)"
}

# Créer le dépôt GitHub et pousser le code initial
setup_github_repository() {
    print_header "Configuration du dépôt GitHub"

    # Vérifier si GitHub CLI est installé
    if ! command -v gh &> /dev/null; then
        print_warning "GitHub CLI (gh) n'est pas installé"
        echo -e ""
        echo -e "Pour créer automatiquement un dépôt GitHub, installez GitHub CLI :"
        echo -e "  ${BLUE}https://cli.github.com/${NC}"
        echo -e ""
        echo -e "${YELLOW}Instructions pour créer le dépôt manuellement :${NC}"
        echo -e ""
        echo -e "1. Allez sur ${BLUE}https://github.com/new${NC}"
        echo -e "2. Créez un nouveau dépôt nommé ${GREEN}'$PROJECT_NAME'${NC}"
        echo -e "3. N'initialisez PAS avec README, .gitignore ou licence (déjà présents)"
        echo -e "4. Puis exécutez ces commandes :"
        echo -e ""
        echo -e "   ${GREEN}git remote add origin https://github.com/VOTRE_USERNAME/$PROJECT_NAME.git${NC}"
        echo -e "   ${GREEN}git branch -M main${NC}"
        echo -e "   ${GREEN}git push -u origin main${NC}"
        echo -e ""
        return 1
    fi

    # Vérifier si l'utilisateur est authentifié avec GitHub CLI
    if ! gh auth status &> /dev/null; then
        print_warning "Vous n'êtes pas authentifié avec GitHub CLI"
        echo -e ""
        echo -e "Pour vous authentifier, exécutez :"
        echo -e "  ${GREEN}gh auth login${NC}"
        echo -e ""
        echo -e "Voulez-vous créer le dépôt GitHub manuellement plus tard ? (o/N)"
        read -p "> " skip_github
        if [[ "$skip_github" =~ ^[oO]$ ]]; then
            print_info "Création du dépôt GitHub ignorée"
            return 1
        else
            print_info "Lancement de l'authentification GitHub CLI..."
            gh auth login
            if [ $? -ne 0 ]; then
                print_error "Échec de l'authentification"
                return 1
            fi
        fi
    fi

    print_success "Authentification GitHub vérifiée"

    # Demander confirmation pour créer le dépôt
    echo -e ""
    echo -e "Voulez-vous créer un dépôt GitHub pour ${GREEN}$PROJECT_NAME${NC} ? (o/N)"
    read -p "> " create_repo

    if [[ ! "$create_repo" =~ ^[oO]$ ]]; then
        print_info "Création du dépôt GitHub ignorée"
        echo -e ""
        echo -e "${YELLOW}Pour créer le dépôt plus tard, exécutez :${NC}"
        echo -e "  ${GREEN}gh repo create $PROJECT_NAME --public --source=. --push${NC}"
        echo -e ""
        return 1
    fi

    # Demander si le dépôt doit être public ou privé
    echo -e ""
    echo -e "Le dépôt doit-il être ${GREEN}public${NC} ou ${YELLOW}privé${NC} ? (public/privé)"
    read -p "> " repo_visibility

    local visibility_flag="--public"
    if [[ "$repo_visibility" =~ ^[pP]riv ]]; then
        visibility_flag="--private"
        print_info "Le dépôt sera privé"
    else
        print_info "Le dépôt sera public"
    fi

    # Description optionnelle
    local description_flag=""
    if [ -n "$PROJECT_DESCRIPTION" ]; then
        description_flag="--description \"$PROJECT_DESCRIPTION\""
    fi

    # Créer le dépôt GitHub
    print_info "Création du dépôt GitHub '$PROJECT_NAME'..."

    # Construire la commande
    local gh_command="gh repo create $PROJECT_NAME $visibility_flag --source=. --remote=origin"

    if [ -n "$PROJECT_DESCRIPTION" ]; then
        gh_command="$gh_command --description \"$PROJECT_DESCRIPTION\""
    fi

    # Exécuter la commande
    eval $gh_command

    if [ $? -eq 0 ]; then
        print_success "Dépôt GitHub créé avec succès"

        # Pousser le code initial
        print_info "Envoi du code initial vers GitHub..."

        # Renommer la branche en main si nécessaire
        current_branch=$(git branch --show-current)
        if [ "$current_branch" != "main" ]; then
            git branch -M main
        fi

        # Pousser vers GitHub
        git push -u origin main

        if [ $? -eq 0 ]; then
            print_success "Code initial poussé vers GitHub"

            # Afficher l'URL du dépôt
            repo_url=$(gh repo view --json url -q .url 2>/dev/null)
            if [ -n "$repo_url" ]; then
                echo -e ""
                echo -e "${GREEN}✨ Votre dépôt est disponible à :${NC}"
                echo -e "   ${BLUE}$repo_url${NC}"
                echo -e ""
            fi
        else
            print_warning "Échec du push initial. Vous pouvez le faire manuellement avec :"
            echo -e "   ${GREEN}git push -u origin main${NC}"
        fi
    else
        print_error "Échec de la création du dépôt GitHub"
        print_info "Vous pouvez créer le dépôt manuellement plus tard"
        return 1
    fi
}

# Afficher les instructions finales (VERSION AMÉLIORÉE)
show_final_instructions() {
    print_header "Félicitations! Votre projet est prêt."

    echo -e "Le projet ${GREEN}$PROJECT_NAME${NC} a été créé et configuré avec succès."
    echo -e ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}Prochaines étapes recommandées :${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    echo -e "  ${YELLOW}1. Documentation${NC}"
    echo -e "     Consultez la documentation dans le dossier ${BLUE}docs/${NC}"
    echo -e ""
    echo -e "  ${YELLOW}2. Lancement de l'application${NC}"
    echo -e "     • Mode développement local : ${GREEN}./run_dev.sh${NC}"
    echo -e "     • Mode web intégré         : ${GREEN}./start_web_integrated.sh${NC}"
    echo -e ""
    echo -e "  ${YELLOW}3. Gestion Git${NC}"
    echo -e "     • Créer une branche de développement : ${GREEN}git checkout -b dev${NC}"
    echo -e "     • Workflow recommandé : développement sur ${GREEN}'dev'${NC}, fusion vers ${GREEN}'main'${NC}"
    echo -e "     • Pour fusionner dev vers main : ${GREEN}./scripts/merge_to_main.sh${NC}"
    echo -e ""
    echo -e "  ${YELLOW}4. Assistance GitHub Copilot${NC}"
    echo -e "     Si vous utilisez VS Code avec GitHub Copilot, demandez à l'assistant de"
    echo -e "     ${GREEN}'lire les fichiers dans .copilot'${NC} pour obtenir de l'aide personnalisée."
    echo -e ""
    echo -e "  ${YELLOW}5. Personnalisation${NC}"
    echo -e "     • Scripts Python : ${BLUE}shared_python/scripts/${NC}"
    echo -e "     • Application Flutter : ${BLUE}flutter_app/lib/${NC}"
    echo -e "     • Configuration : ${BLUE}flutter_app/lib/config/project_config.dart${NC}"
    echo -e ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    echo -e "${GREEN}✨ Bon développement avec $PROJECT_NAME ! ✨${NC}"
    echo -e ""
}

# Fonction principale (VERSION CORRIGÉE)
main() {
    print_header "Création d'un nouveau projet à partir du template yeb_app_template"

    echo -e ""
    echo -e "Ce script va créer un nouveau projet Flutter/Python personnalisé."
    echo -e ""

    # Validation : afficher les étapes qui vont être exécutées
    echo -e "${BLUE}Les étapes suivantes seront exécutées :${NC}"
    echo -e "  1. Vérification des prérequis (Git, curl/wget)"
    echo -e "  2. Configuration du projet (nom, description, auteur)"
    echo -e "  3. Téléchargement du template depuis GitHub"
    echo -e "  4. Personnalisation des fichiers de configuration"
    echo -e "  5. Mise à jour des instructions GitHub Copilot"
    echo -e "  6. Exécution du script d'installation"
    echo -e "  7. Configuration du dépôt GitHub (optionnelle)"
    echo -e "  8. Affichage des instructions finales"
    echo -e ""

    # Étape 1 : Vérification des prérequis
    check_prerequisites

    # Étape 2 : Configuration du projet
    configure_project

    # Étape 3 : Téléchargement du template
    download_template

    # Étape 4 : Personnalisation
    customize_template

    # Étape 5 : Mise à jour des instructions Copilot
    update_copilot_instructions

    # Étape 6 : Exécution du setup
    run_setup_script

    # Étape 7 : Configuration du dépôt GitHub (optionnelle)
    setup_github_repository

    # Étape 8 : Instructions finales
    show_final_instructions
}

# Exécuter la fonction principale
main
