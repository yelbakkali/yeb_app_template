<!--
RÉFÉRENCES CROISÉES:
- Ce fichier ne semble pas être référencé explicitement dans d'autres fichiers du projet
-->

# Gestion des chemins dans le projet

Ce document explique comment les chemins sont gérés automatiquement dans le projet et comment sont traitées les spécificités de chaque plateforme.

## Gestion automatique des chemins

Le projet utilise un système de configuration centralisé qui détecte et configure automatiquement les chemins selon la plateforme. Cette automatisation est implémentée par les mécanismes suivants :

### 1. Configuration d'environnement centralisée

Les fichiers suivants définissent la configuration des chemins :

- `.project_config/env_setup.sh` pour Linux et macOS
- `.project_config/env_setup.bat` pour Windows

Ces fichiers sont chargés automatiquement par tous les scripts de développement et configurent :

- Les chemins des environnements virtuels Python
- Les chemins des outils spécifiques à chaque plateforme
- Les variables d'environnement nécessaires

### 2. Détection automatique de la plateforme

Le système détecte automatiquement :

- Le système d'exploitation (Linux, macOS, Windows)
- Sur macOS : l'architecture (Apple Silicon vs Intel)
- Les environnements virtuels Poetry

### 3. Adaptation aux spécificités de chaque plateforme

#### macOS

- **Homebrew** : Détection et configuration automatique des chemins selon l'architecture
- **Rosetta 2** : Installation automatique sur les Mac avec Apple Silicon (nécessite confirmation)
- **Flutter** : Configuration automatique via un wrapper qui gère les problèmes d'architecture

#### Linux

- Configuration automatique des chemins Python et Poetry
- Installation automatique des dépendances via les gestionnaires de paquets appropriés

#### Windows

- Adaptation des chemins pour les conventions Windows
- Configuration automatique des environnements virtuels Poetry

## Installation de Rosetta 2 sur macOS (Apple Silicon)

Sur les Mac avec Apple Silicon (M1/M2/M3), le script détecte automatiquement l'architecture et propose d'installer Rosetta 2 pour assurer la compatibilité avec les applications x86_64. L'installation nécessite des droits d'administration et se fait avec la commande :

```bash
sudo softwareupdate --install-rosetta --agree-to-license
```

## Flutter sur macOS (Apple Silicon)

Pour Flutter sur Apple Silicon, un script wrapper est automatiquement configuré pour gérer les problèmes de compatibilité :

1. Par défaut, Flutter s'exécute via Rosetta 2 pour une meilleure compatibilité
2. Pour forcer l'exécution native, utilisez la variable d'environnement : `FLUTTER_FORCE_NATIVE=1`

Le wrapper est automatiquement ajouté au PATH lors de l'initialisation du projet.

## Configuration manuelle requise

Dans la plupart des cas, aucune configuration manuelle n'est nécessaire. Les rares exceptions sont :

1. **XCode sur macOS** : L'installation de XCode doit être effectuée manuellement via l'App Store
2. **Droits administrateur** : L'installation de certains outils système peut nécessiter des droits sudo

## Pour les développeurs

Si vous ajoutez de nouveaux outils ou dépendances au projet, suivez ces bonnes pratiques :

1. Utilisez toujours des chemins relatifs au répertoire du projet
2. Détectez la plateforme avant d'utiliser des chemins spécifiques
3. Utilisez la configuration d'environnement centralisée pour les nouveaux chemins
