#!/bin/bash
# ==========================================================================
# RÉFÉRENCES CROISÉES:
# - Ce fichier est référencé dans: [template/bootstrap.sh:203]
# - Ce fichier est référencé dans: [docs/installation.md:131]
# ==========================================================================
# Script d'installation tout-en-un pour le template yeb_app_template

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

# Obtenir le chemin absolu du répertoire du script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$SCRIPT_DIR"

print_header "Installation automatisée du projet"
echo "Ce script va vérifier les prérequis et initialiser votre projet"

# Étape 1: Vérification des prérequis
print_header "Étape 1: Vérification des prérequis"

PREREQ_SCRIPT="${PARENT_DIR}/utils/check_prerequisites.sh"
if [ -f "$PREREQ_SCRIPT" ]; then
    chmod +x "$PREREQ_SCRIPT"
    "$PREREQ_SCRIPT"

    # Si le script de prérequis échoue, demander si l'utilisateur veut continuer
    if [ $? -ne 0 ]; then
        echo -e "${YELLOW}Des prérequis sont manquants. Voulez-vous continuer quand même ? (o/N)${NC}"
        read -p "" -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[oO]$ ]]; then
            echo "Installation annulée. Veuillez installer les prérequis manquants et réessayer."
            exit 1
        fi
    fi
else
    print_error "Script de vérification des prérequis non trouvé"
    exit 1
fi

# Étape 2: Initialisation du projet
print_header "Étape 2: Initialisation du projet"

INIT_SCRIPT="${SCRIPT_DIR}/init_project.sh"
if [ -f "$INIT_SCRIPT" ]; then
    chmod +x "$INIT_SCRIPT"
    "$INIT_SCRIPT"

    if [ $? -ne 0 ]; then
        print_error "Échec de l'initialisation du projet"
        exit 1
    fi
else
    print_error "Script d'initialisation non trouvé"
    exit 1
fi

# Étape 3: Ouverture du projet dans VS Code (si disponible)
print_header "Étape 3: Ouverture du projet dans VS Code"

if command -v code &> /dev/null; then
    echo "Ouverture du projet dans VS Code..."
    code .
    print_success "Projet ouvert dans VS Code"
else
    print_warning "VS Code n'est pas installé ou n'est pas dans le PATH"
    echo "Pour ouvrir le projet manuellement, exécutez 'code .' dans ce dossier"
fi

# Détection de macOS pour configurer automatiquement l'environnement
if [[ "$OSTYPE" == "darwin"* ]]; then
    print_header "Configuration spécifique à macOS"

    # Vérifier si l'architecture est Apple Silicon (M1/M2)
    if [[ $(uname -m) == "arm64" ]]; then
        print_header "Configuration pour Apple Silicon (M1/M2)"

        # Vérifier si Rosetta 2 est déjà installé
        if ! pkgutil --pkg-info=com.apple.pkg.RosettaUpdateAuto &> /dev/null; then
            print_warning "Rosetta 2 n'est pas installé. Installation en cours..."

            # Demander confirmation à l'utilisateur
            echo "Rosetta 2 est nécessaire pour certaines applications x86_64 sur les puces Apple Silicon."
            read -p "Voulez-vous installer Rosetta 2 maintenant? (o/N) " -n 1 -r
            echo

            if [[ $REPLY =~ ^[oO]$ ]]; then
                # Installer Rosetta 2 avec acceptation automatique de la licence
                echo "Installation de Rosetta 2..."
                sudo softwareupdate --install-rosetta --agree-to-license

                if [ $? -eq 0 ]; then
                    print_success "Rosetta 2 installé avec succès"
                else
                    print_error "L'installation de Rosetta 2 a échoué"
                fi
            else
                print_warning "L'installation de Rosetta 2 a été ignorée"
                echo "Si vous rencontrez des problèmes, vous pourrez l'installer plus tard avec :"
                echo "sudo softwareupdate --install-rosetta"
            fi
        else
            print_success "Rosetta 2 est déjà installé"
        fi

        # Configuration automatique de Flutter pour Apple Silicon
        echo "Configuration automatique de Flutter pour Apple Silicon..."

        # Rendre le script wrapper exécutable
        FLUTTER_WRAPPER="${SCRIPT_DIR}/../scripts/flutter_wrapper_macos.sh"
        if [ -f "$FLUTTER_WRAPPER" ]; then
            chmod +x "$FLUTTER_WRAPPER"
            print_success "Script wrapper Flutter pour macOS configuré"

            # Créer un répertoire bin local dans le projet
            mkdir -p "${SCRIPT_DIR}/bin"

            # Créer un lien symbolique vers notre wrapper
            ln -sf "$FLUTTER_WRAPPER" "${SCRIPT_DIR}/bin/flutter"

            # Instructions pour utiliser le wrapper
            echo "Un wrapper Flutter a été configuré pour gérer automatiquement l'architecture."
            echo "Pour l'utiliser :"
            echo "1. Ajoutez ce répertoire à votre PATH : export PATH=\"${SCRIPT_DIR}/bin:\$PATH\""
            echo "2. Pour forcer l'exécution native : FLUTTER_FORCE_NATIVE=1 flutter <commande>"

            # Proposer d'ajouter le répertoire bin au PATH dans le profil
            read -p "Voulez-vous ajouter le répertoire bin au PATH dans votre profil? (o/N) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[oO]$ ]]; then
                # Détecter le shell actuel et mettre à jour le profil approprié
                CURRENT_SHELL=$(basename "$SHELL")
                case "$CURRENT_SHELL" in
                    bash)
                        PROFILE_FILE="$HOME/.bash_profile"
                        if [ ! -f "$PROFILE_FILE" ]; then
                            PROFILE_FILE="$HOME/.profile"
                        fi
                        ;;
                    zsh)
                        PROFILE_FILE="$HOME/.zshrc"
                        ;;
                    *)
                        PROFILE_FILE="$HOME/.profile"
                        ;;
                esac

                echo "" >> "$PROFILE_FILE"
                echo "# Ajout du répertoire bin de ${PROJECT_NAME} au PATH" >> "$PROFILE_FILE"
                echo "export PATH=\"${SCRIPT_DIR}/bin:\$PATH\"" >> "$PROFILE_FILE"
                print_success "Chemin ajouté à $PROFILE_FILE"
                echo "Redémarrez votre terminal ou exécutez 'source $PROFILE_FILE' pour appliquer les changements."
            fi
        else
            print_warning "Script wrapper Flutter introuvable"
            echo "Pour une expérience optimale avec Flutter sur Apple Silicon :"
            echo "- Si vous rencontrez des problèmes avec Flutter, utilisez la commande :"
            echo "  arch -x86_64 flutter <commande>"
        fi
    fi

    # Vérifier la présence de XCode (nécessaire pour le développement iOS)
    if ! command -v xcodebuild &> /dev/null; then
        print_warning "XCode ne semble pas être installé"
        echo "Pour le développement iOS, il est recommandé d'installer XCode depuis l'App Store"
    else
        print_success "XCode est installé"
    fi

    # Vérifier les outils de ligne de commande XCode
    if ! xcode-select -p &> /dev/null; then
        print_warning "Les outils de ligne de commande XCode ne semblent pas être installés"
        echo "Exécutez la commande suivante pour les installer :"
        echo "xcode-select --install"
    else
        print_success "Outils de ligne de commande XCode installés"
    fi
fi

print_header "Installation terminée avec succès !"
echo "Votre projet est maintenant configuré et prêt à l'emploi."
echo
echo "Pour lancer l'application en développement :"
echo "  - Mode local : ./run_dev.sh"
echo "  - Mode web   : ./start_web_integrated.sh"
echo
echo "Pour plus d'informations, consultez la documentation dans le dossier 'docs/'."
print_success "Bon développement !"
