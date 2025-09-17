@echo off
:: ==========================================================================
:: RÉFÉRENCES CROISÉES:
:: - Ce fichier est référencé dans: [setup_project.bat:89]
:: - Ce fichier est référencé dans: [init_project.sh:556]
:: - Ce fichier est référencé dans: [docs/installation.md:149, 194]
:: - Ce fichier est référencé dans: [docs/modes_demarrage.md:54]
:: - Ce fichier est référencé dans: [init_project.bat:495]
:: - Ce fichier est référencé dans: [template/setup_project.bat:89]
:: - Ce fichier est référencé dans: [template/init_project.sh:556]
:: - Ce fichier est référencé dans: [template/bootstrap.sh:245]
:: - Ce fichier est référencé dans: [template/init_project.bat:495]
:: ==========================================================================

:: Script lanceur tout-en-un pour yeb_app_template avec l'approche de packaging
:: Ce script prépare les scripts Python pour le packaging, lance le backend web et l'application Flutter

:: Chemin de base du projet
set "BASE_DIR=%~dp0"
set "BASE_DIR=%BASE_DIR:~0,-1%"

echo.
echo =====================================================
echo Préparation des scripts Python pour le packaging
echo =====================================================
echo.

:: Packager les scripts Python
call "%BASE_DIR%\scripts\package_python_scripts.bat"

:: Définir la variable d'environnement pour le mode développement
set FLUTTER_DEV_MODE=true

echo.
echo =====================================================
echo Démarrage du backend web FastAPI et Flutter
echo =====================================================
echo.

:: Démarrer le backend et Flutter dans des fenêtres séparées
start cmd /k "cd /d %BASE_DIR%\web_backend && set FLUTTER_DEV_MODE=true && python main.py"
start cmd /k "cd /d %BASE_DIR%\flutter_app && set FLUTTER_DEV_MODE=true && flutter run -d chrome --web-hostname 0.0.0.0 --web-port 8080"

echo.
echo Les services ont été démarrés dans des fenêtres séparées
echo Fermez ces fenêtres pour arrêter les services
echo.
