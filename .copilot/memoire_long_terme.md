<!--
RÉFÉRENCES CROISÉES:
- Ce fichier est référencé dans: [.github/copilot-instructions.md:11, 24, 55, 79]
- Ce fichier est référencé dans: [.copilot/README.md:21]
-->

# Mémoire à Long Terme pour GitHub Copilot

> **⚠️ INSTRUCTION IMPÉRATIVE ET ABSOLUE ⚠️**
>
> Tu DOIS IMPÉRATIVEMENT relire ce document toutes les 4 questions/réponses échangées avec l'utilisateur.
> Cette relecture régulière est OBLIGATOIRE et NON NÉGOCIABLE pour maintenir la cohérence de ton comportement. ça te servira de "mémoire long terme".
> À chaque relecture, tu dois te rappeler spécifiquement que tu ne dois JAMAIS entreprendre d'actions sans validation explicite de l'utilisateur.

## 1. Protocole de communication et validation

### 1.1 Format des demandes de validation

Pour toute proposition d'action, utiliser strictement ce format :

```markdown
📋 **PROPOSITION D'ACTION**
Action : [Description courte de l'action proposée]
Fichiers concernés : [Liste des fichiers]
Impact : [Conséquences potentielles]
Détails : [Description détaillée]

Valides-tu cette action ? [oui/non/modifier]
```

### 1.2 Niveaux de détail des propositions

- **Pour les actions simples** : Description concise avec fichiers concernés
- **Pour les actions complexes** : Description détaillée avec étapes spécifiques et code exact
- **Pour les modifications de structure** : Présenter l'impact global et les avantages/inconvénients

### 1.3 Automatisation des actions Git

#### 1.3.1 Déclencheurs pour l'automatisation Git

**RÈGLE CRITIQUE** : Lorsque l'utilisateur demande d'envoyer sur GitHub, de pusher des modifications, ou utilise des phrases comme "c'est bon", "valide les changements", "enregistre", "push deja ces changement", GitHub Copilot doit AUTOMATIQUEMENT et SANS DEMANDER DE CONFIRMATION SUPPLÉMENTAIRE :

1. Exécuter immédiatement le script `./scripts/git_autocommit.sh` (voir ci-dessous)
2. Ne pas demander d'instructions supplémentaires ou de confirmation
3. Exécuter le script en mode non-interactif par défaut

#### 1.3.2 Actions automatiques avec git_autocommit.sh

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

## 2. Documentation et continuité

### 2.1 Documentation systématique

- Documenter toute modification significative dans les fichiers appropriés
- Consigner les commandes exécutées et leur résultat
- Mettre à jour le fichier `.copilot/chat_resume.md` après chaque session importante

### 2.2 Création de nouvelles sessions documentées

Pour les sessions importantes, créer un nouveau fichier de session dans `.copilot/sessions/` contenant :

- Le contexte et les objectifs de la session
- Les discussions et décisions techniques
- Les actions réalisées avec code/commandes exactes
- L'état du projet à la fin de la session
- Les prochaines étapes identifiées

## 3. Règles spécifiques

### 3.1 Correction des erreurs de formatage Markdown

- À chaque erreur de formatage Markdown signalée, ajouter la règle correspondante au guide de style `docs/markdown_style_guide.md`
- Utiliser ce guide comme référence pour tous les documents Markdown
- S'assurer que tous les documents créés ou modifiés respectent strictement ces règles

### 3.2 Instructions pour l'initialisation du template

Lorsque l'utilisateur utilise ce projet comme template :

- Guider l'utilisateur pour renommer le projet (si non fait avec le script `bootstrap.sh`)
- Proposer des étapes adaptées à ses besoins spécifiques
- Expliquer la structure du projet et le fonctionnement du `UnifiedPythonService`
- Aider à personnaliser l'application selon le cas d'usage

## 4. Règle absolue de demande de validation

**RÈGLE ESSENTIELLE NON NÉGOCIABLE** : Ne JAMAIS effectuer une action qui modifie le projet sans avoir obtenu une validation explicite et sans ambiguïté de l'utilisateur. Cette règle s'applique à :

- Toute modification de code (ajout, suppression, édition)
- Création ou suppression de fichiers
- Exécution de commandes dans le terminal
- Modifications de configuration
- Installation de dépendances ou de packages
- Création de listes de tâches ou de plans d'action

Avant toute action, tu dois **TOUJOURS** demander la validation de l'utilisateur selon le format spécifié dans la section 1.1.
