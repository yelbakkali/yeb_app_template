# Organisation des scripts dans le template

## Structure des répertoires de scripts

Le projet YEB App Template organise ses scripts en deux catégories principales :

### 1. Scripts opérationnels (/scripts)

Les scripts dans le dossier `/scripts/` sont des outils opérationnels qui sont utilisés régulièrement pendant le développement du projet. Ces scripts restent disponibles après l'initialisation du projet et sont essentiels au cycle de développement.

**Scripts opérationnels clés :**

- `package_python_scripts.sh/bat` : Prépare les scripts Python pour le packaging dans les assets Flutter
- `git_autocommit.sh` : Outil pour faciliter les commits Git
- `merge_to_main.sh/bat` : Utilitaire pour fusionner la branche de développement vers main
- `flutter_wrapper_macos.sh` : Script enveloppe pour les commandes Flutter sur macOS avec Apple Silicon

### 2. Scripts d'initialisation (/template/scripts)

Les scripts dans le dossier `/template/scripts/` sont spécifiquement conçus pour l'initialisation du projet à partir du template. Ces scripts sont généralement utilisés une seule fois lors de la configuration initiale d'un nouveau projet.

**Scripts d'initialisation clés :**

- `check_prerequisites.sh/bat` : Vérifie et installe les prérequis système
- `cleanup_init_files.sh/bat` : Nettoie les fichiers d'initialisation après leur utilisation
- `configure_vscode_for_flutter.sh/bat` : Configure l'environnement VS Code pour Flutter et Python

## Flux d'initialisation du projet

1. L'utilisateur exécute `bootstrap.sh` ou télécharge directement le template
2. Le script `init_project.sh/bat` dans le dossier racine est exécuté
3. Ce script appelle les scripts d'initialisation du dossier `template/scripts/`
4. Une fois l'initialisation terminée, les fichiers de template et les scripts d'initialisation peuvent être nettoyés

## Maintenance des scripts

- Les scripts opérationnels dans `/scripts/` doivent être maintenus et mis à jour régulièrement
- Les scripts d'initialisation dans `/template/scripts/` sont mis à jour uniquement lors des modifications du processus d'initialisation
- Pour ajouter un nouveau script opérationnel, placez-le dans `/scripts/`
- Pour ajouter un nouveau script d'initialisation, placez-le dans `/template/scripts/`

Cette séparation claire facilite la maintenance et la compréhension des différentes phases du projet.
