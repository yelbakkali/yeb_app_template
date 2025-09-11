# Méthodologie Template GitHub Copilot

> **Important** : Ce document est un complément au fichier principal `methodologie.md`. Assurez-vous d'avoir lu ce fichier principal en premier.

Ce document est un supplément à la méthodologie générale qui contient des instructions spécifiques au développement du template yeb_app_template. Ces informations ne sont pertinentes que pour les développeurs du template et ne seront pas incluses dans la version distribuée aux utilisateurs finaux.

## Instructions spécifiques pour le développement du template

### Stratégie de gestion de l'historique pendant le développement du template

Cette stratégie s'applique uniquement pendant le développement du template yeb_app_template, pas aux projets créés par les utilisateurs :

- **Branche `dev`** : Conserve l'historique complet du développement du template (fichier `chat_resume.md` et dossier `docs/copilot/sessions/`) pour référence et amélioration continue du template
- **Branche `main`** : Ne contient pas les fichiers d'historique, car elle est destinée aux utilisateurs finaux comme point de départ propre pour leurs projets

### Gestion des fichiers lors de la publication du template

Lors de la publication du template sur la branche `main`, les actions suivantes doivent être effectuées :

1. Ne pas inclure ce fichier (`methodologie_temp.md`) sur la branche `main`
2. Vider complètement les fichiers suivants :
   - `docs/chat_resume.md`
   - Tous les fichiers dans `docs/copilot/sessions/` (mais conserver le dossier)
3. S'assurer que les scripts d'initialisation (`init_project.sh`, `init_project.bat`) fonctionnent correctement

### Test du template avant publication

Avant de publier une nouvelle version du template sur la branche `main`, effectuer les tests suivants :

1. Cloner la branche `dev` dans un nouveau répertoire
2. Exécuter les scripts d'initialisation avec un nouveau nom de projet
3. Vérifier que les fichiers d'historique sont correctement vidés ou supprimés
4. Tester l'application Flutter et les scripts Python sur toutes les plateformes cibles

### Poursuite du développement du template

Pour continuer à améliorer le template après publication :

1. Toujours travailler sur la branche `dev`
2. Documenter toutes les améliorations dans les fichiers de session
3. Mettre à jour le fichier `chat_resume.md` avec les nouvelles fonctionnalités
4. Fusionner les améliorations vers `main` uniquement lorsqu'elles sont stables et testées

## ⚠️ RÈGLE CRITIQUE : GESTION DES BRANCHES ET FUSIONS ⚠️

### Fichiers strictement interdits sur la branche main

Les fichiers suivants NE DOIVENT ABSOLUMENT JAMAIS être inclus dans la branche `main` :

| Fichier/Dossier | Action requise avant fusion vers `main` |
|----------------|----------------------------------------|
| **`docs/copilot/methodologie_temp.md`** | **JAMAIS INCLUS** - Ce fichier doit être complètement exclu |
| **`scripts/merge_to_main.sh`** | **JAMAIS INCLUS** - Ce script d'automatisation doit être complètement exclu |
| **`docs/chat_resume.md`** | VIDER COMPLÈTEMENT - Ne conserver que l'en-tête |
| **`docs/copilot/sessions/*`** | VIDER TOUS LES FICHIERS - Conserver uniquement les dossiers vides |

### Procédure obligatoire pour tout push/merge vers main

Avant chaque push ou fusion vers la branche `main`, GitHub Copilot DOIT :

1. **RAPPELER** explicitement cette règle critique à l'utilisateur
2. **PROPOSER** une méthode spécifique pour exclure ces fichiers (branche temporaire, etc.)
3. **VÉRIFIER** après la fusion que ces fichiers ont bien été exclus ou vidés

GitHub Copilot ne doit JAMAIS oublier cette règle, quelle que soit la complexité de la tâche en cours.

### Script d'automatisation du merge

Un script d'automatisation pour la fusion de `dev` vers `main` est disponible dans le dossier `scripts/` :

| Fichier | Description | Action avant fusion vers `main` |
|---------|------------|--------------------------------|
| **`scripts/merge_to_main.sh`** | Script qui automatise la fusion de dev vers main avec exclusion des fichiers spécifiques | **JAMAIS INCLUS** - Ce script ne doit pas être inclus dans la branche `main` |

Ce script fait partie des outils de développement du template et ne doit donc pas être inclus dans la version distribuée aux utilisateurs finaux. Il doit être ajouté à la liste des fichiers à exclure lors de la fusion vers `main`.

### Exécution automatique du script de merge

**RÈGLE IMPORTANTE** : Lorsque l'utilisateur demande à GitHub Copilot de "merger" ou de "fusionner vers main" ou utilise des termes similaires, GitHub Copilot DOIT AUTOMATIQUEMENT :

1. **EXÉCUTER** le script `scripts/merge_to_main.sh` sans demander de confirmation préalable
2. **GUIDER** l'utilisateur à travers le processus interactif du script
3. **CONFIRMER** à la fin que le merge a été correctement effectué

Cette règle s'applique à toute demande de fusion de `dev` vers `main`, quelle que soit la formulation utilisée par l'utilisateur. Le script d'automatisation doit être utilisé systématiquement pour garantir le respect des règles d'exclusion des fichiers.

### Rappel du contexte

Ce fichier (`methodologie_temp.md`) ne doit jamais être poussé sur la branche `main` car il contient des informations internes sur le développement du template qui ne sont pas pertinentes pour les utilisateurs finaux.

## Instructions pour GitHub Copilot

GitHub Copilot: Lorsque tu travailles sur la branche `dev` du template, tu dois automatiquement:

1. Lire ce fichier chaque fois que tu lis `methodologie.md`
2. Appliquer les instructions spécifiques au développement du template décrites ici
3. Comprendre la distinction entre la gestion de l'historique sur les branches `dev` et `main`
4. Ne jamais mentionner ce fichier à un utilisateur qui n'est pas en train de travailler sur le développement du template lui-même
5. **TOUJOURS VÉRIFIER CE FICHIER AVANT TOUTE OPÉRATION IMPLIQUANT LA BRANCHE `main`**
6. **RAPPELER EXPLICITEMENT LES RÈGLES CONCERNANT LES FICHIERS À NE PAS INCLURE DANS `main`**

## Convention pour l'ajout de nouvelles instructions

Règle à suivre concernant l'ajout de nouvelles instructions méthodologiques :

1. Par défaut, toute nouvelle instruction de méthodologie doit être ajoutée au fichier principal `methodologie.md`, destiné à tous les utilisateurs

2. Des instructions seront ajoutées à ce fichier `methodologie_temp.md` uniquement si l'utilisateur le demande explicitement en précisant qu'elles concernent "la méthodologie du template" ou "le développement du template"

3. GitHub Copilot doit strictement respecter cette convention pour maintenir la séparation entre les instructions générales et les instructions spécifiques au développement du template
