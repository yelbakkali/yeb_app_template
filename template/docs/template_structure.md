# Structure du dossier template

Ce document explique l'organisation et la structure du dossier `template/` dans le projet YEB App Template.

## Vue d'ensemble

Le dossier `template/` contient tous les fichiers nécessaires à l'initialisation d'un nouveau projet basé sur YEB App Template. Il est organisé de manière à séparer clairement les points d'entrée (scripts principaux) des utilitaires (scripts auxiliaires).

La structure est la suivante :

```plaintext
template/
├── entry-points/     # Points d'entrée principaux pour l'initialisation du projet
│   ├── bootstrap.sh
│   ├── init_project.bat
│   ├── init_project.sh
│   ├── setup_project.bat
│   └── setup_project.sh
├── utils/            # Scripts utilitaires appelés par les points d'entrée
│   ├── check_prerequisites.bat
│   ├── check_prerequisites.sh
│   ├── cleanup_init_files.bat
│   ├── cleanup_init_files.sh
│   ├── configure_vscode_for_flutter.bat
│   └── configure_vscode_for_flutter.sh
└── docs/             # Documentation spécifique au template
    └── copilot/
        └── template_initialization.md
```

## Points d'entrée (`entry-points/`)

Ce dossier contient les scripts principaux qui servent de points d'entrée pour l'initialisation du projet :

1. **bootstrap.sh** - Script autonome qui télécharge le template et configure un nouveau projet
2. **init_project.sh / init_project.bat** - Scripts d'initialisation du projet (renommage, configuration)
3. **setup_project.sh / setup_project.bat** - Scripts d'installation tout-en-un qui vérifient les prérequis et lancent l'initialisation

## Utilitaires (`utils/`)

Ce dossier contient des scripts auxiliaires qui sont appelés par les points d'entrée :

1. **check_prerequisites.sh / check_prerequisites.bat** - Vérifient que les dépendances nécessaires sont installées
2. **cleanup_init_files.sh / cleanup_init_files.bat** - Suppriment les fichiers d'initialisation après usage
3. **configure_vscode_for_flutter.sh / configure_vscode_for_flutter.bat** - Configurent VS Code pour Flutter

## Documentation du template (`docs/`)

Ce dossier contient la documentation spécifique au template et aux instructions d'initialisation.

## Relations entre les scripts

Les scripts de points d'entrée font appel aux scripts utilitaires selon le schéma suivant :

- `bootstrap.sh` → télécharge le template et lance `setup_project.sh`
- `setup_project.sh` → appelle `check_prerequisites.sh` puis `init_project.sh`
- `init_project.sh` → appelle `check_prerequisites.sh`, `configure_vscode_for_flutter.sh`, etc.

## Initialisation d'un nouveau projet

Pour initialiser un nouveau projet, utilisez l'un des points d'entrée suivants :

1. **Méthode autonome** : Exécutez `bootstrap.sh` qui téléchargera le template et lancera la configuration
2. **Méthode après clonage** : Après avoir cloné le dépôt, exécutez `setup_project.sh` (Linux/macOS) ou `setup_project.bat` (Windows)
3. **Méthode manuelle** : Exécutez directement `init_project.sh` (Linux/macOS) ou `init_project.bat` (Windows) si les prérequis sont déjà installés

## Chemins relatifs

Les scripts utilisent des chemins relatifs pour se référencer entre eux :

- Les scripts dans `entry-points/` référencent les scripts dans `utils/` via `../utils/`
- Tous les scripts utilisent des chemins relatifs pour accéder aux fichiers du projet

Cette organisation permet d'assurer la portabilité du template et sa facilité d'utilisation sur différentes plateformes.
