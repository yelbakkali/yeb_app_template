<!--
RÉFÉRENCES CROISÉES:
- Ce fichier est référencé dans: [README.md:104, 105, 108, 111, 204]
- Ce fichier est référencé dans: [docs/installation.md:13, 83, 162]
-->

# Script d'initialisation du template yeb_app_template

Ce script autonome (`setup_template.sh`) vous permet de créer rapidement un nouveau projet basé sur le template yeb_app_template.

## Fonctionnalités du script

- Télécharge automatiquement le template depuis GitHub
- Configure un nouveau projet avec le nom de votre choix
- Personnalise tous les fichiers de configuration nécessaires
- Initialise un nouveau dépôt Git
- Configure des instructions spéciales pour GitHub Copilot
- Exécute le script d'installation du projet

## Utilisation

1. Téléchargez uniquement ce script d'initialisation:

```bash
curl -LJO https://raw.githubusercontent.com/yelbakkali/yeb_app_template/main/setup_template.sh
chmod +x setup_template.sh
```

1. Exécutez le script:

```bash
./setup_template.sh
```

1. Suivez les instructions à l'écran:
   - Entrez le nom de votre projet
   - Fournissez une description
   - Indiquez votre nom/organisation

## Intégration avec GitHub Copilot

Le script crée automatiquement des instructions spéciales pour GitHub Copilot dans le fichier `docs/copilot/bootstrap_instructions.md`. Ces instructions permettent à GitHub Copilot de:

- Lire automatiquement la documentation du projet
- Comprendre la structure et la méthodologie
- S'adapter au contexte spécifique de votre projet

## Options avancées

Le script d'initialisation propose plusieurs options pour personnaliser le processus d'installation:

- Mode silencieux: Utilisez l'option `-s` pour une installation avec des valeurs par défaut
- Spécification du nom de projet: Utilisez l'option `-p nom_projet` pour définir le nom du projet
- Aide: Utilisez l'option `-h` pour afficher l'aide du script
