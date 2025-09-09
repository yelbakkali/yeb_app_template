# Instructions pour la collaboration avec GitHub Copilot

## Règles de communication et d'action

1. **Validation obligatoire**
   - L'assistant doit demander une validation explicite avant toute action modifiant le projet
   - Les propositions doivent être précises et inclure les détails de mise en œuvre

2. **Documentation systématique**
   - Toute modification proposée pour les fichiers de documentation doit être présentée avant implémentation
   - Les instructions de terminal et commandes exécutées doivent être consignées

3. **Continuité du travail**
   - À chaque nouvelle session, l'assistant doit consulter les fichiers de documentation
   - L'assistant doit analyser la structure du projet pour comprendre le contexte technique actuel
   - L'assistant doit identifier les patterns d'architecture, dépendances et composants clés
   - L'assistant doit fournir un résumé des dernières étapes réalisées au début de chaque session

4. **Format des interactions**
   - Les instructions techniques complexes doivent être accompagnées d'explications claires
   - Les options disponibles doivent être présentées avant de procéder à une implémentation

5. **Correction des fichiers Markdown**
   - L'assistant doit systématiquement vérifier et corriger les erreurs de formatage Markdown dans tous les fichiers
   - Les fichiers doivent respecter le guide de style Markdown défini dans `docs/markdown_style_guide.md`
   - Points particulièrement importants à respecter :
     - Chaque fichier doit se terminer par une seule ligne vide (MD047)
     - Les titres doivent être précédés d'une ligne vide, sauf s'ils commencent le document (MD022)
     - Les blocs de code délimités doivent spécifier un langage (MD040) et être entourés de lignes vides (MD031)
     - Les listes doivent être précédées d'une ligne vide (MD032)
     - Utiliser des tirets (`-`) pour les éléments de liste plutôt que des astérisques (*)
   - L'assistant doit appliquer ces règles à chaque création ou modification de fichier Markdown
   - En cas de doute, se référer au guide de style complet dans `docs/markdown_style_guide.md`

## Format des demandes de validation

L'assistant utilisera le format suivant pour les demandes de validation:

```markdown
📋 **PROPOSITION D'ACTION**
Action : [Description courte de l'action proposée]
Fichiers concernés : [Liste des fichiers]
Impact : [Conséquences potentielles]
Détails : [Description détaillée]

Valides-tu cette action ? [oui/non/modifier]
```

## Méthode de reprise du travail

Lorsque l'instruction "lire les fichiers dans docs/copilot" est donnée, l'assistant doit:

1. Consulter le fichier de résumé global
2. Examiner la dernière session documentée
3. Présenter un récapitulatif des dernières actions et de l'état actuel du projet
4. Proposer les prochaines étapes logiques

## Instructions spéciales pour l'initialisation du template

Lorsque l'utilisateur demande de "lire la documentation dans docs/" après avoir créé un projet à partir du template, l'assistant doit :

1. Consulter le fichier `docs/copilot/template_initialization.md`
2. Suivre les étapes décrites pour guider l'utilisateur dans la personnalisation du template
3. Offrir une assistance proactive pour :
   - Renommer le projet (si ce n'est pas déjà fait par `init_project.sh`)
   - Personnaliser l'application selon les besoins spécifiques
   - Configurer les environnements de développement
   - Ajouter de nouveaux modules Python et écrans Flutter

L'assistant doit adopter une approche guidée par étapes, en commençant par un résumé de la structure du projet et en proposant ensuite un plan d'action adapté aux besoins exprimés par l'utilisateur.
