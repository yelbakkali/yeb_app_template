#!/bin/bash
# ==========================================================================
# RÉFÉRENCES CROISÉES:
# - Ce fichier est référencé dans: [template/entry-points/init_project.sh:476, 478, 479]
# ==========================================================================

# Script pour installer toutes les dépendances nécessaires
# pour le projet yeb_app_template
# Ce script installe les dépendances Dart/Flutter et Python

set -e  # Arrête le script en cas d'erreur

# Couleurs pour l'affichage
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}===============================================${NC}"
echo -e "${YELLOW}   INSTALLATION DES DÉPENDANCES DU PROJET      ${NC}"
echo -e "${YELLOW}===============================================${NC}"

# Chemin du répertoire racine du projet
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$PROJECT_ROOT"

echo -e "\n${GREEN}1. Installation des dépendances Flutter/Dart${NC}"

# Installation des dépendances Flutter/Dart au niveau projet
echo -e "${YELLOW}Installation des dépendances Flutter/Dart au niveau projet...${NC}"
flutter pub get || {
  echo -e "${RED}Échec de l'installation des dépendances Flutter/Dart au niveau projet.${NC}"
  echo -e "${YELLOW}Tentative d'installation uniquement dans le dossier flutter_app...${NC}"
}

# Installation des dépendances Flutter/Dart dans le répertoire flutter_app
echo -e "${YELLOW}Installation des dépendances Flutter/Dart dans le dossier flutter_app...${NC}"
cd "$PROJECT_ROOT/flutter_app"
flutter pub get || {
  echo -e "${RED}Échec de l'installation des dépendances Flutter/Dart dans le dossier flutter_app.${NC}"
  echo -e "${YELLOW}Vérifiez que Flutter est correctement installé.${NC}"
}
cd "$PROJECT_ROOT"

echo -e "\n${GREEN}2. Installation des dépendances Python${NC}"

# Installation des dépendances Python dans web_backend
echo -e "${YELLOW}Installation des dépendances Python dans web_backend...${NC}"
cd "$PROJECT_ROOT/web_backend"
if command -v poetry &> /dev/null; then
  poetry install || {
    echo -e "${RED}Échec de l'installation des dépendances Python avec Poetry dans web_backend.${NC}"
    if [ -f requirements.txt ]; then
      echo -e "${YELLOW}Tentative d'installation avec pip...${NC}"
      pip install -r requirements.txt || {
        echo -e "${RED}Échec de l'installation des dépendances Python avec pip dans web_backend.${NC}"
      }
    fi
  }
else
  if [ -f requirements.txt ]; then
    echo -e "${YELLOW}Poetry non trouvé, utilisation de pip...${NC}"
    pip install -r requirements.txt || {
      echo -e "${RED}Échec de l'installation des dépendances Python avec pip dans web_backend.${NC}"
    }
  else
    echo -e "${RED}Poetry non trouvé et requirements.txt inexistant dans web_backend.${NC}"
  fi
fi
cd "$PROJECT_ROOT"

# Installation des dépendances Python dans python_backend si le dossier existe
if [ -d "$PROJECT_ROOT/python_backend" ]; then
  echo -e "${YELLOW}Installation des dépendances Python dans python_backend...${NC}"
  cd "$PROJECT_ROOT/python_backend"
  if command -v poetry &> /dev/null; then
    poetry install || {
      echo -e "${RED}Échec de l'installation des dépendances Python avec Poetry dans python_backend.${NC}"
      if [ -f requirements.txt ]; then
        echo -e "${YELLOW}Tentative d'installation avec pip...${NC}"
        pip install -r requirements.txt || {
          echo -e "${RED}Échec de l'installation des dépendances Python avec pip dans python_backend.${NC}"
        }
      fi
    }
  else
    if [ -f requirements.txt ]; then
      echo -e "${YELLOW}Poetry non trouvé, utilisation de pip...${NC}"
      pip install -r requirements.txt || {
        echo -e "${RED}Échec de l'installation des dépendances Python avec pip dans python_backend.${NC}"
      }
    else
      echo -e "${RED}Poetry non trouvé et requirements.txt inexistant dans python_backend.${NC}"
    fi
  fi
  cd "$PROJECT_ROOT"
fi

echo -e "\n${GREEN}3. Installation des extensions VS Code recommandées${NC}"
# Vérifie si la commande code est disponible (VS Code installé)
if command -v code &> /dev/null; then
  echo -e "${YELLOW}Installation des extensions VS Code recommandées...${NC}"

  # Extensions Flutter/Dart
  code --install-extension dart-code.dart-code || echo -e "${RED}Échec de l'installation de dart-code.dart-code${NC}"
  code --install-extension dart-code.flutter || echo -e "${RED}Échec de l'installation de dart-code.flutter${NC}"
  code --install-extension nash.awesome-flutter-snippets || echo -e "${RED}Échec de l'installation de nash.awesome-flutter-snippets${NC}"

  # Extensions Python
  code --install-extension ms-python.python || echo -e "${RED}Échec de l'installation de ms-python.python${NC}"
  code --install-extension ms-python.vscode-pylance || echo -e "${RED}Échec de l'installation de ms-python.vscode-pylance${NC}"
  code --install-extension ms-python.black-formatter || echo -e "${RED}Échec de l'installation de ms-python.black-formatter${NC}"
  code --install-extension njpwerner.autodocstring || echo -e "${RED}Échec de l'installation de njpwerner.autodocstring${NC}"
  code --install-extension matangover.mypy || echo -e "${RED}Échec de l'installation de matangover.mypy${NC}"

  # Linters et formatage
  code --install-extension streetsidesoftware.code-spell-checker || echo -e "${RED}Échec de l'installation de streetsidesoftware.code-spell-checker${NC}"
  code --install-extension esbenp.prettier-vscode || echo -e "${RED}Échec de l'installation de esbenp.prettier-vscode${NC}"

  # Git et Collaboration
  code --install-extension github.vscode-pull-request-github || echo -e "${RED}Échec de l'installation de github.vscode-pull-request-github${NC}"
  code --install-extension eamodio.gitlens || echo -e "${RED}Échec de l'installation de eamodio.gitlens${NC}"

  # Productivité
  code --install-extension github.copilot || echo -e "${RED}Échec de l'installation de github.copilot${NC}"
  code --install-extension github.copilot-chat || echo -e "${RED}Échec de l'installation de github.copilot-chat${NC}"
  code --install-extension ms-vsliveshare.vsliveshare || echo -e "${RED}Échec de l'installation de ms-vsliveshare.vsliveshare${NC}"

  # Fonctionnalités natives
  code --install-extension ms-vscode.cpptools || echo -e "${RED}Échec de l'installation de ms-vscode.cpptools${NC}"

  echo -e "${GREEN}Installation des extensions VS Code terminée.${NC}"
else
  echo -e "${YELLOW}La commande 'code' n'est pas disponible dans le PATH.${NC}"
  echo -e "${YELLOW}Pour installer les extensions VS Code recommandées, assurez-vous que VS Code est installé${NC}"
  echo -e "${YELLOW}et que la commande 'code' est disponible dans votre PATH.${NC}"
  echo -e "${YELLOW}Vous pouvez également installer les extensions manuellement depuis VS Code.${NC}"
  echo -e "${YELLOW}Les extensions recommandées sont listées dans .vscode/extensions.json${NC}"
fi

echo -e "\n${GREEN}===============================================${NC}"
echo -e "${GREEN}   INSTALLATION DES DÉPENDANCES TERMINÉE       ${NC}"
echo -e "${GREEN}===============================================${NC}"
echo -e "Si des erreurs sont apparues, vérifiez que les outils suivants sont bien installés :"
echo -e "- Flutter/Dart"
echo -e "- Poetry (pour Python) ou pip"
echo -e "- VS Code (pour les extensions recommandées)"
echo -e "\nVous pouvez maintenant travailler sur le projet!"