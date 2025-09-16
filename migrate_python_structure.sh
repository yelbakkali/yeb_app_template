#!/bin/bash
# Script pour migrer vers la nouvelle structure de dossiers Python unifiée

# Répertoire du projet
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

# Créer la nouvelle structure si elle n'existe pas déjà
mkdir -p shared_python/scripts
mkdir -p shared_python/packages

# Déplacer les scripts Python existants vers le dossier scripts
find shared_python -maxdepth 1 -name "*.py" -not -name "__init__.py" | while read script; do
    filename=$(basename "$script")
    if [ -f "shared_python/scripts/$filename" ]; then
        echo "Le fichier $filename existe déjà dans scripts/, vérification des différences..."
        diff "$script" "shared_python/scripts/$filename"
        if [ $? -ne 0 ]; then
            echo "Les fichiers sont différents, sauvegarde de l'original..."
            cp "$script" "shared_python/scripts/${filename}.old"
        fi
    else
        echo "Déplacement de $script vers scripts/"
        mv "$script" "shared_python/scripts/"
    fi
done

# Mettre à jour le __init__.py pour la nouvelle structure
cat > shared_python/__init__.py << 'EOF'
"""
Package partagé pour les scripts Python utilisés dans l'application Flutter.
Cette structure unifiée permet d'organiser les scripts Python en un seul endroit,
tout en les rendant accessibles sur toutes les plateformes (Android, iOS, Windows, Web).

Organisation:
- scripts/: Contient des scripts Python simples directement exécutables
- packages/: Contient des packages Python plus complexes
- web_adapter.py: Mini serveur pour le mode web intégré à l'application
"""

__version__ = "1.0.0"

# Faciliter l'import des scripts et packages
from . import scripts
from . import packages

# Exposer le démarrage du serveur web
try:
    from .web_adapter import start_server
except ImportError:
    # Les dépendances web ne sont pas installées
    def start_server(*args, **kwargs):
        raise ImportError("Les dépendances pour le mode web ne sont pas installées. "
                         "Installez-les avec: poetry install --extras web")
EOF

# Créer les fichiers __init__.py dans les sous-dossiers s'ils n'existent pas
if [ ! -f "shared_python/scripts/__init__.py" ]; then
    cat > shared_python/scripts/__init__.py << 'EOF'
"""
Package scripts contenant tous les scripts Python utilisables par l'application Flutter.
"""

__version__ = "1.0.0"
EOF
fi

if [ ! -f "shared_python/packages/__init__.py" ]; then
    cat > shared_python/packages/__init__.py << 'EOF'
"""
Package packages contenant les modules Python plus complexes.
"""

__version__ = "1.0.0"
EOF
fi

# Mettre à jour le pyproject.toml pour la nouvelle structure
cat > shared_python/pyproject.toml << 'EOF'
[tool.poetry]
name = "shared_python_scripts"
version = "0.1.0"
description = "Scripts Python partagés pour l'application yeb_app_template"
authors = ["Your Name <your.email@example.com>"]
readme = "README.md"

[tool.poetry.dependencies]
python = ">=3.9,<3.13"
# Dépendances communes pour tous les scripts
pandas = "^2.3.2"
numpy = "^1.26.4"
requests = "^2.32.0"
# Dépendances pour le mode web (optionnelles)
fastapi = {version = "^0.110.0", optional = true}
uvicorn = {version = "^0.30.0", optional = true}

[tool.poetry.extras]
web = ["fastapi", "uvicorn"]

[tool.poetry.group.dev.dependencies]
pytest = "^8.4.2"

[build-system]
requires = ["poetry-core>=1.0.0"]
build-backend = "poetry.core.masonry.api"

# Section personnalisée pour les dépendances spécifiques aux scripts
[tool.shared_scripts.dependencies]
# Format: chemin_relatif = ["dependency1", "dependency2", ...]
# Les chemins sont relatifs au dossier shared_python
"scripts/calcul_demo" = ["numpy", "pandas"]
# Exemples pour d'autres scripts
# "scripts/data_analysis" = ["matplotlib", "scipy"]
# "packages/mon_package" = ["numpy", "requests", "beautifulsoup4"]
EOF

# Créer le web_adapter.py s'il n'existe pas
if [ ! -f "shared_python/web_adapter.py" ]; then
    cat > shared_python/web_adapter.py << 'EOF'
"""
Adaptateur web pour l'exécution des scripts Python via une API REST.
Ce fichier est utilisé uniquement pour la version web de l'application.
"""

import importlib
import json
import traceback
import sys
import os
from pathlib import Path
from fastapi import FastAPI, Request, Response
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

app = FastAPI(title="YEB App Template Python API")

# Configurer CORS pour permettre les requêtes depuis le front-end Flutter
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # En production, spécifiez les origines exactes
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Ajouter le répertoire parent au chemin Python pour résoudre les imports
script_dir = Path(__file__).parent
sys.path.append(str(script_dir))


@app.post("/api/run_script")
async def run_script(request: Request):
    """
    Exécute un script Python spécifié avec les arguments fournis.
    
    Le corps de la requête doit contenir:
    - script_path: Chemin relatif vers le script (ex: "scripts/calcul_demo")
    - args: Liste d'arguments à passer au script
    """
    try:
        data = await request.json()
        script_path = data.get("script_path", "")
        args = data.get("args", [])
        
        # Convertir le chemin de fichier en module importable
        # Ex: "scripts/calcul_demo" -> "scripts.calcul_demo"
        module_path = script_path.replace("/", ".")
        
        try:
            # Importer dynamiquement le module
            module = importlib.import_module(module_path)
            
            # Vérifier si le module a une fonction main
            if hasattr(module, "main") and callable(module.main):
                # Exécuter la fonction main avec les arguments
                result = module.main(*args)
                return {"success": True, "result": result}
            else:
                return {
                    "success": False, 
                    "error": f"Le module {script_path} n'a pas de fonction main() exécutable"
                }
        except ModuleNotFoundError:
            return {
                "success": False,
                "error": f"Script non trouvé: {script_path}",
                "path_info": f"sys.path = {sys.path}"
            }
        except Exception as e:
            # Capturer l'erreur et la stack trace pour le débogage
            error_details = traceback.format_exc()
            return {
                "success": False,
                "error": str(e),
                "details": error_details
            }
    except Exception as e:
        return {"success": False, "error": f"Erreur de requête: {str(e)}"}


@app.get("/api/list_scripts")
async def list_scripts():
    """Liste tous les scripts Python disponibles."""
    scripts = []
    
    # Parcourir le dossier scripts
    scripts_dir = script_dir / "scripts"
    if scripts_dir.exists():
        for file in scripts_dir.glob("**/*.py"):
            rel_path = file.relative_to(script_dir)
            script_path = str(rel_path).replace("\\", "/")
            if script_path.endswith("__init__.py"):
                continue
            script_path = script_path[:-3]  # Enlever l'extension .py
            scripts.append({
                "path": script_path,
                "name": file.stem
            })
    
    # Parcourir les packages pour trouver les modules principaux
    packages_dir = script_dir / "packages"
    if packages_dir.exists():
        for package in packages_dir.glob("*"):
            if package.is_dir() and (package / "__init__.py").exists():
                main_file = package / "__main__.py"
                if main_file.exists():
                    rel_path = main_file.parent.relative_to(script_dir)
                    script_path = str(rel_path).replace("\\", "/")
                    scripts.append({
                        "path": script_path,
                        "name": package.name
                    })
    
    return {"success": True, "scripts": scripts}


@app.get("/")
async def root():
    """Endpoint racine pour vérifier que l'API fonctionne."""
    return {
        "message": "YEB App Template Python API en cours d'exécution",
        "version": "1.0.0",
        "endpoints": [
            {"path": "/api/run_script", "method": "POST", "description": "Exécute un script Python"},
            {"path": "/api/list_scripts", "method": "GET", "description": "Liste les scripts disponibles"}
        ]
    }


def start_server(host="0.0.0.0", port=8000):
    """Démarre le serveur FastAPI."""
    uvicorn.run(app, host=host, port=port)


if __name__ == "__main__":
    # Démarrer le serveur si ce fichier est exécuté directement
    start_server()
EOF
fi

# Créer le script de démarrage web intégré
cat > start_web_integrated.sh << 'EOF'
#!/bin/bash
# Script pour démarrer l'application en mode web avec le serveur Python intégré

# Répertoire du projet
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

# Vérifier si Poetry est installé
if ! command -v poetry &> /dev/null; then
    echo "Poetry n'est pas installé. Installation..."
    curl -sSL https://install.python-poetry.org | python3 -
fi

# Installer les dépendances avec l'extra web
echo "Installation des dépendances Python pour le web..."
cd shared_python
poetry install --extras web

# Démarrer le serveur Python en arrière-plan
echo "Démarrage du serveur Python..."
poetry run python -c "from web_adapter import start_server; start_server()" &
PYTHON_SERVER_PID=$!

# Attendre que le serveur soit prêt (3 secondes)
echo "Attente du démarrage du serveur..."
sleep 3

# Démarrer l'application Flutter en mode web
echo "Démarrage de l'application Flutter en mode web..."
cd "$PROJECT_DIR/flutter_app"
flutter run -d web-server

# Arrêter le serveur Python lorsque Flutter se termine
kill $PYTHON_SERVER_PID
EOF

# Rendre les scripts exécutables
chmod +x start_web_integrated.sh

echo "Migration vers la structure unifiée terminée avec succès!"
echo "La nouvelle structure est:"
echo "- shared_python/"
echo "  |- scripts/ (scripts simples comme calcul_demo.py)"
echo "  |- packages/ (packages complexes)"
echo "  |- web_adapter.py (serveur intégré pour le mode web)"
echo ""
echo "Pour lancer l'application en mode web intégré:"
echo "./start_web_integrated.sh"