# Résumé de la conversation sur le projet 737calcs

Ce document résume les principaux points abordés dans notre conversation sur le développement du projet 737calcs. Il peut être utilisé pour reprendre une conversation interrompue avec un assistant IA.

## Contexte du projet

- **Projet** : Application 737calcs - Application Flutter multiplateforme avec calculs en Python
- **Objectif** : Intégrer des scripts Python pour effectuer des calculs spécifiques sur plusieurs plateformes (Android, iOS, Windows, Web)
- **État actuel** : Architecture de packaging mise en place avec `UnifiedPythonService`

## Principales décisions techniques

1. **Approche de packaging pour les scripts Python**
   - Les scripts sont développés dans `shared_python/`
   - Ils sont inclus comme assets dans l'application Flutter
   - Le service `UnifiedPythonService` les extrait et les exécute au runtime

2. **Intégration spécifique par plateforme**
   - Android : Chaquopy
   - iOS : Python-Apple-support
   - Windows : Python Embeddable
   - Web : API FastAPI

3. **Structure des branches Git**
   - `main` : Branche de production stable
   - `dev` : Branche de développement

## Fichiers clés créés/modifiés

- `/flutter_app/lib/services/unified_python_service.dart` : Service central d'exécution Python
- `/package_python_scripts.sh` : Script de préparation des assets Python
- `/flutter_app/android/app/python_config.gradle.kts` : Configuration pour Android
- `/flutter_app/ios/extract_python_scripts.sh` : Configuration pour iOS
- `/docs/packaging_approach.md` : Documentation de l'approche de packaging
- `/docs/git_workflow.md` : Documentation du workflow Git

## Travail en cours

- Configuration du workflow avec branches `main` (production) et `dev` (développement)
- Mise en place de la documentation pour le projet
- Nettoyage des fichiers redondants suite à l'adoption de l'approche de packaging

## Prochaines étapes discutées

- Implémentation des calculs spécifiques au 737
- Amélioration de l'interface utilisateur
- Mise en place de tests
