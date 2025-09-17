<!--
RÉFÉRENCES CROISÉES:
- Ce fichier est référencé dans: [README.md:56]
-->

# Extension avec des scripts et packages personnalisés

Ce guide explique comment étendre le projet yeb_app_template avec vos propres scripts Python et packages pour répondre à vos besoins spécifiques.

## Table des matières

- [Ajouter des scripts Python personnalisés](#ajouter-des-scripts-python-personnalisés)
- [Ajouter des packages Python personnalisés](#ajouter-des-packages-python-personnalisés)
- [Organiser les packages complexes](#organiser-les-packages-complexes)
- [Tester vos scripts et packages](#tester-vos-scripts-et-packages)
- [Intégration avec l'interface Flutter](#intégration-avec-linterface-flutter)

## Ajouter des scripts Python personnalisés

Le projet yeb_app_template est conçu pour faciliter l'ajout de scripts Python qui fonctionneront sur toutes les plateformes cibles (Android, iOS, Windows, Web, etc.).

### Emplacement des scripts

Tous les scripts Python doivent être placés dans le répertoire `shared_python/scripts/` pour être correctement détectés et empaquetés avec l'application.

```plaintext
yeb_app_template/
└── shared_python/
    └── scripts/
        ├── __init__.py  (obligatoire)
        ├── calcul_demo.py (exemple existant)
        └── mon_script.py (votre nouveau script)
```

### Structure d'un script

Chaque script doit suivre cette structure de base :

```python
"""
Description de votre script.
"""

# Importations nécessaires
import json
# ... autres importations ...

def fonction_utilitaire():
    """Documentation de la fonction utilitaire."""
    # ...
    pass

def main(*args):
    """
    Point d'entrée principal appelé par l'application.
    Cette fonction est OBLIGATOIRE et doit accepter un nombre variable d'arguments.

    Args:
        *args: Arguments variables passés depuis l'application Flutter

    Returns:
        Un dictionnaire qui sera automatiquement converti en JSON
    """
    try:
        # Traitement des arguments
        # ...

        # Votre logique métier
        # ...

        # Retourner le résultat sous forme de dictionnaire
        return {
            "resultat": "valeur",
            "autre_info": 42,
            # ...
        }
    except Exception as e:
        return {"erreur": str(e)}
```

### Bonnes pratiques

1. **Chaque script doit avoir une fonction `main()`** qui sert de point d'entrée
2. **Gérez les exceptions** pour éviter les crashs de l'application
3. **Documentez vos scripts** avec des docstrings et des commentaires
4. **Évitez les dépendances inutiles** pour garder l'application légère
5. **Retournez toujours des valeurs sérialisables** (dictionnaires, listes, types de base)

## Ajouter des packages Python personnalisés

Pour des fonctionnalités plus complexes, vous pouvez créer vos propres packages Python. Ce projet utilise `package-mode = false` dans son `pyproject.toml` principal, ce qui offre une flexibilité supplémentaire dans la façon dont vous pouvez organiser et créer vos packages.

### Options pour la création de packages

Vous disposez de plusieurs approches pour créer et utiliser des packages Python dans ce projet :

#### Option 1 : Packages informels dans le répertoire shared_python/packages/

Cette approche simple est idéale pour des composants réutilisables internes :

```plaintext
yeb_app_template/
└── shared_python/
    └── packages/
        └── mon_package/
            ├── __init__.py  (obligatoire)
            ├── module1.py
            ├── module2.py
            └── sous_package/
                ├── __init__.py
                └── autre_module.py
```

Pour l'utiliser dans vos scripts :

```python
# Dans scripts/mon_script.py
from packages.mon_package.module1 import fonction_principale

def main(*args):
    # Utilisation de la fonction du package
    resultat = fonction_principale(args[0])
    return {"resultat": resultat}
```

#### Option 2 : Packages formels installables

Pour des packages plus structurés que vous pourriez vouloir partager ou publier ultérieurement :

```plaintext
yeb_app_template/
└── shared_python/
    └── packages/
        └── mon_package_formel/
            ├── pyproject.toml  # Configuration Poetry spécifique au package
            ├── README.md
            └── src/
                └── mon_package_formel/
                    ├── __init__.py
                    └── module.py
```

Avec un `pyproject.toml` spécifique au package :

```toml
[tool.poetry]
name = "mon_package_formel"
version = "0.1.0"
description = "Description de mon package"
authors = ["Votre Nom <votre.email@example.com>"]
# Ici, on active le mode package pour ce package spécifique
packages = [{include = "mon_package_formel", from = "src"}]

[tool.poetry.dependencies]
python = ">=3.9,<3.13"
# Dépendances spécifiques à ce package
```

Pour installer ce package dans votre environnement principal :

```bash
cd shared_python
poetry add ../shared_python/packages/mon_package_formel
```

#### Option 3 : Développement en mode éditable

Pour un cycle de développement fluide avec vos packages formels :

```bash
cd shared_python
poetry add -e ../shared_python/packages/mon_package_formel
```

Le mode éditable (`-e`) permet de modifier le code source sans avoir à réinstaller le package après chaque modification.

#### Option 4 : Approche hybride avec imports relatifs

Une structure simplifiée qui fonctionne bien avec `package-mode = false` :

```plaintext
yeb_app_template/
└── shared_python/
    ├── __init__.py  # Marque le dossier comme package
    ├── packages/
    │   ├── __init__.py  # Permet l'importation via "from shared_python.packages..."
    │   └── mon_package/
    │       ├── __init__.py
    │       └── module.py
```

Utilisation dans les scripts :

```python
# Dans scripts/mon_script.py
from shared_python.packages.mon_package.module import ma_fonction

def main(*args):
    return {"resultat": ma_fonction(args[0])}
```

### Structure d'un package simple

Pour un package informel (Option 1 ou 4), suivez cette structure de base :

1. Créez un dossier avec le nom de votre package dans `shared_python/packages/`
2. Ajoutez un fichier `__init__.py` pour marquer le dossier comme un package Python
3. Créez vos modules (fichiers .py) à l'intérieur de ce dossier
4. Pour faciliter l'importation, exposez les fonctions principales dans `__init__.py` :

```python
# Dans __init__.py
from .module1 import fonction_principale
from .module2 import autre_fonction

__version__ = "0.1.0"
```

### Ajouter des dépendances

Pour ajouter des dépendances à votre projet :

**Méthode 1: Ajout via Poetry** (recommandé) :

```bash
cd shared_python
poetry add nom-du-package
```

**Méthode 2: Ajout manuel** dans `pyproject.toml` :

```toml
[tool.poetry.dependencies]
# Dépendances existantes...
mon-package = "^1.2.3"
```

Puis mettez à jour le lockfile :

```bash
cd shared_python
poetry lock
```

### Mode de package dans Poetry (`package-mode = false`)

Le projet utilise `package-mode = false` dans son `pyproject.toml` principal, ce qui offre plusieurs avantages :

1. **Structure flexible** : Vous n'êtes pas contraint à une structure de répertoire spécifique
2. **Facilité d'utilisation** : Poetry se concentre uniquement sur la gestion des dépendances
3. **Simplicité** : Pas besoin de configurer des chemins d'installation complexes
4. **Compatibilité avec l'intégration Flutter** : Idéal pour des scripts exécutés via `UnifiedPythonService`

Cette configuration est parfaite pour ce projet où les scripts Python sont souvent utilisés comme des utilitaires indépendants plutôt que comme un package Python traditionnel à importer.

Si vous créez des packages formels (Option 2), vous pouvez activer le mode package spécifiquement pour ces packages individuels, tout en conservant la flexibilité globale du projet.

## Organiser les packages complexes

Pour les projets complexes avec plusieurs packages :

### Structure recommandée

```plaintext
shared_python/
├── scripts/               # Scripts simples (points d'entrée)
│   ├── __init__.py
│   └── entry_point.py     # Appelle les fonctionnalités des packages
│
└── packages/
    ├── data_processing/   # Package pour le traitement des données
    │   ├── __init__.py
    │   └── processors.py
    │
    └── visualization/     # Package pour la visualisation
        ├── __init__.py
        └── plots.py
```

### Importations entre packages

Dans vos scripts, importez vos packages comme ceci :

```python
# Dans scripts/entry_point.py
from packages.data_processing import process_data
from packages.visualization import create_chart

def main(*args):
    data = process_data(args[0])
    chart = create_chart(data)
    return {"result": chart}
```

## Tester vos scripts et packages

### Tests locaux

Vous pouvez tester vos scripts Python directement en ligne de commande :

```bash
cd shared_python
python -c "import scripts.mon_script as ms; print(ms.main('argument1', 'argument2'))"
```

### Tests automatisés

1. Créez des tests dans le répertoire `shared_python/tests/`
2. Utilisez pytest pour lancer les tests :

```bash
cd shared_python
poetry run pytest
```

## Intégration avec l'interface Flutter

Pour appeler vos scripts Python depuis Flutter :

```dart
// Dans votre code Flutter
final result = await UnifiedPythonService.runScript(
  'scripts/mon_script',  // Chemin vers le script (sans extension .py)
  ["argument1", "argument2"],  // Arguments à passer au script
);

// Traiter le résultat (JSON)
final jsonResult = jsonDecode(result);
```

### Exemple complet d'intégration

```dart
Future<void> executerMonScript() async {
  setState(() {
    isLoading = true;
    resultat = "Traitement en cours...";
  });

  try {
    final output = await UnifiedPythonService.runScript(
      'scripts/mon_script',
      [argument1, argument2],
    );

    final jsonResult = jsonDecode(output);

    // Utiliser le résultat
    setState(() {
      resultat = "Traitement terminé :\n";
      jsonResult.forEach((key, value) {
        resultat += "\n• $key: $value";
      });
    });
  } catch (e) {
    setState(() {
      resultat = "Erreur: $e";
    });
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}
```

---

N'hésitez pas à consulter les exemples fournis dans le dossier `shared_python/scripts/` comme point de départ pour vos propres développements.N'hésitez pas à consulter les exemples fournis dans le dossier `shared_python/scripts/` comme point de départ pour vos propres développements.
