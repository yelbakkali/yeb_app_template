# Configuration de protection des branches GitHub

Ce document décrit comment configurer la protection des branches dans GitHub pour le projet 737calcs.

## Règles de protection recommandées

### Pour la branche `main`

1. Accédez aux paramètres du dépôt sur GitHub
2. Allez dans "Branches" > "Branch protection rules"
3. Cliquez sur "Add rule"
4. Dans "Branch name pattern", entrez `main`
5. Activez les options suivantes :
   - ✅ Require pull request reviews before merging
   - ✅ Dismiss stale pull request approvals when new commits are pushed
   - ✅ Require status checks to pass before merging
   - ✅ Require branches to be up to date before merging
   - ✅ Include administrators
   - ✅ Restrict who can push to matching branches

### Pour la branche `dev`

1. Créez une nouvelle règle pour la branche `dev`
2. Activez les options suivantes :
   - ✅ Require status checks to pass before merging
   - ✅ Require branches to be up to date before merging
   - ❌ Restrictions moins strictes pour faciliter le développement rapide

## Workflow CI/CD recommandé

Pour renforcer ce modèle de branches, nous recommandons de configurer un workflow GitHub Actions qui :

1. Exécute les tests sur chaque pull request vers `dev` et `main`
2. Construit automatiquement l'application pour chaque plateforme lors d'un merge vers `main`
3. Déploie automatiquement les artefacts de build (APK, IPA, etc.) lors d'un tag de version

## Exemple de fichier GitHub Actions

Créez un fichier `.github/workflows/flutter-ci.yml` avec le contenu suivant :

```yaml
name: Flutter CI

on:
  push:
    branches: [ main, dev ]
  pull_request:
    branches: [ main, dev ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.10.0'
      - name: Install dependencies
        run: |
          cd flutter_app
          flutter pub get
      - name: Run tests
        run: |
          cd flutter_app
          flutter test
```

## Autres bonnes pratiques

- Configurer des vérifications automatiques de formatage du code
- Mettre en place des analyses statiques du code (avec des outils comme SonarQube)
- Automatiser la génération de la documentation
- Configurer des notifications pour les étapes critiques du workflow
