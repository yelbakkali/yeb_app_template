<!--
RÉFÉRENCES CROISÉES:
- Ce fichier est référencé dans: [.github/copilot-instructions.md:15, 83]
- Ce fichier est référencé dans: [.copilot/sessions/session_20250914_auto_doc.md:30]
-->

# Instructions pour GitHub Copilot - Initialisation du template

Ce document contient les instructions destinées à GitHub Copilot pour aider les utilisateurs après qu'ils ont créé un projet à partir du template `yeb_app_template`.

## Déclencheur de contexte

Lorsque l'utilisateur demande à Copilot de "lire la documentation dans docs/" ou une requête similaire après avoir créé un projet à partir de ce template, Copilot doit :

1. Lire ce document
2. Comprendre le contexte complet du template
3. Proposer les étapes personnalisées de développement

## Processus automatisé d'initialisation

Quand l'utilisateur demande à Copilot de l'aide après avoir initialisé son projet avec le script `bootstrap.sh` (qui appelle `template/init_project.sh` ou `template/init_project.bat` en interne), Copilot doit :

1. **Résumer la structure du projet** :
   - Expliquer la structure des dossiers du template
   - Décrire comment le système de packaging Python fonctionne
   - Présenter le fonctionnement du `UnifiedPythonService`

2. **Expliquer les étapes déjà réalisées** :
   - Renommage du projet
   - Configuration de l'environnement
   - Installation des dépendances

3. **Proposer les prochaines étapes** :
   - Personnalisation de l'UI Flutter
   - Ajout de modules Python spécifiques
   - Configuration des tests
   - Déploiement sur différentes plateformes

## Exemples de développement guidés

Copilot doit être capable de guider l'utilisateur à travers ces scénarios courants :

### 1. Ajout d'un nouveau module de calcul Python

```markdown
Pour ajouter un nouveau module de calcul Python :

1. Créez un fichier dans le dossier `shared_python/` (par exemple `mon_module.py`)
2. Implémentez une fonction `main()` qui sera le point d'entrée
3. Exécutez `./scripts/package_python_scripts.sh` pour mettre à jour les assets
4. Utilisez dans Flutter via `UnifiedPythonService.runScript('mon_module', [args])`
```

### 2. Création d'un nouvel écran Flutter

```markdown
Pour ajouter un nouvel écran à l'application Flutter :

1. Créez une nouvelle classe dans `flutter_app/lib/routes/`
2. Ajoutez la route dans le système de navigation
3. Intégrez les appels Python nécessaires via `UnifiedPythonService`
```

### 3. Configuration des tests

```markdown
Pour configurer les tests de votre application :

1. Tests Flutter : Ajoutez les tests dans `flutter_app/test/`
2. Tests Python : Ajoutez les tests dans `python_backend/tests/` et `web_backend/tests/`
3. Exécutez les tests via les commandes recommandées dans le guide d'installation
```

## Adaptation spécifique au projet

Lorsque l'utilisateur demande à Copilot de l'aider à adapter le template à son cas d'usage spécifique, Copilot doit :

1. Demander des informations sur le cas d'usage précis
2. Suggérer des modifications adaptées à ce cas d'usage
3. Proposer une feuille de route personnalisée
4. Offrir d'aider à implémenter les premières étapes

## Considérations de performance et de sécurité

Copilot doit rappeler à l'utilisateur :

1. D'optimiser les scripts Python pour la performance mobile
2. De considérer les implications de sécurité du code Python embarqué
3. De maintenir à jour les dépendances pour éviter les vulnérabilités
4. De suivre les bonnes pratiques de développement Flutter et Python
