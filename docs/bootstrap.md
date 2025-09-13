# Script Bootstrap pour yeb_app_template

Ce script autonome (`bootstrap.sh`) vous permet de créer rapidement un nouveau projet basé sur le template yeb_app_template.

## Fonctionnalités du script

- Télécharge automatiquement le template depuis GitHub
- Configure un nouveau projet avec le nom de votre choix
- Personnalise tous les fichiers de configuration nécessaires
- Initialise un nouveau dépôt Git
- Configure des instructions spéciales pour GitHub Copilot
- Exécute le script d'installation du projet

## Utilisation

1. Téléchargez uniquement ce script bootstrap:

```bash
curl -O https://raw.githubusercontent.com/yelbakkali/yeb_app_template/dev/bootstrap.sh
chmod +x bootstrap.sh
```

1. Exécutez le script:

```bash
./bootstrap.sh
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
- Vous assister de manière plus pertinente

Une fois le projet créé, vous pouvez simplement ouvrir VS Code et demander à GitHub Copilot de vous assister. Il sera déjà familiarisé avec votre projet.

## Prérequis

Le script vérifie automatiquement si vous avez les outils nécessaires:

- Git
- curl ou wget

## Remarque

Ce bootstrap est la méthode recommandée pour démarrer un nouveau projet à partir du template yeb_app_template, car il configure tout correctement et automatiquement.
