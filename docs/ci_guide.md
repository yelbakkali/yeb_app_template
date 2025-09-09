# Guide CI/CD - Flutter/Python

Ce document décrit la configuration CI/CD mise en place pour ce projet et comment résoudre les problèmes courants.

## Workflows GitHub Actions

### 1. Flutter/Python CI (`flutter_python_ci.yml`)

Ce workflow vérifie :

- Le formatage et l'analyse du code Flutter
- L'exécution des tests Flutter
- L'exécution des tests Python pour `python_backend` et `web_backend`

#### Jobs

- **Test Flutter** : Vérifie le code Flutter, incluant formatage, analyse et tests
- **Test Python** : Vérifie le code Python des deux backends, incluant les tests

### 2. Template Config (`template_config.yml`)

Ce workflow configure les paramètres du template GitHub.

## Problèmes courants et solutions

### Flutter

1. **Erreurs de formatage** :
   - Utiliser `flutter format .` pour formater le code
   - Dans le CI, nous utilisons `--no-fatal-infos --no-fatal-warnings` pour éviter les échecs sur les avertissements

2. **Assets manquants** :
   - Vérifier que les répertoires d'assets dans `pubspec.yaml` existent
   - Utiliser des fichiers `.gitkeep` pour maintenir la structure des répertoires vides

### Python avec Poetry

1. **Erreurs de synchronisation du fichier lock** :
   - Exécuter `poetry lock` pour mettre à jour le fichier lock
   - Le workflow CI inclut cette étape automatiquement

2. **Commandes Poetry non trouvées** :
   - Assurez-vous que Poetry est dans le PATH avec `echo "$HOME/.local/bin" >> $GITHUB_PATH`
   - Vérifiez l'installation avec `which poetry`

3. **Dépendances manquantes** :
   - Utilisez `poetry add <package>` pour ajouter des dépendances
   - Pour les dépendances de développement : `poetry add --group dev <package>`

## Bonnes pratiques

1. **Tests** :
   - Écrire des tests qui ne dépendent pas de services externes
   - Pour Flutter, créer des widgets de test simples qui ne nécessitent pas d'initialisation complexe

2. **Gestion des branches** :
   - Développer sur la branche `dev`
   - Fusionner vers `main` uniquement lorsque tous les tests passent

3. **Commits** :
   - Utiliser des messages de commit conventionnels (feat:, fix:, docs:, ci:, etc.)
   - Inclure des descriptions détaillées pour les changements importants
