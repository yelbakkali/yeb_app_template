<!--
RÉFÉRENCES CROISÉES:
- Ce fichier est référencé dans: [README.md:46, 89]
- Ce fichier est référencé dans: [template/bootstrap.sh:202]
- Ce fichier est référencé dans: [update_docs.sh:9]
-->

# Structure du projet yeb_app_template

Ce document décrit l'organisation des dossiers et fichiers du projet.

## Répertoires principaux

```bash
yeb_app_template/
├── docs/                    # Documentation du projet
├── flutter_app/             # Application Flutter principale (contient tout le code Dart)
├── python_backend/          # Backend Python pour le développement local
├── scripts/                 # Scripts d'installation et de configuration
├── shared_python/           # Code Python partagé entre les plateformes
├── test/                    # Tests généraux du projet
└── web_backend/             # Backend Python pour le déploiement web
```

## Détail des répertoires

### docs/

Contient toute la documentation du projet :

```bash
docs/
├── chat_resume.md           # Résumé des conversations avec GitHub Copilot
├── ci_guide.md              # Guide pour la CI/CD
├── copilot/                 # Documentation pour la collaboration avec GitHub Copilot
├── git_workflow.md          # Workflow Git utilisé dans le projet
└── github_branch_protection.md  # Configuration de la protection des branches
```

### flutter_app/

Application Flutter principale avec les configurations pour chaque plateforme :

```bash
flutter_app/
├── android/                 # Configuration Android avec Chaquopy
├── assets/                  # Ressources et scripts Python embarqués
│   └── shared_python/       # Scripts Python partagés
├── ios/                     # Configuration iOS avec Python-Apple-support
├── lib/                     # Code Dart de l'application (tout le code Dart du projet)
│   ├── config/              # Configurations et constantes de l'application
│   ├── models/              # Modèles de données
│   ├── services/            # Services, dont UnifiedPythonService
│   └── utils/               # Utilitaires et helpers
├── linux/                   # Configuration Linux
├── macos/                   # Configuration macOS
├── test/                    # Tests spécifiques à l'application Flutter
├── web/                     # Configuration web
└── windows/                 # Configuration Windows avec Python embarqué
```

### python_backend/

Backend Python pour le développement local :

```bash
python_backend/
├── python_backend/          # Code source principal
├── tests/                   # Tests unitaires
└── utils/                   # Utilitaires partagés (ex: SQLiteManager)
```

### scripts/

Scripts utilisés pendant le développement :

```bash
scripts/
├── flutter_wrapper_macos.sh # Wrapper pour Flutter sur macOS avec Apple Silicon
├── git_autocommit.sh        # Script pour automatiser les commits Git
├── merge_to_main.bat/sh     # Scripts pour fusionner les branches vers main
├── package_python_scripts.*  # Scripts pour empaqueter les scripts Python
└── start_vscode_wsl.sh      # Script pour démarrer VS Code optimisé pour WSL
```

### template/utils/

Scripts d'installation et de configuration utilisés lors de l'initialisation du projet :

```bash
template/utils/
├── setup.bat                # Script d'installation principal (Windows)
├── setup.sh                 # Script d'installation principal (Unix)
├── setup_windows.bat        # Configuration spécifique à Windows
└── setup_wsl.sh             # Configuration spécifique à WSL
```

### web_backend/

Backend Python pour le déploiement web :

```bash
web_backend/
├── main.py                  # Point d'entrée de l'API
├── tests/                   # Tests unitaires
└── start_server.sh          # Script de démarrage du serveur
```

## Fichiers importants

- `.github/workflows/flutter_python_ci.yml` : Configuration CI pour tests Flutter et Python
- `README.md` : Documentation principale du projet
- `.vscode/*.json` : Configuration VS Code pour le développement
