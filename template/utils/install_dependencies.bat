@echo off
:: ==========================================================================
:: RÉFÉRENCES CROISÉES:
:: - Ce fichier est référencé dans: [template/entry-points/init_project.bat:414, 416]
:: ==========================================================================

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
set "PROJECT_ROOT=%~dp0..\.."
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
echo %GREEN%3. Installation des extensions VS Code recommandées%NC%
REM Vérifie si la commande code est disponible (VS Code installé)
where code >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo %YELLOW%Installation des extensions VS Code recommandées...%NC%

    REM Extensions Flutter/Dart
    call code --install-extension dart-code.dart-code
    if %ERRORLEVEL% NEQ 0 echo %RED%Échec de l'installation de dart-code.dart-code%NC%
    call code --install-extension dart-code.flutter
    if %ERRORLEVEL% NEQ 0 echo %RED%Échec de l'installation de dart-code.flutter%NC%
    call code --install-extension nash.awesome-flutter-snippets
    if %ERRORLEVEL% NEQ 0 echo %RED%Échec de l'installation de nash.awesome-flutter-snippets%NC%

    REM Extensions Python
    call code --install-extension ms-python.python
    if %ERRORLEVEL% NEQ 0 echo %RED%Échec de l'installation de ms-python.python%NC%
    call code --install-extension ms-python.vscode-pylance
    if %ERRORLEVEL% NEQ 0 echo %RED%Échec de l'installation de ms-python.vscode-pylance%NC%
    call code --install-extension ms-python.black-formatter
    if %ERRORLEVEL% NEQ 0 echo %RED%Échec de l'installation de ms-python.black-formatter%NC%
    call code --install-extension njpwerner.autodocstring
    if %ERRORLEVEL% NEQ 0 echo %RED%Échec de l'installation de njpwerner.autodocstring%NC%
    call code --install-extension matangover.mypy
    if %ERRORLEVEL% NEQ 0 echo %RED%Échec de l'installation de matangover.mypy%NC%

    REM Linters et formatage
    call code --install-extension streetsidesoftware.code-spell-checker
    if %ERRORLEVEL% NEQ 0 echo %RED%Échec de l'installation de streetsidesoftware.code-spell-checker%NC%
    call code --install-extension esbenp.prettier-vscode
    if %ERRORLEVEL% NEQ 0 echo %RED%Échec de l'installation de esbenp.prettier-vscode%NC%

    REM Git et Collaboration
    call code --install-extension github.vscode-pull-request-github
    if %ERRORLEVEL% NEQ 0 echo %RED%Échec de l'installation de github.vscode-pull-request-github%NC%
    call code --install-extension eamodio.gitlens
    if %ERRORLEVEL% NEQ 0 echo %RED%Échec de l'installation de eamodio.gitlens%NC%

    REM Productivité
    call code --install-extension github.copilot
    if %ERRORLEVEL% NEQ 0 echo %RED%Échec de l'installation de github.copilot%NC%
    call code --install-extension github.copilot-chat
    if %ERRORLEVEL% NEQ 0 echo %RED%Échec de l'installation de github.copilot-chat%NC%
    call code --install-extension ms-vsliveshare.vsliveshare
    if %ERRORLEVEL% NEQ 0 echo %RED%Échec de l'installation de ms-vsliveshare.vsliveshare%NC%

    REM Fonctionnalités natives
    call code --install-extension ms-vscode.cpptools
    if %ERRORLEVEL% NEQ 0 echo %RED%Échec de l'installation de ms-vscode.cpptools%NC%

    echo %GREEN%Installation des extensions VS Code terminée.%NC%
) else (
    echo %YELLOW%La commande 'code' n'est pas disponible dans le PATH.%NC%
    echo %YELLOW%Pour installer les extensions VS Code recommandées, assurez-vous que VS Code est installé%NC%
    echo %YELLOW%et que la commande 'code' est disponible dans votre PATH.%NC%
    echo %YELLOW%Vous pouvez également installer les extensions manuellement depuis VS Code.%NC%
    echo %YELLOW%Les extensions recommandées sont listées dans .vscode/extensions.json%NC%
)

echo.
echo %GREEN%===============================================%NC%
echo %GREEN%   INSTALLATION DES DÉPENDANCES TERMINÉE       %NC%
echo %GREEN%===============================================%NC%
echo Si des erreurs sont apparues, vérifiez que les outils suivants sont bien installés :
echo - Flutter/Dart
echo - Poetry (pour Python) ou pip
echo - VS Code (pour les extensions recommandées)
echo.
echo Vous pouvez maintenant travailler sur le projet!