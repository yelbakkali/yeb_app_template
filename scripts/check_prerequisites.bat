@echo off
REM Script de vérification et d'installation des prérequis pour le template yeb_app_template
REM Ce script détecte et suggère l'installation des outils nécessaires pour le projet

REM Couleurs pour les messages (Windows)
set "RED=[91m"
set "GREEN=[92m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "NC=[0m"

REM Fonctions utilitaires
:print_header
echo %BLUE%===================================================================%NC%
echo %BLUE% %~1 %NC%
echo %BLUE%===================================================================%NC%
goto :EOF

:print_success
echo %GREEN%✓ %~1%NC%
goto :EOF

:print_warning
echo %YELLOW%⚠ %~1%NC%
goto :EOF

:print_error
echo %RED%✗ %~1%NC%
goto :EOF

call :print_header "Vérification des prérequis pour le projet"

REM Variables pour suivre l'état des outils
set MISSING_TOOLS=
set INSTALLED_TOOLS=

REM Vérifier si Git est disponible
call :print_header "Vérification de Git"
where git >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    call :print_warning "Git n'est pas installé ou n'est pas dans le PATH"
    echo Pour installer Git :
    echo 1. Téléchargez Git depuis https://git-scm.com/download/win
    echo 2. Exécutez l'installateur et suivez les instructions
    echo 3. Assurez-vous de sélectionner l'option pour ajouter Git au PATH
    set "MISSING_TOOLS=%MISSING_TOOLS% Git"
) else (
    call :print_success "Git est installé"
)

REM Vérifier si Python est disponible
call :print_header "Vérification de Python"
where python >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    call :print_warning "Python n'est pas installé ou n'est pas dans le PATH"
    echo Pour installer Python :
    echo 1. Téléchargez Python depuis https://www.python.org/downloads/windows/
    echo 2. Exécutez l'installateur et suivez les instructions
    echo 3. Assurez-vous de cocher l'option "Add Python to PATH"
    set "MISSING_TOOLS=%MISSING_TOOLS% Python"
) else (
    call :print_success "Python est installé"
    python --version
)

REM Vérifier si Poetry est disponible
call :print_header "Vérification de Poetry"
where poetry >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    call :print_warning "Poetry n'est pas installé ou n'est pas dans le PATH"
    echo Pour installer Poetry :
    
    echo Voulez-vous installer Poetry automatiquement ? (O/N)
    set /p INSTALL_CHOICE=
    
    if /i "%INSTALL_CHOICE%"=="O" (
        call :print_header "Installation de Poetry"
        powershell -Command "(Invoke-WebRequest -Uri https://install.python-poetry.org -UseBasicParsing).Content | python -"
        
        if %ERRORLEVEL% EQU 0 (
            call :print_success "Poetry installé. Veuillez redémarrer ce script pour détecter Poetry."
            REM Ajouter Poetry au PATH pour cette session - mais cela ne fonctionnera que pour les futures commandes
            set "PATH=%USERPROFILE%\.poetry\bin;%PATH%"
            set "INSTALLED_TOOLS=%INSTALLED_TOOLS% Poetry"
        ) else (
            call :print_error "Échec de l'installation de Poetry"
            echo 1. Visitez https://python-poetry.org/docs/#installation
            echo 2. Suivez les instructions d'installation
            set "MISSING_TOOLS=%MISSING_TOOLS% Poetry"
        )
    ) else (
        echo 1. Visitez https://python-poetry.org/docs/#installation
        echo 2. Suivez les instructions d'installation
        set "MISSING_TOOLS=%MISSING_TOOLS% Poetry"
    )
) else (
    call :print_success "Poetry est installé"
)

REM Vérifier si Flutter est disponible
call :print_header "Vérification de Flutter"
where flutter >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    call :print_warning "Flutter n'est pas installé ou n'est pas dans le PATH"
    echo Pour installer Flutter :
    echo 1. Téléchargez Flutter depuis https://docs.flutter.dev/get-started/install/windows
    echo 2. Extrayez l'archive zip dans le dossier de votre choix (par exemple C:\src\flutter)
    echo 3. Ajoutez flutter\bin au PATH système
    echo 4. Exécutez 'flutter doctor' pour vérifier l'installation
    set "MISSING_TOOLS=%MISSING_TOOLS% Flutter"
) else (
    call :print_success "Flutter est installé"
    flutter --version | findstr "Flutter"
)

REM Vérifier si VS Code est disponible
call :print_header "Vérification de VS Code"
where code >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    call :print_warning "VS Code n'est pas installé ou n'est pas dans le PATH"
    echo Pour installer VS Code :
    echo 1. Téléchargez VS Code depuis https://code.visualstudio.com/download
    echo 2. Exécutez l'installateur et suivez les instructions
    echo 3. Assurez-vous de sélectionner l'option pour ajouter VS Code au PATH
    set "MISSING_TOOLS=%MISSING_TOOLS% VSCode"
) else (
    call :print_success "VS Code est installé"
    
    REM Installation des extensions VS Code recommandées
    call :print_header "Installation des extensions VS Code recommandées"
    echo Voulez-vous installer les extensions VS Code recommandées ? (O/N)
    set /p INSTALL_EXT=
    
    if /i "%INSTALL_EXT%"=="O" (
        REM Extensions Flutter/Dart
        code --install-extension Dart-Code.flutter
        code --install-extension Dart-Code.dart-code
        
        REM Extensions Python
        code --install-extension ms-python.python
        code --install-extension ms-python.vscode-pylance
        code --install-extension LittleFoxTeam.vscode-python-test-adapter
        
        REM Outils généraux
        code --install-extension mhutchie.git-graph
        code --install-extension eamodio.gitlens
        
        REM Qualité du code
        code --install-extension dbaeumer.vscode-eslint
        code --install-extension esbenp.prettier-vscode
        
        call :print_success "Extensions VS Code installées"
    ) else (
        call :print_warning "Les extensions seront proposées à l'ouverture du projet dans VS Code."
    )
)

REM Résumé
call :print_header "Résumé des vérifications"

if not "%INSTALLED_TOOLS%"=="" (
    echo Outils installés durant cette session :
    echo %INSTALLED_TOOLS%
    echo.
)

if not "%MISSING_TOOLS%"=="" (
    echo Outils manquants qui nécessitent une installation manuelle :
    echo %MISSING_TOOLS%
    echo.
    call :print_warning "Veuillez installer les outils manquants avant de continuer."
) else (
    call :print_success "Tous les prérequis sont satisfaits ou ont été vérifiés."
)

echo.
call :print_header "Fin de la vérification des prérequis"
echo Appuyez sur une touche pour terminer...
pause > nul