# Suivi des étapes du projet 737calcs

## Étape 1 : Préparation du workspace

- Création de la structure de dossiers :
  - flutter_app/
  - python_backend/
  - docs/
- Initialisation du suivi des étapes dans ce fichier.

## Étape 2 : Initialisation du projet Flutter

- installer android studio pour avoir le sdk
- Depuis le dossier `flutter_app/`, exécuter la commande :

```bash
flutter create .
```

- Cela va générer toute la structure Flutter (Android, iOS, etc.) dans le dossier.

## Étape 3 : Initialisation du backend Python avec Poetry

- Ajout d'un fichier pyproject.toml dans python_backend/.
- Initialisation de l'environnement virtuel Poetry et installation des dépendances de base.
- Création du package Python minimal dans python_backend/python_backend/ avec __init__.py.

## Étape 4 : Intégration de Python embeddable et des dépendances pour Windows

- Télécharger la version "Windows embeddable package" de Python (ex : 3.11.x) :
  - [https://www.python.org/downloads/windows/](https://www.python.org/downloads/windows/) (section "Windows embeddable package (64-bit)")
- Télécharger get-pip.py :
  - [https://bootstrap.pypa.io/get-pip.py](https://bootstrap.pypa.io/get-pip.py)
- Placer les fichiers dans `flutter_app/windows/python_embedded/`.
- Installer pip dans ce Python embeddable (`get-pip.py`).
- Installer les dépendances nécessaires (ex : pandas, numpy) avec pip dans ce dossier.
- Vérifier que `Lib/site-packages/` et `Scripts/` sont bien présents.

```bash
python.exe get-pip.py
python.exe -m pip install pandas numpy
```

- Nettoyage (optionnel)
  - Supprime get-pip.py si tu veux alléger le dossier.
  - Tu peux aussi supprimer les caches pip si besoin.
- Intégration dans Flutter
  - Place tout le dossier python_embedded/ dans flutter_app/windows/.
  - Dans python_service.dart, utilise le chemin relatif pour lancer python.exe et tes scripts.
- Distribution
  - Lors du packaging de ton app Windows, assure-toi que le dossier python_embedded/ est bien inclus dans le build final.

## Étape 5 : Intégration Flutter ↔️ Python

- Préparer la structure de service côté Flutter pour appeler les scripts Python selon la plateforme (Android, iOS, Windows).
- Définir une interface unique dans Flutter pour envoyer les entrées et recevoir les résultats des calculs Python.
- Création du squelette du service Flutter `python_service.dart` dans lib/services/ pour centraliser l'appel aux scripts Python selon la plateforme.

## Étape 6 : Création de la structure multiplateforme pour les scripts Python

- Création du dossier `flutter_app/windows/python_embedded/` pour Python portable sur Windows.
- Création du dossier `flutter_app/android/app/src/main/python/` pour les scripts Python Chaquopy (Android).
- Création du dossier `flutter_app/ios/PythonBundle/` pour les scripts Python embarqués avec Python-Apple-support (iOS).
- Création des dossiers de structure Flutter : `lib/forms/`, `lib/models/`, `lib/routes/`, `lib/services/`, `lib/utils/`.
- Création des dossiers de structure Python : `calculs/`, `utils/`.

## Étape 7 : Intégration de Chaquopy pour Android

- Ouvre le dossier `flutter_app/android/`.
- Ajoute le repository Chaquopy dans `settings.gradle.kts` ou `build.gradle.kts` racine :

```kotlin
dependencyResolutionManagement {
  repositories {
    google()
    mavenCentral()
    maven { url = uri("https://chaquo.com/maven") }
  }
}
```

- Dans `app/build.gradle.kts`, ajoute le plugin Chaquopy :

```kotlin
plugins {
  id("com.android.application")
  id("com.chaquo.python") version "14.0.2"
}
```

- Ajoute la configuration Chaquopy après le bloc `android { ... }` :

```kotlin
python {
  buildPython.set("python3")
  pip {
    install("pandas")
    install("numpy")
  }
}
```

- Place tes scripts Python dans `android/app/src/main/python/`.
- Crée un Platform Channel Flutter ↔️ Android pour exécuter les scripts Python via Chaquopy.
- Documentation officielle : [https://chaquo.com/chaquopy/doc/current/](https://chaquo.com/chaquopy/doc/current/)

(Les prochaines étapes seront ajoutées ici au fur et à mesure de l’avancement du projet.)
