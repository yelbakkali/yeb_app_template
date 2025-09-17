<!--
RÉFÉRENCES CROISÉES:
- Ce fichier est référencé dans: [README.md:70, 90, 146]
- Ce fichier est référencé dans: [run_dev.bat:6]
- Ce fichier est référencé dans: [run_dev.sh:8]
- Ce fichier est référencé dans: [setup_template.sh:6, 204]
- Ce fichier est référencé dans: [setup_project.bat:5]
- Ce fichier est référencé dans: [init_project.bat:7]
- Ce fichier est référencé dans: [update_docs.sh:10]
-->

# Guide d'installation du projet yeb_app_template

Ce guide vous aidera à installer et configurer l'environnement de développement pour le projet yeb_app_template.

> **Note :** Si vous utilisez ce template pour créer un nouveau projet, référez-vous d'abord au [processus d'initialisation](../README.md) qui utilise le script `setup_template.sh`. Vous pouvez également consulter la documentation du template dans le dossier `template/docs/`. Ce guide s'applique une fois que vous avez déjà initialisé votre projet.

## Prérequis

### Outils principaux

Avant de commencer, assurez-vous d'avoir installé :

- [Flutter](https://docs.flutter.dev/get-started/install) (version 3.35.0 ou supérieure)
- [Dart SDK](https://dart.dev/get-dart) (installé automatiquement avec Flutter)
- [Python](https://www.python.org/downloads/) (version 3.9 ou supérieure)
- [Poetry](https://python-poetry.org/docs/#installation) (pour la gestion des dépendances Python)
- [Git](https://git-scm.com/downloads)
- [VS Code](https://code.visualstudio.com/download) (recommandé comme environnement de développement)
- [tmux](https://github.com/tmux/tmux/wiki/Installing) (pour Linux/macOS, utilisé par les scripts de développement)

### Extensions VS Code recommandées

Pour une expérience de développement optimale, installez ces extensions VS Code :

- **Flutter/Dart** :
  - [Flutter](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter) - Support Flutter et Dart
  - [Dart](https://marketplace.visualstudio.com/items?itemName=Dart-Code.dart-code) - Support du langage Dart

- **Python** :
  - [Python](https://marketplace.visualstudio.com/items?itemName=ms-python.python) - Support Python
  - [Pylance](https://marketplace.visualstudio.com/items?itemName=ms-python.vscode-pylance) - Serveur de langage Python
  - [Python Test Explorer](https://marketplace.visualstudio.com/items?itemName=LittleFoxTeam.vscode-python-test-adapter) - Pour exécuter les tests Python

- **Outils généraux** :
  - [Git Graph](https://marketplace.visualstudio.com/items?itemName=mhutchie.git-graph) - Visualisation de l'historique Git
  - [GitLens](https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens) - Fonctionnalités Git avancées
  - [GitHub Copilot](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot) - Assistant IA pour le développement (optionnel)

- **Qualité du code** :
  - [ESLint](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint) - Linting pour JavaScript/TypeScript
  - [Prettier](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode) - Formattage de code

Vous pouvez installer toutes ces extensions rapidement en exécutant les commandes suivantes dans un terminal :

```bash
# Extensions Flutter/Dart
code --install-extension Dart-Code.flutter
code --install-extension Dart-Code.dart-code

# Extensions Python
code --install-extension ms-python.python
code --install-extension ms-python.vscode-pylance
code --install-extension LittleFoxTeam.vscode-python-test-adapter

# Outils généraux
code --install-extension mhutchie.git-graph
code --install-extension eamodio.gitlens

# Qualité du code
code --install-extension dbaeumer.vscode-eslint
code --install-extension esbenp.prettier-vscode
```

## Installation

### 1. Cloner le dépôt

Si vous travaillez sur le template lui-même (et non pas pour créer un nouveau projet) :

```bash
git clone https://github.com/votre-utilisateur/yeb_app_template.git
cd yeb_app_template
```

Pour créer un nouveau projet basé sur ce template, utilisez plutôt le script `setup_template.sh` comme indiqué dans le [README](../README.md) et documenté dans [`template/docs/setup_template.md`](../template/docs/setup_template.md).

### 2. Utiliser le script d'installation automatique (recommandé)

Le projet inclut des scripts qui automatisent l'installation et la configuration :

```bash
# Utilisez le script setup_template.sh comme expliqué dans le README.md
./setup_template.sh

# Ou pour une installation manuelle des dépendances :
./template/utils/setup.sh    # Linux/macOS
template\utils\setup.bat     # Windows
```

Ce script va :

- Vérifier les prérequis (Git, Python, Poetry, Flutter, VS Code)
- Tenter d'installer automatiquement les outils manquants lorsque possible
- Initialiser le projet avec votre nom personnalisé
- Configurer VS Code avec les paramètres recommandés
- Installer les dépendances Flutter et Python
- Ouvrir le projet dans VS Code si disponible

### 3. Installation manuelle (alternative)

Si vous préférez une installation étape par étape, suivez les instructions ci-dessous :

#### Configuration Flutter

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
chmod +x run_dev.sh
./run_dev.sh
```

#### Pour Windows

```bash
run_dev.bat
```

#### Pour WSL (Windows Subsystem for Linux)

Si vous utilisez WSL pour le développement, le projet inclut des outils d'optimisation pour résoudre un problème connu de VS Code avec WSL où les redirections de ports s'accumulent.

Lors de l'installation via `setup_wsl.sh`, un alias `code-wsl` est automatiquement configuré dans votre profil bash. Utilisez cette commande au lieu de `code` pour lancer VS Code avec les optimisations WSL :

```bash
code-wsl
```

Pour plus de détails sur ce problème et sa solution, consultez [Optimisation de VS Code pour WSL](wsl_optimisation.md).

## Configuration de l'éditeur VS Code

La configuration optimale de VS Code est **automatiquement mise en place** par les scripts d'initialisation du projet qui sont appelés par le script `setup_template.sh` lors de la création d'un nouveau projet. Ces scripts créent les fichiers suivants dans le dossier `.vscode` :

- `settings.json` : Configuration de l'éditeur et des extensions
- `extensions.json` : Recommandations d'extensions à installer
- `launch.json` : Configurations de débogage pour Flutter et Python

### Configuration appliquée

Cette configuration automatique inclut :

1. **Pour Flutter/Dart** :
   - Formatage automatique du code
   - Longueur de ligne à 100 caractères
   - Règles d'édition optimisées

2. **Pour Python** :
   - Configuration de l'interpréteur Python
   - Activation du linting avec Pylint
   - Formatage avec Black (88 caractères par ligne)
   - Organisation automatique des imports

3. **Configuration générale** :
   - Sauvegarde automatique
   - Taille de tabulation à 2 espaces
   - Paramètres Git simplifiés

### Personnalisation

Si vous souhaitez personnaliser davantage ces paramètres, vous pouvez modifier manuellement les fichiers dans le dossier `.vscode` après l'initialisation du projet.

> Note: Les extensions recommandées seront proposées à l'installation lors de la première ouverture du projet dans VS Code.

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
./start_web_integrated.sh  # Linux/macOS
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
