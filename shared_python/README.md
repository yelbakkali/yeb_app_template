# Scripts Python partagés

Ce dossier contient tous les scripts Python partagés utilisés par l'application yeb_app_template.

## Structure

- `scripts/` : Contient les scripts Python simples exécutables
- `packages/` : Contient les packages Python plus complexes
- `web_adapter.py` : Interface FastAPI pour l'exécution des scripts via le web

## Utilisation

Les scripts peuvent être appelés depuis l'application Flutter via le service UnifiedPythonService.
Pour le mode web, les scripts sont accessibles via l'API REST exposée par web_adapter.py.