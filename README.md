# _737calcs

Application Flutter multiplateforme avec intégration Python pour les calculs spécifiques.

## Présentation

Ce projet combine la puissance de Flutter pour l'interface utilisateur cross-plateforme avec la flexibilité de Python pour les calculs techniques. L'application est conçue pour fonctionner sur plusieurs plateformes :

- Android (via Chaquopy)
- iOS (via Python-Apple-support)
- Windows (via Python embarqué)
- Web (via API backend)
- Linux/macOS (via Python système)

## Architecture

L'architecture du projet est basée sur une approche de packaging des scripts Python :

- Les scripts Python sont développés dans le dossier `shared_python/`
- Ces scripts sont empaquetés comme assets dans l'application Flutter
- Un service unifié (`UnifiedPythonService`) extrait et exécute ces scripts sur chaque plateforme

## Structure du projet

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

## Installation

1. Clonez ce dépôt
2. Assurez-vous que Flutter est installé et configuré
3. Exécutez `package_python_scripts.sh` pour préparer les scripts Python
4. Lancez l'application avec `flutter run`

## Scripts utilitaires

- `package_python_scripts.sh` : Prépare les scripts Python pour le packaging
- `run_dev.sh` : Lance l'environnement de développement complet
- `run_dev_direct.sh` : Lance l'environnement avec accès direct aux scripts source
- `start_web_dev.sh` : Lance l'application Flutter en mode web avec le backend FastAPI

## Développement

Pour développer et tester l'application :

```bash
# Préparer les scripts Python pour le packaging
./package_python_scripts.sh

# Lancer l'environnement de développement
./run_dev.sh
```

Pour développer et tester l'application en mode web :

```bash
# Lancer l'application en mode web avec le backend FastAPI
./start_web_dev.sh
```

Pour ajouter un nouveau calcul :

1. Créez un nouveau script Python dans `shared_python/calculs/`
2. Exécutez `package_python_scripts.sh` pour mettre à jour les assets
3. Dans votre code Flutter, utilisez `UnifiedPythonService.runScript('nom_du_script', [args])`

## Documentation

Pour plus de détails sur l'approche de packaging, consultez `docs/packaging_approach.md`.

## Organisation des branches

Le projet utilise une structure de branches pour organiser le développement :

- **main** : Branche de production stable. Elle contient le code prêt à être déployé.
- **dev** : Branche de développement. Toutes les nouvelles fonctionnalités et corrections sont d'abord intégrées ici.

### Workflow de développement

1. Le développement de nouvelles fonctionnalités se fait sur la branche **dev** ou sur des branches dédiées créées à partir de **dev**
2. Une fois les fonctionnalités testées et validées dans **dev**, elles sont fusionnées vers **main**
3. Les versions de production sont toujours créées à partir de la branche **main**
