# Structure du projet 737calcs

Ce document décrit l'organisation des dossiers et fichiers du projet.

## Répertoires principaux

```bash
_737calcs/
├── docs/                    # Documentation du projet
├── flutter_app/             # Application Flutter principale
├── lib/                     # Code Dart partagé
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
├── lib/                     # Code Dart spécifique à l'application Flutter
├── linux/                   # Configuration Linux
├── macos/                   # Configuration macOS
├── test/                    # Tests Flutter
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

Scripts d'installation et de configuration :

```bash
scripts/
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
