# Guide de style Markdown

Ce document définit les règles de formatage Markdown à suivre pour tous les documents du projet. L'objectif est de maintenir une documentation cohérente, lisible et maintenable.

## Règles générales

1. **Utilisez des titres pour structurer votre contenu**
   - Commencez chaque document par un titre de niveau 1 (`#`)
   - Utilisez les niveaux de titre de manière séquentielle (ne sautez pas de niveaux)

2. **Gardez les lignes à une longueur raisonnable**
   - Limitez vos lignes à environ 80-100 caractères pour une meilleure lisibilité

3. **Utilisez la syntaxe correcte pour les éléments Markdown**
   - Italique : `*texte*` ou `_texte_`
   - Gras : `**texte**` ou `__texte__`
   - Code inline : `` `code` ``

## Espacement et formatage

### MD009 : Espaces en fin de ligne

- Évitez les espaces en fin de ligne (trailing spaces)
- Pour les sauts de ligne forcés, utilisez exactement deux espaces en fin de ligne, pas plus
- Préférez utiliser des lignes vides pour séparer les paragraphes plutôt que des espaces en fin de ligne

### MD012 : Lignes vides consécutives

- N'utilisez jamais plus d'une ligne vide consécutive
- Utilisez exactement une ligne vide pour séparer les paragraphes et les sections

### MD032 : Lignes vides autour des listes

- Toujours entourer les listes de lignes vides, avant et après

### MD031 : Lignes vides autour des blocs de code

- Entourez les blocs de code avec des lignes vides (avant et après)

## Listes

### MD007 : Indentation des listes à puces

- Indentez les sous-listes avec 2 ou 4 espaces (soyez cohérent)

### MD030 : Espaces après les marqueurs de liste

- Utilisez un seul espace après les marqueurs de liste à puces (`-`, `*`, `+`)
- Utilisez un espace après les numéros pour les listes ordonnées

### MD029 : Style de numérotation des listes ordonnées

- Utilisez toujours la numérotation séquentielle (1, 2, 3...) pour les listes ordonnées
- Ne réinitialisez pas la numérotation à 1 au milieu d'une liste

## Blocs de code

### MD040 : Langue des blocs de code

- Spécifiez toujours le langage dans les blocs de code délimités
- Utilisez "text" comme langage si aucun langage spécifique n'est applicable

### MD048 : Style de délimitation des blocs de code

- Utilisez des backticks (`` ``` ``) plutôt que des tildes (`~~~`) pour les blocs de code

## Liens et images

### MD034 : URLs brutes

- Évitez les URLs brutes, utilisez plutôt la syntaxe des liens Markdown

### MD033 : HTML inline

- Évitez d'utiliser du HTML dans les documents Markdown sauf si absolument nécessaire

## Titres

### MD001 : Niveaux de titre

- Ne sautez pas de niveaux de titre (ex : de `#` à `###` sans `##`)

### MD026 : Ponctuation dans les titres

- Évitez d'utiliser la ponctuation à la fin des titres (., :, ;)

## Cohérence

### MD047 : Fichiers se terminant par une nouvelle ligne

- Tous les fichiers doivent se terminer par une nouvelle ligne

### MD041 : Premier élément du document

- Le premier élément d'un fichier doit être un titre de niveau 1

## Outils recommandés

Pour vous aider à respecter ces règles, nous recommandons l'utilisation de:

1. **markdownlint** : Extension VS Code pour vérifier le formatage Markdown
2. **Prettier** : Pour formater automatiquement les documents

## Gestion des blocs de code imbriqués

### MD049 : Exemples de syntaxe Markdown

Pour montrer des exemples de syntaxe Markdown dans un document Markdown:

1. Utilisez plus de backticks pour le bloc extérieur (ex: quatre backticks pour entourer un bloc de trois backticks)

2. Ou échappez les backticks internes avec des caractères d'échappement (`\`)

Note: Pour les exemples complexes, envisagez d'utiliser des captures d'écran plutôt que d'essayer de représenter du code Markdown imbriqué.
