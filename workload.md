# 737calcs - Développement d'une application multiplateforme avec Flutter et Python

Ce document résume le processus de développement de l'application 737calcs, qui combine Flutter pour l'interface utilisateur et Python pour les calculs.

## Architecture globale

L'application 737calcs utilise une architecture hybride :

- **Frontend** : Application Flutter multiplateforme (Android, iOS, Windows, Web)
- **Calculs** : Scripts Python intégrés dans l'application (via packaging)
- **Intégration** : Mécanisme de communication adapté à chaque plateforme

```plaintext
_737calcs/
├── docs/                   # Documentation du projet
├── flutter_app/            # Application Flutter
│   ├── android/            # Configuration Android avec Chaquopy
│   ├── ios/                # Configuration iOS avec Python-Apple-support
│   ├── windows/            # Configuration Windows avec Python embarqué
│   ├── lib/                # Code Dart de l'application
│   │   ├── services/       # Services dont UnifiedPythonService
│   │   └── main.dart       # Point d'entrée de l'application
│   └── assets/             # Assets de l'application
│       └── shared_python/  # Scripts Python packagés
├── shared_python/          # Scripts Python source partagés
│   └── calculs/            # Modules de calcul
└── web_backend/            # API backend pour la version web
```

## Prérequis

### Outils de développement

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.9+ recommandée)
- [Android Studio](https://developer.android.com/studio) (pour le SDK Android)
- [Xcode](https://developer.apple.com/xcode/) (pour le développement iOS, macOS uniquement)
- [Visual Studio](https://visualstudio.microsoft.com/) (pour le développement Windows)
- [Python](https://www.python.org/downloads/) (version 3.11+ recommandée)

### Dépendances spécifiques aux plateformes

- **Android** : [Chaquopy](https://chaquo.com/chaquopy/) (version 14.0.2+)
- **iOS** : [Python-Apple-support](https://github.com/beeware/Python-Apple-support)
- **Windows** : [Python Embeddable](https://www.python.org/downloads/windows/) (version 3.11.9)
- **Web** : [FastAPI](https://fastapi.tiangolo.com/) pour le backend Python

## Étapes d'installation et configuration

### 1. Préparation de l'environnement

```bash
# Cloner le dépôt
git clone https://github.com/yelbakkali/_737calcs.git
cd _737calcs

# Installer les dépendances Flutter
cd flutter_app
flutter pub get
```

### 2. Configuration spécifique à chaque plateforme

#### Android (Chaquopy)

```kotlin
# Configuration dans android/settings.gradle.kts
maven { url = uri("https://chaquo.com/maven") }

# Configuration dans android/app/build.gradle.kts
plugins {
  id("com.chaquo.python") version "14.0.2"
}

# Ajout de python_config.gradle.kts pour extraire les scripts Python des assets
```

#### iOS (Python-Apple-support)

```bash
# Création d'un script de build phase dans iOS
extract_python_scripts.sh

# Configuration du PythonBridge dans AppDelegate.swift
```

#### Windows (Python Embeddable)

```plaintext
# Téléchargement du package Python embeddable
https://www.python.org/ftp/python/3.11.9/python-3.11.9-embed-amd64.zip

# Installation dans flutter_app/windows/python_embedded/
# Configuration pour l'extraction des scripts Python
```

#### Web (FastAPI)

```python
# Création d'un backend API dans web_backend/
# Configuration pour l'exposition des scripts Python via API
```

### 3. Approche d'intégration Python

Après évaluation de deux approches (synchronisation des scripts vs packaging), nous avons opté pour l'**approche de packaging** qui offre :

- Une meilleure portabilité
- Une maintenance simplifiée
- Une intégration plus cohérente avec le processus de build

### 4. Mise en place du service UnifiedPythonService

Ce service centralise l'accès aux scripts Python sur toutes les plateformes :

- Extraction des scripts Python des assets Flutter
- Détection automatique de la plateforme
- Exécution adaptée selon la plateforme (Chaquopy, Python-Apple-support, Python Embeddable, API)
- Support du mode développement pour accès direct aux sources

## Utilisation du projet

### Développement

```bash
# Préparer les scripts Python pour le packaging
./package_python_scripts.sh

# Lancer l'environnement de développement complet
./run_dev.sh

# OU en mode accès direct aux scripts
./run_dev_direct.sh
```

### Ajout d'un nouveau calcul

1. Créer un script Python dans `shared_python/calculs/`
2. Structurer le script avec une fonction `main(*args)` comme point d'entrée
3. Exécuter `package_python_scripts.sh` pour mettre à jour les assets
4. Utiliser dans Flutter : `UnifiedPythonService.runScript('nom_script', [args])`

### Déploiement

Chaque plateforme a son processus de build spécifique :

- **Android** : `flutter build apk` (scripts extraits avec Chaquopy)
- **iOS** : `flutter build ipa` (scripts extraits avec Python-Apple-support)
- **Windows** : `flutter build windows` (avec Python Embeddable)
- **Web** : `flutter build web` + déploiement du backend API

## Ressources et liens utiles

- [Flutter](https://flutter.dev/) - Framework UI multiplateforme
- [Chaquopy](https://chaquo.com/chaquopy/) - Python pour Android
- [Python-Apple-support](https://github.com/beeware/Python-Apple-support) - Python pour iOS
- [Python Embeddable](https://www.python.org/downloads/windows/) - Python portable pour Windows
- [FastAPI](https://fastapi.tiangolo.com/) - Framework API Python

## Défis techniques résolus

1. **Intégration Python sur plusieurs plateformes** - Chaque plateforme nécessite une approche différente pour exécuter Python
2. **Partage des scripts Python** - Solution de packaging avec extraction au runtime
3. **Mode développement vs production** - Variable d'environnement FLUTTER_DEV_MODE pour faciliter le développement
4. **Intégration du build** - Scripts automatiques pour inclure Python dans le processus de build Flutter
