@echo off
:: ==========================================================================
:: RÉFÉRENCES CROISÉES:
:: - Ce fichier est référencé dans: [template/init_project.bat:256, 258, 259]
:: - Ce fichier est référencé dans: [init_project.bat:256, 258, 259]
:: ==========================================================================

REM Ce script modifie le fichier .vscode/settings.json pour exécuter automatiquement
REM le script d'installation des dépendances lors de l'ouverture du projet dans VS Code

REM Couleurs pour l'affichage
set "GREEN=[92m"
set "YELLOW=[93m"
set "RED=[91m"
set "NC=[0m"

echo %YELLOW%Configuration de VS Code pour l'installation automatique des dépendances...%NC%

REM Chemin du répertoire racine du projet
set "PROJECT_ROOT=%~dp0.."
set "SETTINGS_FILE=%PROJECT_ROOT%\.vscode\settings.json"

REM Créer le répertoire .vscode s'il n'existe pas
if not exist "%PROJECT_ROOT%\.vscode" mkdir "%PROJECT_ROOT%\.vscode"

REM Vérifier si le fichier settings.json existe
if not exist "%SETTINGS_FILE%" (
    echo {} > "%SETTINGS_FILE%"
)

REM Utiliser Python pour mettre à jour le fichier settings.json
where python >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    python -c "
import json
import sys
import os

# Lire le fichier settings.json existant
settings_file = os.path.join(r'%PROJECT_ROOT%', '.vscode', 'settings.json')
try:
    with open(settings_file, 'r') as f:
        try:
            settings = json.load(f)
        except json.JSONDecodeError:
            settings = {}
except FileNotFoundError:
    settings = {}

# Ajouter les nouveaux paramètres
settings['dart.flutterSdkPath'] = ''
settings['dart.sdkPath'] = ''
settings['python.defaultInterpreterPath'] = '${command:python.interpreterPath}'
settings['python.analysis.extraPaths'] = ['${workspaceFolder}/shared_python']

# Écrire les paramètres mis à jour
with open(settings_file, 'w') as f:
    json.dump(settings, f, indent=4)

print('Fichier settings.json mis à jour avec succès.')
"
) else (
    echo %RED%Python n'est pas installé ou n'est pas dans le PATH.%NC%
    echo %YELLOW%Création d'un fichier settings.json basique...%NC%
    
    REM Sauvegarde du fichier existant
    if exist "%SETTINGS_FILE%" (
        copy "%SETTINGS_FILE%" "%SETTINGS_FILE%.bak" >nul
    )
    
    REM Créer un nouveau fichier settings.json
    echo {> "%SETTINGS_FILE%"
    echo     "dart.flutterSdkPath": "",>> "%SETTINGS_FILE%"
    echo     "dart.sdkPath": "",>> "%SETTINGS_FILE%"
    echo     "python.defaultInterpreterPath": "${command:python.interpreterPath}",>> "%SETTINGS_FILE%"
    echo     "python.analysis.extraPaths": ["${workspaceFolder}/shared_python"]>> "%SETTINGS_FILE%"
    echo }>> "%SETTINGS_FILE%"
    
    echo %YELLOW%Fichier settings.json créé avec configuration de base.%NC%
)

echo %GREEN%Configuration de VS Code terminée.%NC%
echo %GREEN%Vous pouvez maintenant ouvrir le projet dans VS Code.%NC%