@echo off
REM Script d'installation des dépendances pour Windows
REM Ce script installe tous les outils nécessaires pour le développement du projet 737calcs sous Windows

echo [INFO] Démarrage du script d'installation pour Windows...

REM Vérifier si le script s'exécute en tant qu'administrateur
NET SESSION >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERREUR] Ce script doit être exécuté en tant qu'administrateur.
    echo Veuillez relancer ce script avec des droits d'administrateur.
    pause
    exit /B 1
)

REM Vérifier si Chocolatey est installé, sinon l'installer
where choco >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [INFO] Installation de Chocolatey...
    @powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
    set PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin
) else (
    echo [INFO] Chocolatey est déjà installé.
)

REM Installation de Git
echo [INFO] Vérification de l'installation de Git...
where git >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [INFO] Installation de Git...
    choco install git -y
) else (
    echo [INFO] Git est déjà installé.
)

REM Installation de Python
echo [INFO] Vérification de l'installation de Python...
where python >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [INFO] Installation de Python 3...
    choco install python -y
    refreshenv
) else (
    echo [INFO] Python est déjà installé.
)

REM Installation de Poetry
echo [INFO] Vérification de l'installation de Poetry...
where poetry >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [INFO] Installation de Poetry...
    powershell -Command "(Invoke-WebRequest -Uri https://install.python-poetry.org -UseBasicParsing).Content | python -"
    refreshenv
) else (
    echo [INFO] Poetry est déjà installé.
)

REM Installation de Flutter
echo [INFO] Vérification de l'installation de Flutter...
where flutter >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [INFO] Installation de Flutter...
    
    REM Créer un dossier pour Flutter
    if not exist "%USERPROFILE%\development" mkdir "%USERPROFILE%\development"
    
    REM Télécharger Flutter
    echo [INFO] Téléchargement de Flutter...
    powershell -Command "Invoke-WebRequest -Uri https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.19.4-stable.zip -OutFile flutter.zip"
    
    REM Extraire Flutter
    echo [INFO] Extraction de Flutter...
    powershell -Command "Expand-Archive -Path flutter.zip -DestinationPath %USERPROFILE%\development"
    del flutter.zip
    
    REM Ajouter Flutter au PATH
    setx PATH "%PATH%;%USERPROFILE%\development\flutter\bin"
    set PATH=%PATH%;%USERPROFILE%\development\flutter\bin
    
    REM Activer la prise en charge du développement web
    flutter config --enable-web
) else (
    echo [INFO] Flutter est déjà installé.
    flutter config --enable-web
)

REM Installation de VS Code
echo [INFO] Vérification de l'installation de VS Code...
where code >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [INFO] Installation de Visual Studio Code...
    choco install vscode -y
) else (
    echo [INFO] Visual Studio Code est déjà installé.
)

REM Installation des extensions VS Code recommandées
echo [INFO] Installation des extensions VS Code recommandées...
call code --install-extension ms-python.python
call code --install-extension ms-python.vscode-pylance
call code --install-extension dart-code.flutter
call code --install-extension dart-code.dart-code
call code --install-extension ms-vscode-remote.remote-wsl
call code --install-extension github.vscode-pull-request-github

REM Installation de Google Chrome (pour Flutter web)
echo [INFO] Vérification de l'installation de Google Chrome...
if not exist "%PROGRAMFILES%\Google\Chrome\Application\chrome.exe" (
    if not exist "%PROGRAMFILES(x86)%\Google\Chrome\Application\chrome.exe" (
        echo [INFO] Installation de Google Chrome...
        choco install googlechrome -y
    ) else (
        echo [INFO] Google Chrome est déjà installé.
    )
) else (
    echo [INFO] Google Chrome est déjà installé.
)

REM Configurer WSL si disponible
echo [INFO] Vérification de la disponibilité de WSL...
wsl --status >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [INFO] WSL est installé, configuration...
    
    REM Vérifier si Ubuntu est installé, sinon l'installer
    wsl -l | findstr "Ubuntu" >nul
    if %ERRORLEVEL% NEQ 0 (
        echo [INFO] Installation d'Ubuntu sur WSL...
        wsl --install -d Ubuntu
    ) else (
        echo [INFO] Ubuntu est déjà installé sur WSL.
    )
    
    REM Copier le script d'installation WSL
    echo [INFO] Copie du script d'installation WSL...
    cd /d %~dp0
    wsl -d Ubuntu -- mkdir -p ~/737calcs_setup
    wsl -d Ubuntu -- cp $(wslpath '%~dp0setup_wsl.sh') ~/737calcs_setup/
    wsl -d Ubuntu -- chmod +x ~/737calcs_setup/setup_wsl.sh
    
    echo [INFO] Pour finaliser l'installation sous WSL, exécutez:
    echo       wsl -d Ubuntu
    echo       ~/737calcs_setup/setup_wsl.sh
) else (
    echo [INFO] WSL n'est pas disponible. Vous pouvez l'activer via les fonctionnalités Windows.
)

echo.
echo [SUCCES] Installation terminée avec succès!
echo [INFO] Veuillez redémarrer votre ordinateur pour appliquer tous les changements de PATH.
echo.
pause
