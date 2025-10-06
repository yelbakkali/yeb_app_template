<!--
RÉFÉRENCES CROISÉES:
- Ce fichier documente les nouvelles fonctionnalités de vérification Git et création de dépôt GitHub
-->

# Vérification Git et Création Automatique de Dépôt GitHub

## Introduction

Ce document décrit les nouvelles fonctionnalités de vérification de la configuration Git et de création automatique de dépôt GitHub ajoutées au template. Ces fonctionnalités sont disponibles sur toutes les plateformes (Linux/WSL, macOS et Windows).

## Fonctionnalités

### 1. Vérification et Configuration Git

Le système vérifie automatiquement si Git est correctement configuré lors de l'installation du template et aide l'utilisateur à le configurer si nécessaire. Il vérifie et configure :

- **user.name** : Le nom d'utilisateur global pour Git
- **user.email** : L'adresse email globale pour Git
- **init.defaultBranch** : Configuration de la branche par défaut à "main"

### 2. Création Automatique de Dépôt GitHub

Une nouvelle fonctionnalité permet de créer automatiquement un dépôt GitHub et de le connecter au projet local. Cette fonctionnalité :

- Crée un nouveau dépôt GitHub (public ou privé au choix de l'utilisateur)
- Configure le remote "origin" pour pointer vers ce dépôt
- Pousse la branche principale "main" vers GitHub
- Crée et pousse une branche de développement "dev"

## Utilisation

### Pendant l'Installation du Template

Les scripts d'installation (`setup_macos.sh`, `setup_wsl.sh`, `setup_windows.bat`) incluent désormais ces vérifications et proposent ces fonctionnalités automatiquement.

### Utilisation Manuelle

Les scripts peuvent également être exécutés séparément :

**Sur Linux/macOS :**

```bash
bash template/utils/git_config_helper.sh
```

**Sur Windows :**

```cmd
template\utils\git_config_helper.bat
```

## Prérequis

Pour la création automatique de dépôt GitHub, l'outil GitHub CLI (`gh`) est nécessaire. Si l'outil n'est pas installé, le script tentera de l'installer ou fournira des instructions pour l'installation manuelle.

## Workflow Recommandé

Le template configure un workflow Git basé sur deux branches principales :

1. **main** : Branche de production stable
2. **dev** : Branche de développement actif

Il est recommandé de développer sur la branche `dev` et de fusionner vers `main` uniquement les fonctionnalités stables et testées, en utilisant le script `scripts/merge_to_main.sh` ou `scripts/merge_to_main.bat`.

## Compatibilité

Cette fonctionnalité est disponible et testée sur :

- Linux/WSL (Ubuntu, Debian)
- macOS (Intel et Apple Silicon)
- Windows
