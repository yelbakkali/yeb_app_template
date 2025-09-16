@echo off
:: Script de packaging des scripts Python partagés pour toutes les plateformes
:: Cette approche copie les scripts dans les assets de Flutter au lieu de faire une synchronisation manuelle

:: Chemin de base du projet
set "BASE_DIR=%~dp0.."

set "SHARED_PYTHON_DIR=%BASE_DIR%\shared_python"
set "FLUTTER_DIR=%BASE_DIR%\flutter_app"

echo Préparation des scripts Python pour le packaging...

:: S'assurer que le répertoire assets existe
set "ASSETS_DIR=%FLUTTER_DIR%\assets\shared_python"
if not exist "%ASSETS_DIR%" mkdir "%ASSETS_DIR%"
if not exist "%ASSETS_DIR%\scripts" mkdir "%ASSETS_DIR%\scripts"
if not exist "%ASSETS_DIR%\packages" mkdir "%ASSETS_DIR%\packages"

echo Copie des scripts Python vers les assets de Flutter...

:: Utiliser robocopy pour Windows à la place de rsync
:: Copier les fichiers à la racine (init, web_adapter, etc)
robocopy "%SHARED_PYTHON_DIR%" "%ASSETS_DIR%" *.py /XD "__pycache__" /NFL /NDL

:: Copier les dossiers scripts et packages en préservant leur structure
if exist "%SHARED_PYTHON_DIR%\scripts" (
    robocopy "%SHARED_PYTHON_DIR%\scripts" "%ASSETS_DIR%\scripts" *.py /E /XD "__pycache__" /NFL /NDL
)

if exist "%SHARED_PYTHON_DIR%\packages" (
    robocopy "%SHARED_PYTHON_DIR%\packages" "%ASSETS_DIR%\packages" *.py /E /XD "__pycache__" /NFL /NDL
)

echo Scripts Python copiés avec succès dans les assets.

:: Vérifier que le pubspec.yaml contient les assets nécessaires
findstr /C:"assets/shared_python/" "%FLUTTER_DIR%\pubspec.yaml" > nul
if errorlevel 1 (
    echo ATTENTION: Assurez-vous que votre pubspec.yaml contient les assets suivants:
    echo   assets:
    echo     - assets/shared_python/
)

:: Rappel pour Android
echo Pour Android (Chaquopy):
echo - Les scripts sont chargés via UnifiedPythonService depuis les assets
echo - Assurez-vous que le build.gradle.kts est configuré pour Chaquopy

:: Rappel pour iOS
echo Pour iOS (Python-Apple-support):
echo - Les scripts sont extraits au runtime avec UnifiedPythonService