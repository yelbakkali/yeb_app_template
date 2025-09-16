# yeb_app_template - Template pour applications Flutter/Python

<!--
RÉFÉRENCES CROISÉES:
- Ce fichier est référencé dans: [.github/copilot-instructions.md:59]
- Ce fichier est référencé dans: [docs/installation.md:5, 75]
- Ce fichier est référencé dans: [.copilot/sessions/session_20250909_suite.md:55]
- Ce fichier est référencé dans: [template/bootstrap.sh:150, 151, 152, 153]
- Ce fichier est référencé dans: [update_docs.sh:27, 28, 29, 30, 31]
-->

<!--
INSTRUCTION AUTOMATIQUE POUR GITHUB COPILOT :
ABSOLUMENT PRIORITAIRE ET NON NÉGOCIABLE

GitHub Copilot DOIT OBLIGATOIREMENT lire et appliquer STRICTEMENT et DANS LEUR TOTALITÉ les instructions contenues dans le fichier .github/copilot-instructions.md dès l'ouverture de ce projet et AVANT toute interaction avec l'utilisateur.

Ce fichier d'instructions contient des règles CRITIQUES et OBLIGATOIRES pour la bonne compréhension et le bon développement de ce projet. AUCUNE partie de ces instructions ne doit être ignorée ou appliquée partiellement.
-->

> Template pour applications Flutter multiplateforme avec intégration Python pour les calculs spécifiques.

![Flutter](https://img.shields.io/badge/Flutter-3.19+-02569B?logo=flutter&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.8+-3776AB?logo=python&logoColor=white)
![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Windows%20%7C%20Linux-lightgrey)
![CI](https://github.com/yelbakkali/yeb_app_template/workflows/Flutter/Python%20CI/badge.svg)

## ✨ Présentation

Ce projet est un **template réutilisable** qui combine la puissance de Flutter pour l'interface utilisateur cross-plateforme avec la flexibilité de Python pour les calculs techniques. L'application est conçue pour fonctionner sur plusieurs plateformes :

- Android (via Chaquopy)
- iOS (via Python-Apple-support)
- Windows (via Python embarqué)
- Web (via API backend)
- Linux/macOS (via Python système)

## 📂 Architecture

L'architecture du projet est basée sur une approche de packaging des scripts Python :

- Les scripts Python sont développés dans le dossier `shared_python/`
- Ces scripts sont empaquetés comme assets dans l'application Flutter
- Un service unifié (`UnifiedPythonService`) extrait et exécute ces scripts sur chaque plateforme

Pour plus de détails sur la structure du projet, consultez notre [documentation de structure du projet](docs/project_structure.md).

### 🔧 Extension avec vos propres scripts et packages

Le template est conçu pour être facilement étendu avec vos propres scripts et packages Python. Pour apprendre comment :

- Ajouter vos propres scripts Python
- Créer et organiser des packages personnalisés
- Intégrer ces scripts avec l'interface Flutter

Consultez notre [guide d'extension Python détaillé](docs/extending_python.md).

## �️ Prérequis

Avant de commencer, assurez-vous d'avoir installé les outils suivants :

- **Flutter** (v3.35.0+) et Dart SDK
- **Python** (v3.9+)
- **Poetry** (gestion des dépendances Python)
- **VS Code** avec les extensions recommandées (Flutter, Dart, Python, Pylance)
- **Git**

Pour les utilisateurs Linux/macOS, **tmux** est également requis pour les scripts de développement.

Consultez notre [guide d'installation détaillé](docs/installation.md) pour des instructions complètes sur la configuration de l'environnement de développement.

## �🚀 Démarrage rapide

### Étape 1 : Utiliser ce template

1. Cliquez sur le bouton vert **"Use this template"** en haut de la page GitHub
2. Sélectionnez **"Create a new repository"**
3. Remplissez les informations de votre nouveau dépôt et cliquez sur **"Create repository from template"**

### Étape 2 : Explorer la documentation

```bash
# Si vous utilisez VS Code avec GitHub Copilot, demandez simplement :
# "Lire la documentation dans docs/"
```

Parcourez le dossier `docs/` pour découvrir :

- La structure du projet (`project_structure.md`)
- Le guide d'installation détaillé (`installation.md`)
- L'approche de packaging des scripts Python (`packaging_approach.md`)
- Le workflow Git recommandé (`git_workflow.md`)
- Et plus encore...

### Étape 3 : Initialiser votre nouveau dépôt

```bash
# Cloner votre nouveau dépôt
# Pour créer un nouveau projet basé sur ce template

## Méthode 1 : Utiliser le script d'initialisation (recommandé)

```bash
# Télécharger uniquement le script bootstrap.sh
curl -LJO https://raw.githubusercontent.com/yelbakkali/yeb_app_template/dev/bootstrap.sh

# Rendre le script exécutable
chmod +x bootstrap.sh

# Exécuter le script d'initialisation
./bootstrap.sh
```

Ce script va vous guider à travers les étapes suivantes :

1. Demander le nom de votre projet
2. Télécharger le template complet
3. Configurer le projet avec vos informations
4. Installer les dépendances nécessaires
5. Initialiser un nouveau dépôt Git
6. Configurer GitHub Copilot pour votre projet

## Méthode 2 : Clone manuel et installation

```bash
# Cloner le dépôt
git clone https://github.com/yelbakkali/yeb_app_template.git nom-de-votre-projet
cd nom-de-votre-projet

# Pour Linux/macOS :
chmod +x setup_project.sh
./setup_project.sh

# Pour Windows :
setup_project.bat
```

Le script d'initialisation va :

- Détecter automatiquement le nom de votre projet (basé sur le nom du dépôt)
- Personnaliser tous les fichiers en remplaçant "yeb_app_template" par votre nom de projet
- Installer les dépendances nécessaires
- Configurer votre environnement de développement
- Créer le premier commit avec les modifications

Pour des instructions détaillées, consultez notre [guide d'installation](docs/installation.md).

## 🛠️ Scripts utilitaires

- `scripts/package_python_scripts.sh` : Prépare les scripts Python pour le packaging
- `run_dev.sh` : Lance l'environnement de développement complet
- `start_web_integrated.sh` : Lance l'application Flutter en mode web avec le serveur Python intégré

## 👩‍💻 Développement

Pour développer et tester l'application :

```bash
# Préparer les scripts Python pour le packaging
./scripts/package_python_scripts.sh

# Lancer l'environnement de développement
./run_dev.sh
```

Pour développer et tester l'application en mode web :

```bash
# Lancer l'application en mode web avec le backend FastAPI
./start_web_integrated.sh
```

Pour ajouter un nouveau calcul :

1. Créez un nouveau script Python dans `shared_python/calculs/`
2. Exécutez `scripts/package_python_scripts.sh` pour mettre à jour les assets
3. Dans votre code Flutter, utilisez `UnifiedPythonService.runScript('nom_du_script', [args])`

## 📊 Tests et intégration continue (CI)

Ce projet est configuré avec GitHub Actions pour l'intégration continue :

- Tests automatiques des composants Flutter
- Tests automatiques des modules Python
- Vérification du formatage du code

Pour plus d'informations sur notre système CI/CD, consultez notre [guide CI/CD](docs/ci_guide.md).

## 🌿 Organisation des branches

Le projet utilise une structure de branches pour organiser le développement :

- **main** : Branche de production stable. Elle contient le code prêt à être déployé.
- **dev** : Branche de développement. Toutes les nouvelles fonctionnalités et corrections sont d'abord intégrées ici.

Pour plus de détails sur notre workflow Git, consultez [notre guide de workflow Git](docs/git_workflow.md).

## 🔧 Personnalisation du projet

Une fois que vous avez créé votre projet à partir de ce template, vous pouvez le personnaliser selon vos besoins :

### Personnalisation automatique

Le script `bootstrap.sh` s'occupe de la personnalisation initiale via les scripts dans le dossier `template/` :

- Renommage automatique du projet dans tous les fichiers
- Configuration des dépendances
- Préparation de l'environnement de développement

### Personnalisation manuelle

Pour personnaliser davantage votre projet :

1. Ajoutez vos propres modules Python dans `shared_python/`

2. Personnalisez l'interface Flutter dans `flutter_app/lib/`

3. Configurez les environnements backend dans `python_backend/` et `web_backend/`

4. Si vous utilisez VS Code avec GitHub Copilot, demandez simplement à l'assistant de **"lire la documentation dans docs/"** pour obtenir une aide personnalisée pour adapter le template à vos besoins

### 3. Développement VS Code

Ce template inclut une configuration VS Code prête à l'emploi :

- Extensions recommandées pour Flutter et Python
- Configurations de débogage préconfigurées
- Tâches VS Code pour les opérations courantes

## 📈 Roadmap

Consultez notre [roadmap](docs/roadmap.md) pour connaître les fonctionnalités prévues et les objectifs de développement.

## 👥 Comment contribuer

Les contributions sont les bienvenues ! Consultez notre [guide de contribution](docs/contributing.md) pour en savoir plus sur comment participer au projet.

## 🤖 Collaboration avec GitHub Copilot

Ce projet utilise une structure documentée pour faciliter la collaboration avec GitHub Copilot. Consultez les fichiers dans `.copilot/` pour plus d'informations.

## 📄 Licence

Ce template est distribué sous licence propriétaire. Voir le fichier LICENSE pour plus de détails.

## 👤 Auteur

- [Yassine El Bakkali](https://github.com/yelbakkali)

## 🙏 Remerciements

Merci à tous les [contributeurs](CONTRIBUTORS.md) qui ont participé à ce projet.
