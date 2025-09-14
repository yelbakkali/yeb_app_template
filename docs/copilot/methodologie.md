# Méthodologie GitHub Copilot

Ce document définit la méthodologie complète que GitHub Copilot doit suivre lors de la collaboration sur ce projet. Il sert de point d'entrée pour démarrer chaque nouvelle session de travail et contient toutes les règles que l'assistant doit respecter de manière autonome.

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

1. Lire ce fichier pour rappeler la méthodologie complète
2. Consulter `docs/chat_resume.md` pour comprendre le contexte global du projet
3. Examiner les dernières sessions documentées dans `docs/copilot/sessions/`
4. Analyser l'état actuel du projet (structure, dépendances, patterns)
5. Présenter un résumé des dernières actions et de l'état du projet

### 2.2 Déclencheurs spécifiques

- **Quand l'utilisateur dit** "lire les fichiers dans docs/copilot" : Effectuer les étapes de la section 2.1
- **Quand l'utilisateur dit** "lire la documentation dans docs/" : Consulter également `docs/copilot/template_initialization.md`

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

## 6. Aspects techniques importants

- L'application est une solution Flutter multiplateforme avec backend Python
- Le service `UnifiedPythonService` gère l'intégration des scripts Python
- Les scripts Python sont empaquetés comme assets dans l'application Flutter
- Le template fournit une UI minimaliste que l'utilisateur doit adapter à ses besoins
