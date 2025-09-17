@echo off
:: ==========================================================================
:: RÉFÉRENCES CROISÉES:
:: - Ce fichier est référencé dans: [template/entry-points/init_project.bat:310]
:: - Ce fichier est référencé dans: [template/entry-points/init_project.sh:350]
:: - Ce fichier est référencé dans: [docs/project_structure.md:79]
:: ==========================================================================

REM Script d'installation intelligent - Détecte l'environnement et exécute le script approprié

echo [INFO] Démarrage du script d'installation intelligent...

REM Détecter si nous sommes sur Windows ou autre chose
if "%OS%"=="Windows_NT" (
    echo [INFO] Environnement Windows détecté.
    echo [INFO] Exécution du script d'installation pour Windows...
    call "%~dp0setup_windows.bat"
) else (
    echo [ERREUR] Ce script est conçu pour Windows, mais votre système ne semble pas être Windows.
    echo [INFO] Si vous êtes sur Linux ou macOS, veuillez utiliser le script setup.sh à la place.
    pause
    exit /B 1
)