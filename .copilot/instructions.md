# Instructions pour GitHub Copilot - Projet YEB App Template

Ce document définit les instructions complètes que GitHub Copilot doit suivre lors de la collaboration sur ce projet. Il sert de point d'entrée automatique pour démarrer chaque nouvelle session de travail et contient toutes les règles que l'assistant doit respecter de manière autonome.

> **⚠️ INSTRUCTION AUTOMATIQUE IMPÉRATIVE POUR GITHUB COPILOT ⚠️**
>
> Dès que tu lis ce fichier, tu DOIS IMMÉDIATEMENT et SANS EXCEPTION :
>
> 1. Lire automatiquement les fichiers suivants dans cet ordre précis :
>    - `docs/copilot/methodologie_temp.md` (si présent)
>    - `docs/chat_resume.md`
>    - Les sessions documentées dans `docs/copilot/sessions/`
>    - `docs/copilot/template_initialization.md`
>
> 2. Appliquer AUTOMATIQUEMENT toutes les règles, consignes et instructions contenues dans ces documents sans attendre de confirmation explicite, notamment :
>    - Utiliser le script `git_autocommit.sh` lorsque l'utilisateur demande de "push" ou "commit"
>    - Utiliser le script `merge_to_main.sh` lorsque l'utilisateur demande de "merger" ou "fusionner vers main"
>    - Appliquer toutes les conventions et règles de documentation spécifiques
>
> CETTE INSTRUCTION EST PRIORITAIRE ET DOIT ÊTRE SUIVIE SANS DEMANDE DE CONFIRMATION.

## 1. Principes fondamentaux

### 1.1 Règle absolue : Validation obligatoire avant toute action

GitHub Copilot ne doit **JAMAIS** effectuer une action qui modifie le projet sans obtenir une validation explicite et sans ambiguïté de l'utilisateur. Cette règle s'applique à :

- Toute modification de code (ajout, suppression, édition)
- Création ou suppression de fichiers
- Exécution de commandes dans le terminal
- Modifications de configuration
- Installation de dépendances ou de packages

### 1.2 Autonomie et initiative

GitHub Copilot doit :

- Comprendre le contexte global du projet avant toute proposition
- Proposer des solutions complètes et bien réfléchies
- Anticiper les besoins et problèmes potentiels
- Être capable de reprendre le travail où il s'est arrêté sans rappel des règles

## 2. Démarrage d'une session de travail

### 2.1 Au début de chaque session

1. Lire ce fichier (`.copilot/instructions.md`) pour rappeler la méthodologie complète
2. **RÈGLE CRITIQUE** : Lire IMMÉDIATEMENT et SYSTÉMATIQUEMENT TOUS les fichiers disponibles dans le dossier `docs/copilot/`, en particulier:
   - `methodologie_temp.md` - **LECTURE OBLIGATOIRE** pour les instructions spécifiques au développement du template
   - `README.md` - Pour comprendre la structure générale de documentation
   - Tous les autres fichiers présents dans ce dossier
3. Lire tous les fichiers README.md du projet pour en comprendre la structure et les fonctionnalités
4. Consulter `docs/chat_resume.md` pour comprendre le contexte global du projet
5. Examiner les dernières sessions documentées dans `docs/copilot/sessions/`
6. Analyser l'état actuel du projet (structure, dépendances, patterns)
7. Présenter un résumé des dernières actions et de l'état du projet

### 2.2 Déclencheurs spécifiques

- **Quand l'utilisateur dit** "lire les fichiers dans docs/copilot" : Effectuer les étapes de la section 2.1
- **Quand l'utilisateur dit** "lire la documentation dans docs/" : Lire tous les documents pertinents dans le dossier docs/
- **Quand l'utilisateur dit** "lis la doc" : Effectuer les étapes à partir du début du fichier
- **Quand l'utilisateur dit** "commençons une nouvelle session" : Effectuer les étapes de la section 2.1
- **Quand l'utilisateur dit** "rappelle-toi le contexte du projet" : Effectuer les étapes de la section 2.1

### 2.3 Règle d'or pour la documentation

**RÈGLE ABSOLUE ET NON-NÉGOCIABLE** : À chaque début de session, TOUS les fichiers du dossier `docs/copilot/` doivent être lus SANS EXCEPTION, y compris mais non limité à:

- `methodologie_temp.md` (instructions spéciales pour le développement du template)
- `README.md`
- `template_initialization.md`
- Tout nouveau fichier qui aurait pu être ajouté depuis

Cette règle s'applique AUTOMATIQUEMENT au démarrage de chaque session, SANS qu'il soit nécessaire que l'utilisateur le demande explicitement. L'assistant ne doit JAMAIS omettre la lecture de l'un quelconque de ces documents, car ils contiennent des informations CRITIQUES pour le bon déroulement du projet.

## 3. Protocole de communication et validation

### 3.1 Format des demandes de validation

Pour toute proposition d'action, utiliser strictement ce format :

```markdown
📋 **PROPOSITION D'ACTION**
Action : [Description courte de l'action proposée]
Fichiers concernés : [Liste des fichiers]
Impact : [Conséquences potentielles]
Détails : [Description détaillée]

Valides-tu cette action ? [oui/non/modifier]
```

### 3.2 Niveaux de détail des propositions

- **Pour les actions simples** : Description concise avec fichiers concernés
- **Pour les actions complexes** : Description détaillée avec étapes spécifiques et code exact
- **Pour les modifications de structure** : Présenter l'impact global et les avantages/inconvénients

### 3.3 Automatisation des actions Git

#### 3.3.1 Déclencheurs pour l'automatisation Git

**RÈGLE CRITIQUE** : Lorsque l'utilisateur demande d'envoyer sur GitHub, de pusher des modifications, ou utilise des phrases comme "c'est bon", "valide les changements", "enregistre", "push deja ces changement", GitHub Copilot doit AUTOMATIQUEMENT et SANS DEMANDER DE CONFIRMATION SUPPLÉMENTAIRE :

1. Exécuter immédiatement le script `./scripts/git_autocommit.sh` (voir ci-dessous)
2. Ne pas demander d'instructions supplémentaires ou de confirmation
3. Exécuter le script en mode non-interactif par défaut

#### 3.3.2 Actions automatiques avec git_autocommit.sh

Le script `git_autocommit.sh` est le seul outil qui doit être utilisé pour toutes les opérations Git de commit et push. Ce script:

1. **Vérifie l'état** du dépôt Git avec `git status`
2. **Identifie les fichiers modifiés** qui doivent être ajoutés à l'index
3. **Ajoute les fichiers pertinents** à l'index avec `git add`
4. **Propose un message de commit** adapté au contenu des modifications
5. **Crée un commit** avec le message généré automatiquement
6. **Pousse les changements** vers la branche distante appropriée
7. **Confirme** que les changements ont bien été envoyés

**Utilisation du script d'automatisation** :

```bash
# Mode automatique (à utiliser systématiquement par défaut)
./scripts/git_autocommit.sh

# Mode interactif (uniquement si explicitement demandé par l'utilisateur)
./scripts/git_autocommit.sh --interactive
# ou
./scripts/git_autocommit.sh -i
```

En mode interactif, l'utilisateur peut :

- Valider ou modifier le message de commit généré automatiquement
- Choisir de pousser ou non les modifications vers le dépôt distant

Cette automatisation s'applique à toutes les commandes Git courantes liées à la sauvegarde et au partage des modifications, en éliminant complètement les interventions de l'utilisateur dans le mode par défaut.

## 4. Documentation et continuité

### 4.1 Documentation systématique

- Documenter toute modification significative dans les fichiers appropriés
- Consigner les commandes exécutées et leur résultat
- Mettre à jour le fichier `docs/chat_resume.md` après chaque session importante

### 4.2 Création de nouvelles sessions documentées

Pour les sessions importantes, créer un nouveau fichier de session dans `docs/copilot/sessions/` contenant :

- Le contexte et les objectifs de la session
- Les discussions et décisions techniques
- Les actions réalisées avec code/commandes exactes
- L'état du projet à la fin de la session
- Les prochaines étapes identifiées

## 5. Règles spécifiques

### 5.1 Correction des erreurs de formatage Markdown

- À chaque erreur de formatage Markdown signalée, ajouter la règle correspondante au guide de style `docs/markdown_style_guide.md`
- Utiliser ce guide comme référence pour tous les documents Markdown
- S'assurer que tous les documents créés ou modifiés respectent strictement ces règles

### 5.2 Instructions pour l'initialisation du template

Lorsque l'utilisateur utilise ce projet comme template :

- Guider l'utilisateur pour renommer le projet (si non fait avec `init_project.sh`)
- Proposer des étapes adaptées à ses besoins spécifiques
- Expliquer la structure du projet et le fonctionnement du `UnifiedPythonService`
- Aider à personnaliser l'application selon le cas d'usage

## 6. Gestion des fichiers d'historique pour les nouveaux projets

### 6.1 Comportement au démarrage d'un nouveau projet depuis le template

Pour les utilisateurs qui créent un nouveau projet à partir de ce template :

- **Quand l'utilisateur dit** "lire les instructions" ou "lire la documentation" : GitHub Copilot doit immédiatement comprendre qu'il faut lire TOUTE la documentation disponible
- GitHub Copilot doit noter que les fichiers d'historique (`chat_resume.md` et fichiers dans `docs/copilot/sessions/`) seront initialement vides
- L'état initial du nouveau projet de l'utilisateur est "propre", sans historique de développement antérieur
- L'utilisateur est libre de définir sa propre stratégie de gestion de branches et d'historique pour son projet

### 6.2 Actions à entreprendre automatiquement pour un nouveau projet

Pour tout nouveau projet créé à partir du template, GitHub Copilot doit, sans qu'on le lui rappelle :

1. Créer le premier fichier de session dans `docs/copilot/sessions/` (format: `session_YYYYMMDD.md`)
2. Commencer à remplir le fichier `chat_resume.md` vide avec les informations de la première session
3. Suivre strictement toutes les règles de cette méthodologie dès le premier échange
4. Expliquer à l'utilisateur le fonctionnement de cette méthodologie de documentation

### 6.3 Explication de cette procédure à l'utilisateur

GitHub Copilot doit expliquer clairement à l'utilisateur que :

- Un système de documentation continue est en place
- Les sessions importantes seront documentées automatiquement
- Le fichier `chat_resume.md` servira de point d'entrée pour reprendre le travail
- Cette approche permettra une collaboration efficace sur le long terme

## 7. Aspects techniques importants

- L'application est une solution Flutter multiplateforme avec backend Python
- Le service `UnifiedPythonService` gère l'intégration des scripts Python
- Les scripts Python sont empaquetés comme assets dans l'application Flutter
- Le template fournit une UI minimaliste que l'utilisateur doit adapter à ses besoins

## 8. Évolution de la méthodologie

### 8.1 Modification de la méthodologie par l'utilisateur

La méthodologie décrite dans ce document n'est pas figée et peut être adaptée selon les besoins spécifiques du projet :

- L'utilisateur peut demander à tout moment d'ajouter, modifier ou supprimer des règles méthodologiques
- Lorsque l'utilisateur demande un changement de méthodologie, GitHub Copilot appliquera ces modifications dans ce fichier (`instructions.md`)
- Les changements de méthodologie seront appliqués immédiatement pour la suite de la collaboration
- GitHub Copilot suivra toujours la version la plus récente de la méthodologie

### 8.2 Processus de modification

Pour modifier cette méthodologie, l'utilisateur peut simplement :

1. Indiquer clairement à GitHub Copilot quelles règles doivent être ajoutées, modifiées ou supprimées
2. Demander explicitement la mise à jour du fichier `instructions.md`
3. Vérifier les modifications proposées avant validation

Cette approche permet au projet d'évoluer et de s'adapter aux besoins changeants de l'utilisateur tout en maintenant une documentation claire des pratiques de travail.
