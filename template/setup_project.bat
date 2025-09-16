@echo off
REM Script d'installation tout-en-un pour le template yeb_app_template

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

call :print_header "Installation automatisée du projet"
echo Ce script va vérifier les prérequis et initialiser votre projet

REM Étape 1: Vérification des prérequis
call :print_header "Étape 1: Vérification des prérequis"

set "SCRIPT_DIR=%~dp0"
set "PREREQ_SCRIPT=%SCRIPT_DIR%scripts\check_prerequisites.bat"

if exist "%PREREQ_SCRIPT%" (
    call "%PREREQ_SCRIPT%"
    
    REM Si le script de prérequis a affiché des avertissements, demander si l'utilisateur veut continuer
    if %ERRORLEVEL% NEQ 0 (
        echo %YELLOW%Des prérequis sont manquants. Voulez-vous continuer quand même ? (O/N)%NC%
        set /p CONTINUE_CHOICE=
        if /i not "%CONTINUE_CHOICE%"=="O" (
            echo Installation annulée. Veuillez installer les prérequis manquants et réessayer.
            exit /b 1
        )
    )
) else (
    call :print_error "Script de vérification des prérequis non trouvé"
    exit /b 1
)

REM Étape 2: Initialisation du projet
call :print_header "Étape 2: Initialisation du projet"

set "INIT_SCRIPT=%SCRIPT_DIR%init_project.bat"
if exist "%INIT_SCRIPT%" (
    call "%INIT_SCRIPT%"
    
    if %ERRORLEVEL% NEQ 0 (
        call :print_error "Échec de l'initialisation du projet"
        exit /b 1
    )
) else (
    call :print_error "Script d'initialisation non trouvé"
    exit /b 1
)

REM Étape 3: Ouverture du projet dans VS Code (si disponible)
call :print_header "Étape 3: Ouverture du projet dans VS Code"

where code >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo Ouverture du projet dans VS Code...
    code .
    call :print_success "Projet ouvert dans VS Code"
) else (
    call :print_warning "VS Code n'est pas installé ou n'est pas dans le PATH"
    echo Pour ouvrir le projet manuellement, exécutez 'code .' dans ce dossier
)

call :print_header "Installation terminée avec succès !"
echo Votre projet est maintenant configuré et prêt à l'emploi.
echo.
echo Pour lancer l'application en développement :
echo   - Mode local : run_dev.bat
echo   - Mode web   : start_web_dev.bat
echo.
echo Pour plus d'informations, consultez la documentation dans le dossier 'docs/'.
call :print_success "Bon développement !"