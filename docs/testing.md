<!--
RÉFÉRENCES CROISÉES:
- Ce fichier est référencé dans: [template/bootstrap.sh:208]
-->

# Structure des Tests dans Yeb App Template

## Tests Flutter

Tous les tests Flutter de l'application sont situés exclusivement dans le sous-répertoire `flutter_app/test/`.

Pour exécuter ces tests :

```bash
cd flutter_app
flutter test
```

## Tests Python

Les tests pour les backends Python sont organisés dans leurs répertoires respectifs :

- Tests du backend web : `web_backend/tests/`
- Tests du backend Python : `python_backend/tests/`

Pour exécuter ces tests, utilisez les commandes appropriées dans chaque répertoire.

## Note Importante

Le répertoire `test` à la racine du projet a été supprimé pour éviter les problèmes d'importation avec l'application Flutter qui se trouve dans un sous-répertoire.

Si vous avez besoin d'ajouter des tests au niveau racine du projet, ils devraient être limités à des tests d'intégration ou autres tests qui ne dépendent pas directement de l'implémentation des widgets Flutter.

## Configuration CI

Si vous configurez l'intégration continue pour ce projet, assurez-vous d'exécuter les tests Flutter à partir du répertoire `flutter_app` :

```yaml
# Exemple pour GitHub Actions
- name: Run Flutter Tests
  run: |
    cd flutter_app
    flutter test
```
