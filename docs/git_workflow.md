# Guide du workflow Git pour 737calcs

Ce document décrit le workflow Git recommandé pour le développement de l'application 737calcs.

## Structure des branches

Le projet utilise deux branches principales :

- **main** : Branche de production stable
- **dev** : Branche de développement

## Règles générales

1. La branche **main** ne reçoit jamais directement de commits
2. Tout développement se fait sur **dev** ou sur des branches de fonctionnalités
3. Les fusions vers **main** se font uniquement par pull request après tests

## Workflow pour les développeurs

### 1. Commencer un travail

Assurez-vous toujours d'avoir la dernière version de la branche dev :

```bash
git checkout dev
git pull origin dev
```

### 2. Développer une nouvelle fonctionnalité

Pour une fonctionnalité significative, créez une branche dédiée :

```bash
git checkout -b feature/nom-de-ma-fonctionnalite dev
```

### 3. Effectuer des commits réguliers

Faites des commits atomiques avec des messages descriptifs :

```bash
git add .
git commit -m "Description claire de la modification"
```

### 4. Pousser vers le dépôt distant

```bash
git push -u origin feature/nom-de-ma-fonctionnalite
```

### 5. Fusionner vers dev

Une fois la fonctionnalité terminée :

```bash
git checkout dev
git pull origin dev
git merge feature/nom-de-ma-fonctionnalite
git push origin dev
```

### 6. Déploiement en production

Lorsque la branche **dev** est stable et prête pour la production :

```bash
git checkout main
git pull origin main
git merge dev
git push origin main
git tag -a v1.x.x -m "Version 1.x.x"
git push origin v1.x.x
```

## Gestion des bugs

Pour corriger un bug critique en production :

```bash
git checkout -b hotfix/description-du-bug main
# Correction du bug
git checkout main
git merge hotfix/description-du-bug
git push origin main
git checkout dev
git merge main  # Pour avoir la correction aussi dans dev
git push origin dev
```

## Conventions de nommage

- Branches de fonctionnalités : `feature/nom-explicite`
- Branches de correctifs : `hotfix/description-bug`
- Branches de refactoring : `refactor/description`
- Tags de version : `v1.x.x` (suivant [SemVer](https://semver.org/))

## Outils Git recommandés

- [GitKraken](https://www.gitkraken.com/) - Interface graphique
- [GitLens](https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens) - Extension VS Code
- [Commitizen](https://github.com/commitizen/cz-cli) - Pour des commits standardisés
