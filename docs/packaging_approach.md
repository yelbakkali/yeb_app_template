# Approche de Packaging pour Scripts Python

Ce document explique l'approche de packaging adoptée pour gérer les scripts Python dans l'application 737calcs.

## Résumé

Notre application Flutter multiplateforme utilise des scripts Python pour effectuer des calculs spécifiques. Pour assurer une gestion cohérente de ces scripts à travers toutes les plateformes (Android, iOS, Windows, Web), nous avons adopté une approche basée sur le **packaging des scripts Python comme assets** de l'application Flutter.

## Avantages de l'approche de packaging

1. **Déploiement unifié** : Les scripts Python sont empaquetés dans l'application Flutter, garantissant que la même version est utilisée sur toutes les plateformes.
2. **Maintenabilité améliorée** : Une seule source de vérité pour les scripts Python.
3. **Pas de synchronisation manuelle** : Plus besoin de synchroniser manuellement les scripts entre les différentes plateformes.
4. **Compatibilité avec le processus de build** : S'intègre facilement aux workflows CI/CD.
5. **Facilité de mise à jour** : Mettre à jour un script le met à jour pour toutes les plateformes.

## Comment ça fonctionne

1. Les scripts Python sont placés dans le dossier `shared_python/` à la racine du projet.
2. Le script `package_python_scripts.sh` copie ces scripts dans le dossier `flutter_app/assets/shared_python/`.
3. Le fichier `pubspec.yaml` référence ces assets pour qu'ils soient inclus dans le package Flutter.
4. Le service `UnifiedPythonService` extrait ces scripts au runtime dans un dossier temporaire sur chaque plateforme.
5. Des scripts spécifiques à chaque plateforme garantissent que les scripts sont correctement intégrés :
   - Android : Configuration Chaquopy via `python_config.gradle.kts`
   - iOS : Script build phase `extract_python_scripts.sh`
   - Windows : Extraction automatique via `UnifiedPythonService`
   - Web : API backend qui accède aux mêmes scripts

## Fonctionnement par plateforme

### Android

Les scripts Python sont extraits des assets par `UnifiedPythonService` et exécutés via Chaquopy. La configuration Gradle assure que les scripts sont disponibles pour l'exécution.

### iOS

Les scripts sont extraits au runtime par `UnifiedPythonService` et un script de build phase les copie également dans le bundle de l'application pour l'exécution via Python-Apple-support.

### Windows

Les scripts sont extraits au runtime et exécutés via le Python embarqué situé dans `windows/python_embedded/`.

### Web

Une API backend (FastAPI) accède aux mêmes scripts Python et expose leurs fonctionnalités via des endpoints HTTP.

## Mode développement vs. production

- **Mode développement** : Un mode spécial (`FLUTTER_DEV_MODE`) permet d'accéder directement aux scripts dans le dossier `shared_python/` pour faciliter le développement sans avoir à repackager à chaque modification.
- **Mode production** : Les scripts sont extraits des assets au runtime, garantissant que la version empaquetée est utilisée.

## Scripts utilitaires

- `package_python_scripts.sh` : Prépare les scripts Python pour le packaging.
- `run_dev_direct.sh` : Lance l'application en mode développement avec accès direct aux scripts.
- `extract_python_scripts.sh` : Script pour iOS pour extraire les scripts Python pendant le build.

## Maintenance et mise à jour

Pour mettre à jour les scripts Python :

1. Modifiez les scripts dans le dossier `shared_python/`.
2. Exécutez `package_python_scripts.sh` pour mettre à jour les assets.
3. Reconstruisez l'application Flutter.

Cette approche garantit que tous les utilisateurs obtiennent les mêmes fonctionnalités de calcul sur toutes les plateformes, tout en minimisant la complexité de maintenance.
