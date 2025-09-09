# Guide d'installation du projet 737calcs

Ce guide vous aidera à installer et configurer l'environnement de développement pour le projet 737calcs.

## Prérequis

Avant de commencer, assurez-vous d'avoir installé :

- [Flutter](https://docs.flutter.dev/get-started/install) (version 3.35.0 ou supérieure)
- [Python](https://www.python.org/downloads/) (version 3.9 ou supérieure)
- [Poetry](https://python-poetry.org/docs/#installation) (pour la gestion des dépendances Python)
- [Git](https://git-scm.com/downloads)
- [VS Code](https://code.visualstudio.com/download) (recommandé)

## Installation

### 1. Cloner le dépôt

```bash
git clone https://github.com/votre-utilisateur/737calcs.git
cd 737calcs
```

### 2. Configuration Flutter

Assurez-vous que Flutter est correctement installé et configuré :

```bash
flutter doctor
```

Corrigez toutes les erreurs signalées par cette commande avant de continuer.

### 3. Installation des dépendances Flutter

```bash
flutter pub get
```

### 4. Installation des dépendances Python

Pour le backend Python local :

```bash
cd python_backend
poetry install
cd ..
```

Pour le backend Web :

```bash
cd web_backend
poetry install
cd ..
```

### 5. Configuration de l'environnement de développement

#### Pour Linux/macOS

```bash
chmod +x run_dev_environment.sh
./run_dev_environment.sh
```

#### Pour Windows

```bash
run_dev_environment.bat
```

## Lancement de l'application

### Mode développement local

Pour lancer l'application en mode développement local :

```bash
./run_dev.sh  # Linux/macOS
run_dev.bat   # Windows
```

### Mode développement Web

Pour lancer l'application en mode développement Web :

```bash
./start_web_dev.sh  # Linux/macOS
start_web_dev.bat   # Windows
```

## Structure des tests

### Tests Flutter

Les tests Flutter se trouvent dans le dossier `flutter_app/test/`.

Pour exécuter les tests Flutter :

```bash
cd flutter_app
flutter test
```

### Tests Python

Les tests Python se trouvent dans les dossiers `python_backend/tests/` et `web_backend/tests/`.

Pour exécuter les tests Python :

```bash
cd python_backend
poetry run pytest
cd ../web_backend
poetry run pytest
```

## Intégration continue (CI)

Ce projet utilise GitHub Actions pour l'intégration continue. Les tests sont exécutés automatiquement lors des pull requests et des commits sur les branches principales.

Pour plus d'informations sur la CI, consultez le [guide CI/CD](./ci_guide.md).

## Résolution des problèmes courants

### Problèmes Flutter

- Si vous rencontrez des erreurs liées à Flutter, essayez :

  ```bash
  flutter clean
  flutter pub get
  ```

### Problèmes Python

- Si vous rencontrez des erreurs liées à Poetry :

  ```bash
  poetry lock --no-update
  poetry install
  ```

### Problèmes de synchronisation des scripts Python

Si les scripts Python ne sont pas correctement synchronisés entre les différentes parties du projet :

```bash
./sync_python_scripts.sh  # Linux/macOS
sync_python_scripts.bat   # Windows
```

## Ressources supplémentaires

- [Documentation Flutter](https://docs.flutter.dev/)
- [Documentation Poetry](https://python-poetry.org/docs/)
- [Guide du workflow Git](./git_workflow.md)
