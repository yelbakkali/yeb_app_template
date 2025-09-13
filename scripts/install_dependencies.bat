@echo off
REM Script pour installer toutes les dépendances nécessaires
REM pour le projet yeb_app_template
REM Ce script installe les dépendances Dart/Flutter et Python

REM Couleurs pour l'affichage
set "GREEN=[92m"
set "YELLOW=[93m"
set "RED=[91m"
set "NC=[0m"

echo %YELLOW%===============================================%NC%
echo %YELLOW%   INSTALLATION DES DÉPENDANCES DU PROJET      %NC%
echo %YELLOW%===============================================%NC%

REM Chemin du répertoire racine du projet
set "PROJECT_ROOT=%~dp0.."
cd "%PROJECT_ROOT%"

echo.
echo %GREEN%1. Installation des dépendances Flutter/Dart%NC%

REM Installation des dépendances Flutter/Dart au niveau projet
echo %YELLOW%Installation des dépendances Flutter/Dart au niveau projet...%NC%
call flutter pub get
if %ERRORLEVEL% NEQ 0 (
    echo %RED%Échec de l'installation des dépendances Flutter/Dart au niveau projet.%NC%
    echo %YELLOW%Tentative d'installation uniquement dans le dossier flutter_app...%NC%
)

REM Installation des dépendances Flutter/Dart dans le répertoire flutter_app
echo %YELLOW%Installation des dépendances Flutter/Dart dans le dossier flutter_app...%NC%
cd "%PROJECT_ROOT%\flutter_app"
call flutter pub get
if %ERRORLEVEL% NEQ 0 (
    echo %RED%Échec de l'installation des dépendances Flutter/Dart dans le dossier flutter_app.%NC%
    echo %YELLOW%Vérifiez que Flutter est correctement installé.%NC%
)
cd "%PROJECT_ROOT%"

echo.
echo %GREEN%2. Installation des dépendances Python%NC%

REM Installation des dépendances Python dans web_backend
echo %YELLOW%Installation des dépendances Python dans web_backend...%NC%
cd "%PROJECT_ROOT%\web_backend"
where poetry >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    call poetry install
    if %ERRORLEVEL% NEQ 0 (
        echo %RED%Échec de l'installation des dépendances Python avec Poetry dans web_backend.%NC%
        if exist requirements.txt (
            echo %YELLOW%Tentative d'installation avec pip...%NC%
            pip install -r requirements.txt
            if %ERRORLEVEL% NEQ 0 (
                echo %RED%Échec de l'installation des dépendances Python avec pip dans web_backend.%NC%
            )
        )
    )
) else (
    if exist requirements.txt (
        echo %YELLOW%Poetry non trouvé, utilisation de pip...%NC%
        pip install -r requirements.txt
        if %ERRORLEVEL% NEQ 0 (
            echo %RED%Échec de l'installation des dépendances Python avec pip dans web_backend.%NC%
        )
    ) else (
        echo %RED%Poetry non trouvé et requirements.txt inexistant dans web_backend.%NC%
    )
)
cd "%PROJECT_ROOT%"

REM Installation des dépendances Python dans python_backend si le dossier existe
if exist "%PROJECT_ROOT%\python_backend" (
    echo %YELLOW%Installation des dépendances Python dans python_backend...%NC%
    cd "%PROJECT_ROOT%\python_backend"
    where poetry >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        call poetry install
        if %ERRORLEVEL% NEQ 0 (
            echo %RED%Échec de l'installation des dépendances Python avec Poetry dans python_backend.%NC%
            if exist requirements.txt (
                echo %YELLOW%Tentative d'installation avec pip...%NC%
                pip install -r requirements.txt
                if %ERRORLEVEL% NEQ 0 (
                    echo %RED%Échec de l'installation des dépendances Python avec pip dans python_backend.%NC%
                )
            )
        )
    ) else (
        if exist requirements.txt (
            echo %YELLOW%Poetry non trouvé, utilisation de pip...%NC%
            pip install -r requirements.txt
            if %ERRORLEVEL% NEQ 0 (
                echo %RED%Échec de l'installation des dépendances Python avec pip dans python_backend.%NC%
            )
        ) else (
            echo %RED%Poetry non trouvé et requirements.txt inexistant dans python_backend.%NC%
        )
    )
    cd "%PROJECT_ROOT%"
)

echo.
echo %GREEN%===============================================%NC%
echo %GREEN%   INSTALLATION DES DÉPENDANCES TERMINÉE       %NC%
echo %GREEN%===============================================%NC%
echo Si des erreurs sont apparues, vérifiez que les outils suivants sont bien installés :
echo - Flutter/Dart
echo - Poetry (pour Python) ou pip
echo.
echo Vous pouvez maintenant travailler sur le projet!