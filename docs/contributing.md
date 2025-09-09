# Guide de contribution

Merci de votre intérêt pour contribuer au projet yeb_app_template ! Ce guide vous aidera à comprendre comment vous pouvez participer efficacement au développement du projet.

## Processus de contribution

### 1. Choix d'une tâche

- Consultez les issues GitHub ouvertes pour trouver des tâches à réaliser.
- Les issues avec le label "good first issue" sont particulièrement adaptées aux nouveaux contributeurs.
- Vous pouvez également proposer vos propres améliorations en créant une nouvelle issue.

### 2. Fork et clone du dépôt

1. Effectuez un fork du dépôt sur votre compte GitHub.
2. Clonez votre fork localement :

   ```bash
   git clone https://github.com/votre-username/yeb_app_template.git
   cd yeb_app_template
   ```

3. Ajoutez le dépôt original comme remote "upstream" :

   ```bash
   git remote add upstream https://github.com/organisation-originale/yeb_app_template.git
   ```

### 3. Création d'une branche

Créez une branche dédiée à votre contribution :

```bash
git checkout -b feature/nom-de-votre-fonctionnalite
```

Utilisez un préfixe descriptif pour votre branche :

- `feature/` pour une nouvelle fonctionnalité
- `fix/` pour une correction de bug
- `docs/` pour des modifications de documentation
- `test/` pour l'ajout ou la modification de tests

### 4. Développement

- Assurez-vous de suivre les conventions de codage du projet.
- Écrivez des tests pour vos changements lorsque c'est pertinent.
- Maintenez votre code propre et bien documenté.
- Veillez à respecter les règles de formatage Markdown dans la documentation.

#### Correction automatique des erreurs Markdown

GitHub Copilot peut vous aider à corriger automatiquement les erreurs de formatage Markdown. Si vous rencontrez des problèmes de formatage dans vos documents Markdown :

1. Demandez à GitHub Copilot de vérifier et corriger le formatage
2. Les erreurs courantes qui peuvent être corrigées automatiquement incluent :
   - Espacement autour des blocs de code
   - Indentation incorrecte des listes
   - Espacement autour des titres
   - Spécification des langages pour les blocs de code
   - Numérotation des listes ordonnées

### 5. Tests locaux

Avant de soumettre vos modifications, assurez-vous que tous les tests passent :

```bash
# Pour les tests Flutter
cd flutter_app
flutter test

# Pour les tests Python du backend local
cd python_backend
poetry run pytest

# Pour les tests Python du backend web
cd web_backend
poetry run pytest
```

### 6. Commit et push

Faites des commits clairs et descriptifs :

```bash
git add .
git commit -m "Description concise de vos modifications"
git push origin feature/nom-de-votre-fonctionnalite
```

### 7. Pull Request

1. Allez sur GitHub et créez une Pull Request (PR) depuis votre branche vers la branche `dev` du dépôt original.
2. Donnez un titre clair à votre PR et décrivez en détail les modifications apportées.
3. Référencez les issues concernées en utilisant le préfixe "Fixes #" ou "Relates to #".

## Conventions de codage

### Code Dart/Flutter

- Suivez les [conventions de style Dart](https://dart.dev/guides/language/effective-dart/style).
- Utilisez `flutter format` pour formater votre code.
- Respectez les règles définies dans le fichier `analysis_options.yaml`.

### Code Python

- Suivez la [PEP 8](https://peps.python.org/pep-0008/) pour le style de code Python.
- Utilisez des docstrings pour documenter vos fonctions et classes.
- Préférez les annotations de type lorsque c'est possible.

## Processus de revue

- Les mainteneurs examineront votre PR et pourront demander des modifications.
- Les tests d'intégration continue (CI) seront exécutés automatiquement.
- Une fois votre PR approuvée, elle sera fusionnée dans la branche principale.

## Communication

- Utilisez les commentaires des issues et des PR pour discuter des détails techniques.
- Pour des discussions plus générales, utilisez les discussions GitHub du projet.
- Restez respectueux et constructif dans toutes vos interactions.

## Remerciements

Votre contribution est précieuse ! Tous les contributeurs sont crédités dans le fichier CONTRIBUTORS.md du projet.
