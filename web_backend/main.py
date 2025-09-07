# pylint: disable=import-error
# type: ignore
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import importlib
import sys
import os
from pathlib import Path
import uvicorn
import json
from pydantic import BaseModel
from typing import List


# Configuration des chemins pour accéder directement aux scripts Python partagés
SHARED_PYTHON_DIR = Path(__file__).parent.parent / "shared_python"
sys.path.append(str(SHARED_PYTHON_DIR))

app = FastAPI(title="737calcs API", description="API pour les calculs aéronautiques")

# Configuration CORS pour permettre les requêtes depuis le frontend Flutter
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # En production, limitez aux origines spécifiques
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class ScriptRequest(BaseModel):
    script_name: str
    args: List[str]

@app.get("/")
async def root():
    return {"message": "737calcs API est en ligne. Utilisez /api/run_script pour exécuter des calculs."}

@app.post("/api/run_script")
async def run_script(request: ScriptRequest):
    try:
        # Extraction du nom du module sans l'extension .py
        module_name = request.script_name.replace(".py", "")
        
        # Tenter d'importer le module dynamiquement
        try:
            # D'abord essayer dans le répertoire principal
            module = importlib.import_module(module_name)
        except ImportError:
            # Ensuite essayer dans le sous-répertoire calculs
            try:
                module = importlib.import_module(f"calculs.{module_name}")
            except ImportError:
                # Enfin essayer avec le chemin complet
                module = importlib.import_module(f"python_backend.{module_name}")
        
        # Vérifier si la fonction main existe dans le module
        if hasattr(module, "main"):
            # Convertir les arguments en nombres si possible
            processed_args = []
            for arg in request.args:
                try:
                    # Essayer de convertir en nombre
                    if "." in arg:
                        processed_args.append(float(arg))
                    else:
                        processed_args.append(int(arg))
                except ValueError:
                    # Garder comme chaîne si la conversion échoue
                    processed_args.append(arg)
            
            # Exécuter la fonction main avec les arguments
            if processed_args:
                result = module.main(*processed_args)
            else:
                result = module.main()
                
            # Convertir le résultat en format JSON compatible
            return {"result": result}
        else:
            raise HTTPException(status_code=400, detail=f"Le script {module_name} ne contient pas de fonction main()")
            
    except ImportError as e:
        raise HTTPException(status_code=404, detail=f"Script {request.script_name} introuvable: {str(e)}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erreur lors de l'exécution: {str(e)}")

# Point d'entrée pour exécution directe
if __name__ == "__main__":
    # Définir le port (utiliser une variable d'environnement ou 8000 par défaut)
    port = int(os.environ.get("PORT", 8000))
    
    # Lancer le serveur avec uvicorn
    uvicorn.run(app, host="0.0.0.0", port=port)
