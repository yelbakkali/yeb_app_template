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