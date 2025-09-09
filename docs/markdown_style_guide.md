# Guide de style Markdown pour yeb_app_template

Ce document définit les conventions de formatage Markdown à suivre pour tous les fichiers de documentation dans le projet yeb_app_template.

## Règles générales

- Tous les fichiers doivent se terminer par une seule ligne vide (MD047)
- Éviter les espaces en fin de ligne (MD009)
- Utiliser des espaces pour l'indentation, pas des tabulations (MD010)
- Ne pas dépasser 100 caractères par ligne pour le texte (MD013)

## Titres

- Les titres doivent être précédés d'une ligne vide, sauf au début du document (MD022)
- Les titres doivent être suivis d'une ligne vide (MD022)
- Pas d'espaces en fin des titres (MD009)
- Utiliser la syntaxe ATX pour les titres (`#`, `##`, etc.) et non la syntaxe Setext (soulignement) (MD003)
- Les titres de même niveau doivent utiliser un style cohérent (MD003)

```markdown
# Titre de niveau 1

## Titre de niveau 2

Texte...

### Titre de niveau 3

Texte...
```

## Listes

- Les listes doivent être précédées d'une ligne vide (MD032)
- Utiliser des tirets (`-`) pour les listes non ordonnées plutôt que des astérisques (`*`)
- Utiliser des chiffres suivis d'un point pour les listes ordonnées
- Indenter les listes imbriquées de 2 ou 4 espaces

```markdown
Texte précédant une liste.

- Élément 1
- Élément 2
  - Sous-élément 2.1
  - Sous-élément 2.2
- Élément 3

1. Premier élément
2. Deuxième élément
```

## Blocs de code

- Les blocs de code délimités doivent spécifier un langage (MD040)
- Les blocs de code doivent être entourés de lignes vides (MD031)
- Utiliser des blocs délimités (triple backtick) plutôt que l'indentation pour les blocs de code

```markdown
Voici un exemple de code :

```dart
void main() {
  print('Hello, world!');
}
```

Le texte continue ici.
```

## Liens et références

- Utiliser la syntaxe de référence pour les liens répétés
- Les URL ne doivent pas être écrites en texte brut dans le document

```markdown
[Texte du lien](https://exemple.com)

<!-- Pour les liens répétés -->
[Texte du lien][reference]

<!-- Plus bas dans le document -->
[reference]: https://exemple.com
```

## Mise en forme du texte

- Utiliser des double-astérisques pour le texte en gras: `**texte en gras**`
- Utiliser des underscores simples pour l'italique: `_texte en italique_`
- Utiliser des backticks pour le code en ligne: `` `code` ``

## Tableaux

- Les tableaux doivent avoir une ligne d'en-tête et une ligne de séparation
- Aligner les délimiteurs de colonnes pour une meilleure lisibilité

```markdown
| Colonne 1 | Colonne 2 | Colonne 3 |
|-----------|-----------|-----------|
| Valeur 1  | Valeur 2  | Valeur 3  |
| Valeur 4  | Valeur 5  | Valeur 6  |
```

## Citations

- Les blocs de citation doivent être précédés d'une ligne vide
- Les blocs de citation doivent être suivis d'une ligne vide

```markdown
Texte précédant une citation.

> Ceci est une citation.
> Elle peut s'étendre sur plusieurs lignes.

Le texte continue ici.
```

## Validation

- Utiliser des outils de linting comme markdownlint pour valider les fichiers
- Dans VS Code, installer l'extension "markdownlint" de David Anson
