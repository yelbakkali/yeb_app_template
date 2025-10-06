#!/bin/bash

# ==========================================================================
# RÉFÉRENCES CROISÉES:
# - Ce fichier est créé pour tester automatiquement le processus d'installation
# ==========================================================================

# Script de test pour valider le processus d'installation
# Ce script vérifie la présence et le bon fonctionnement des dépendances requises

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Variables pour le suivi des tests
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
WARNINGS=0

# Fonctions utilitaires
echo_info() {
    echo -e "${BLUE}${BOLD}[INFO]${NC} $1"
}

echo_success() {
    echo -e "${GREEN}${BOLD}[SUCCÈS]${NC} $1"
}

echo_warning() {
    echo -e "${YELLOW}${BOLD}[AVERTISSEMENT]${NC} $1"
    ((WARNINGS++))
}

echo_error() {
    echo -e "${RED}${BOLD}[ERREUR]${NC} $1"
}

# Fonction pour tester une dépendance
test_dependency() {
    local name=$1
    local command=$2
    local test_args=$3
    local expected_status=$4

    ((TOTAL_TESTS++))

    echo -e "\n${BOLD}Test #$TOTAL_TESTS: Vérification de $name${NC}"

    if ! command -v $command &> /dev/null; then
        echo_error "$name non trouvé"
        echo "  → Le programme '$command' n'est pas disponible dans le PATH"
        ((FAILED_TESTS++))
        return 1
    fi

    if [ -n "$test_args" ]; then
        echo_info "Vérification de la version/fonctionnalité..."

        # Exécuter la commande de test avec les arguments fournis
        eval "$command $test_args" > /tmp/test_output_$TOTAL_TESTS.log 2>&1
        local exit_code=$?

        if [ $exit_code -eq $expected_status ]; then
            echo_success "$name installé et fonctionnel"
            echo "  → Version: $(head -n 1 /tmp/test_output_$TOTAL_TESTS.log)"
            ((PASSED_TESTS++))
            return 0
        else
            echo_error "$name est installé mais le test de fonctionnalité a échoué"
            echo "  → Statut de retour: $exit_code (attendu: $expected_status)"
            echo "  → Détails: $(head -n 3 /tmp/test_output_$TOTAL_TESTS.log)"
            ((FAILED_TESTS++))
            return 1
        fi
    else
        echo_success "$name trouvé dans le PATH"
        echo "  → Emplacement: $(which $command)"
        ((PASSED_TESTS++))
        return 0
    fi
}

# Fonction pour tester une configuration
test_config() {
    local name=$1
    local config_file=$2
    local test_pattern=$3
    local success_message=$4
    local error_message=$5

    ((TOTAL_TESTS++))

    echo -e "\n${BOLD}Test #$TOTAL_TESTS: Vérification de la configuration $name${NC}"

    if [ ! -f "$config_file" ]; then
        echo_error "Fichier de configuration '$config_file' non trouvé"
        ((FAILED_TESTS++))
        return 1
    fi

    if grep -q "$test_pattern" "$config_file"; then
        echo_success "$success_message"
        ((PASSED_TESTS++))
        return 0
    else
        echo_error "$error_message"
        echo "  → Pattern '$test_pattern' non trouvé dans $config_file"
        ((FAILED_TESTS++))
        return 1
    fi
}

# Fonction pour tester l'environnement Python Poetry
test_poetry_env() {
    ((TOTAL_TESTS++))

    echo -e "\n${BOLD}Test #$TOTAL_TESTS: Vérification de l'environnement Poetry${NC}"

    if [ ! -d "shared_python" ]; then
        echo_warning "Dossier shared_python non trouvé, test ignoré"
        return 0
    fi

    cd shared_python

    if ! command -v poetry &> /dev/null; then
        echo_error "Poetry non trouvé dans le PATH"
        cd ..
        ((FAILED_TESTS++))
        return 1
    fi

    # Vérifier si l'environnement virtuel est configuré
    POETRY_ENV_PATH=$(poetry env info --path 2>/dev/null)
    if [ -z "$POETRY_ENV_PATH" ]; then
        echo_error "Environnement virtuel Poetry non configuré"
        cd ..
        ((FAILED_TESTS++))
        return 1
    fi

    echo_success "Environnement Poetry configuré"
    echo "  → Chemin: $POETRY_ENV_PATH"

    # Vérifier si les packages de base sont installés
    if [ -f "$POETRY_ENV_PATH/bin/pytest" ]; then
        echo_success "Package pytest trouvé dans l'environnement virtuel"
    else
        echo_warning "Package pytest non trouvé dans l'environnement virtuel"
    fi

    cd ..
    ((PASSED_TESTS++))
    return 0
}

# Fonction pour tester la configuration VS Code
test_vscode_config() {
    ((TOTAL_TESTS++))

    echo -e "\n${BOLD}Test #$TOTAL_TESTS: Vérification de la configuration VS Code${NC}"

    if [ ! -d ".vscode" ]; then
        echo_warning "Dossier .vscode non trouvé, test ignoré"
        return 0
    fi

    if [ ! -f ".vscode/settings.json" ]; then
        echo_error "Fichier .vscode/settings.json non trouvé"
        ((FAILED_TESTS++))
        return 1
    fi

    # Vérifier si Python est configuré
    if grep -q "\"python.defaultInterpreterPath\"" ".vscode/settings.json"; then
        echo_success "Interpréteur Python configuré dans VS Code"
    else
        echo_warning "Interpréteur Python non configuré dans VS Code"
    fi

    # Vérifier si les chemins d'analyse Python sont configurés
    if grep -q "\"python.analysis.extraPaths\"" ".vscode/settings.json"; then
        echo_success "Chemins d'analyse Python configurés dans VS Code"
    else
        echo_warning "Chemins d'analyse Python non configurés dans VS Code"
    fi

    ((PASSED_TESTS++))
    return 0
}

# Fonction principale
main() {
    echo_info "Démarrage des tests d'installation..."
    echo_info "Détection de l'environnement: $(uname -s) $(uname -r)"
    echo "-------------------------------------------"

    # Tester les dépendances de base
    test_dependency "Git" "git" "--version" 0
    test_dependency "Python" "python3" "--version" 0
    test_dependency "pip" "pip3" "--version" 0
    test_dependency "Poetry" "poetry" "--version" 0

    # Tester les dépendances Flutter
    test_dependency "Flutter" "flutter" "--version" 0
    test_dependency "Dart" "dart" "--version" 0

    # Tester VS Code
    test_dependency "VS Code" "code" "--version" 0

    # Tester l'environnement Poetry
    test_poetry_env

    # Tester la configuration VS Code
    test_vscode_config

    # Si on est sur macOS, tester les spécificités macOS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        test_dependency "Homebrew" "brew" "--version" 0

        # Tester la présence de CocoaPods si Xcode est installé
        if [ -d "/Applications/Xcode.app" ]; then
            test_dependency "CocoaPods" "pod" "--version" 0
        fi
    fi

    # Si on est sur Windows via WSL, vérifier les configurations WSL
    if grep -q Microsoft /proc/version 2>/dev/null || grep -q microsoft /proc/version 2>/dev/null; then
        echo -e "\n${BOLD}Tests WSL spécifiques${NC}"

        # Vérifier si la commande 'code' fonctionne dans WSL
        if command -v code &> /dev/null; then
            echo_success "La commande 'code' est disponible dans WSL"
        else
            echo_warning "La commande 'code' n'est pas disponible dans WSL"
        fi
    fi

    # Afficher le résumé des tests
    echo -e "\n${BOLD}================================${NC}"
    echo -e "${BOLD}       RÉSUMÉ DES TESTS         ${NC}"
    echo -e "${BOLD}================================${NC}"
    echo -e "Tests exécutés:     ${BOLD}$TOTAL_TESTS${NC}"
    echo -e "Tests réussis:      ${GREEN}${BOLD}$PASSED_TESTS${NC}"
    echo -e "Tests échoués:      ${RED}${BOLD}$FAILED_TESTS${NC}"
    echo -e "Avertissements:     ${YELLOW}${BOLD}$WARNINGS${NC}"
    echo -e "${BOLD}================================${NC}"

    # Déterminer le succès global
    if [ $FAILED_TESTS -eq 0 ]; then
        if [ $WARNINGS -eq 0 ]; then
            echo_success "Tous les tests ont réussi!"
        else
            echo_warning "Tests réussis avec $WARNINGS avertissements."
        fi
        return 0
    else
        echo_error "$FAILED_TESTS test(s) ont échoué."
        return 1
    fi
}

# Exécuter la fonction principale
main
