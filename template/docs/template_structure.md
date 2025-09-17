# Structure du dossier template

Ce document explique l'organisation et la structure du dossier `template/` dans le projet YEB App Template.

## Vue d'ensemble

Le dossier `template/` contient tous les fichiers nécessaires à l'initialisation d'un nouveau projet basé sur YEB App Template. Il est organisé de manière à séparer clairement les points d'entrée (scripts principaux) des utilitaires (scripts auxiliaires).

La structure est la suivante :

```plaintext
template/
├── entry-points/     # Points d'entrée principaux pour l'initialisation du projet
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

Ce dossier contient les scripts principaux qui servent de points d'entrée pour l'initialisation du projet. Ces scripts sont appelés par le script `setup_template.sh` à la racine du projet.

**Note:** Le script `setup_template.sh` à la racine du projet est le point d'entrée principal pour initialiser un nouveau projet à partir du template.

## Utilitaires (`utils/`)

Ce dossier contient des scripts auxiliaires qui sont appelés par les points d'entrée :

1. **check_prerequisites.sh / check_prerequisites.bat** - Vérifient que les dépendances nécessaires sont installées
2. **cleanup_init_files.sh / cleanup_init_files.bat** - Suppriment les fichiers d'initialisation après usage
3. **configure_vscode_for_flutter.sh / configure_vscode_for_flutter.bat** - Configurent VS Code pour Flutter

## Documentation du template (`docs/`)

Ce dossier contient la documentation spécifique au template et aux instructions d'initialisation.

## Relations entre les scripts

Les scripts font appel les uns aux autres selon le schéma suivant :

- `setup_template.sh` (à la racine) → télécharge le template et lance les scripts dans `template/entry-points/`
- Les scripts dans `entry-points/` → appellent les utilitaires dans `utils/` comme `check_prerequisites.sh`, `configure_vscode_for_flutter.sh`, etc.

## Initialisation d'un nouveau projet

Pour initialiser un nouveau projet, utilisez la méthode suivante :

1. Créez un dossier avec le nom de votre projet
2. Téléchargez le script `setup_template.sh`
3. Exécutez `setup_template.sh` qui téléchargera le template et lancera la configuration

## Chemins relatifs

Les scripts utilisent des chemins relatifs pour se référencer entre eux :

- Les scripts dans `entry-points/` référencent les scripts dans `utils/` via `../utils/`
- Tous les scripts utilisent des chemins relatifs pour accéder aux fichiers du projet

Cette organisation permet d'assurer la portabilité du template et sa facilité d'utilisation sur différentes plateformes.
