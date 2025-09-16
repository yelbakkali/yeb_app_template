# Web Backend pour yeb_app_template

Ce module est le backend web de yeb_app_template, construit avec FastAPI, pour offrir une API RESTful qui exécute les mêmes calculs que les versions mobile et desktop.

## Prérequis

- Python 3.9 ou plus récent
- Poetry (gestionnaire de dépendances Python)

## Installation

1. Assurez-vous que Poetry est installé :

   ```bash
   curl -sSL https://install.python-poetry.org | python3 -
   ```

2. Installez les dépendances :

   ```bash
   cd web_backend
   poetry install
   ```

## Démarrage du serveur

Vous pouvez démarrer le serveur de deux façons :

### Option 1 : Avec le script de démarrage

```bash
./start_server.sh
```

### Option 2 : Manuellement

```bash
cd web_backend
poetry run python main.py
```

Par défaut, le serveur démarre sur le port 8000. Vous pouvez changer le port en définissant la variable d'environnement `PORT` :

```bash
PORT=8080 poetry run python main.py
```

## Utilisation de l'API

### Vérification du serveur

```http
GET http://localhost:8000/
```

Réponse attendue :

```json
{
  "message": "yeb_app_template API est en ligne. Utilisez /api/run_script pour exécuter des calculs."
}
```

### Exécution d'un calcul

```http
POST http://localhost:8000/api/run_script
```

Exemple de corps de requête :

```json
{
  "script_name": "calcul_demo",
  "args": ["5", "3"]
}
```

Réponse attendue :

```json
{
  "result": {
    "somme": 8.0,
    "différence": 2.0,
    "produit": 15.0,
    "quotient": 1.6666666666666667
  }
}
```

## Intégration avec Flutter

Dans votre application Flutter, utilisez le package HTTP pour vous connecter à cette API lorsque l'application s'exécute en mode web.
