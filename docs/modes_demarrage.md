# Analyse des modes de démarrage

Date: 2025-09-16

## Comparaison des scripts de démarrage

### `run_dev.sh/bat` (Mode développement complet)

**Caractéristiques:**

- Utilise le backend FastAPI complet (`web_backend/main.py`)
- Effectue le packaging des scripts Python vers les assets Flutter
- Utilise tmux (Linux) ou plusieurs fenêtres cmd (Windows) pour gérer les processus
- Définit la variable d'environnement `FLUTTER_DEV_MODE=true`
- Lance l'application Flutter en mode Chrome

**Usage typique:**

- Développement complet avec accès à toutes les fonctionnalités du backend
- Environnement qui reflète mieux la production
- Développement et test de nouvelles API

### `start_web_integrated.sh/bat` (Mode web intégré)

**Caractéristiques:**

- Utilise un serveur Python minimal via `web_adapter.py`
- Installe les dépendances Python avec l'option `--extras web`
- Ne fait pas de packaging des scripts Python
- Démarre un seul processus Python en arrière-plan
- Lance l'application Flutter en mode web-server

**Usage typique:**
- Tests rapides d'interface utilisateur
- Développement axé principalement sur le frontend
- Exécution plus légère avec moins de dépendances

## Proposition de simplification

### Option 1: Clarifier la documentation et maintenir les deux scripts

Garder les deux scripts mais mieux documenter leurs différences et cas d'utilisation:

- `run_dev.sh` : Pour le développement complet (backend FastAPI + Flutter)
- `start_web_integrated.sh` : Pour le développement web léger (serveur Python minimal + Flutter)

### Option 2: Fusionner en un seul script avec un paramètre de mode

```bash
# Exemple pour Linux
./run_dev.sh --mode=full|web-only

# Exemple pour Windows
run_dev.bat --mode=full|web-only
```

### Option 3: Rendre le script de développement web obsolète

Si le mode développement complet couvre tous les besoins, nous pourrions déplacer les scripts `start_web_integrated.*` vers le répertoire `archived_scripts/`.

## Recommandation

L'option 1 semble la plus appropriée car les deux modes semblent avoir des cas d'utilisation distincts. Néanmoins, il faudrait:

1. Mettre à jour la documentation pour expliquer clairement quand utiliser chaque script
2. Normaliser les noms pour plus de cohérence (par exemple: `run_dev_full.sh` et `run_dev_web.sh`)
3. S'assurer que les versions Linux/WSL et Windows restent synchronisées

Une décision devrait être prise en fonction des besoins réels du projet et de la fréquence d'utilisation de chaque mode.
