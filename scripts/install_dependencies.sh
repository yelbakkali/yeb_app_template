#!/bin/bash

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
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
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

echo -e "\n${GREEN}===============================================${NC}"
echo -e "${GREEN}   INSTALLATION DES DÉPENDANCES TERMINÉE       ${NC}"
echo -e "${GREEN}===============================================${NC}"
echo -e "Si des erreurs sont apparues, vérifiez que les outils suivants sont bien installés :"
echo -e "- Flutter/Dart"
echo -e "- Poetry (pour Python) ou pip"
echo -e "\nVous pouvez maintenant travailler sur le projet!"