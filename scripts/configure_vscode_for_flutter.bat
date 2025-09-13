@echo off
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

settings_file = r'%SETTINGS_FILE%'
with open(settings_file, 'r') as f:
    try:
        settings = json.load(f)
    except json.JSONDecodeError:
        settings = {}

# Ajouter ou mettre à jour les configurations
settings['dart.runPubGetOnPubspecChanges'] = True
settings['flutter.autoInstallPubDeps'] = True

# Écrire les modifications
with open(settings_file, 'w') as f:
    json.dump(settings, f, indent=4)
"
    echo %GREEN%Configuration VS Code mise à jour avec succès.%NC%
) else (
    REM Vérifier si Python3 est disponible
    where python3 >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        python3 -c "
import json
import sys
import os

settings_file = r'%SETTINGS_FILE%'
with open(settings_file, 'r') as f:
    try:
        settings = json.load(f)
    except json.JSONDecodeError:
        settings = {}

# Ajouter ou mettre à jour les configurations
settings['dart.runPubGetOnPubspecChanges'] = True
settings['flutter.autoInstallPubDeps'] = True

# Écrire les modifications
with open(settings_file, 'w') as f:
    json.dump(settings, f, indent=4)
"
        echo %GREEN%Configuration VS Code mise à jour avec succès.%NC%
    ) else (
        echo %RED%Ni Python ni Python3 ne sont disponibles. Veuillez installer Python ou modifier manuellement %SETTINGS_FILE%%NC%
        echo Ajoutez les lignes suivantes à votre fichier .vscode/settings.json :
        echo "dart.runPubGetOnPubspecChanges": true,
        echo "flutter.autoInstallPubDeps": true,
    )
)

echo.
echo %GREEN%Configuration terminée !%NC%
echo VS Code exécutera automatiquement 'flutter pub get' lorsque le fichier pubspec.yaml est modifié.