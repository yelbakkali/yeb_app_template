@echo off
setlocal enabledelayedexpansion

:: ==========================================================================
:: RÉFÉRENCES CROISÉES:
:: - Ce fichier est équivalent à: [setup_template.sh]
:: - Ce fichier est référencé dans: [README.md]
:: ==========================================================================

:: setup_template.bat - Script de démarrage pour initialiser un nouveau projet à partir du template yeb_app_template
:: Auteur: Yassine El Bakkali
:: Ce script télécharge le template yeb_app_template et configure un nouveau projet
:: avec toutes les dépendances nécessaires

:: Couleurs pour les messages (Windows)
set "RED=[91m"
set "GREEN=[92m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "NC=[0m"

:: Fonctions utilitaires
:print_header
    echo %BLUE%===================================================================%NC%
    echo %BLUE% %~1 %NC%
    echo %BLUE%===================================================================%NC%
    exit /b

:print_success
    echo %GREEN%✓ %~1%NC%
    exit /b

:print_warning
    echo %YELLOW%⚠ %~1%NC%
    exit /b

:print_error
    echo %RED%✗ %~1%NC%
    exit /b

:: Vérifier si les outils nécessaires sont installés
:check_prerequisites
    call :print_header "Vérification des prérequis"

    set "missing_tools="

    :: Vérifier Git
    where git >nul 2>&1
    if %ERRORLEVEL% neq 0 (
        set "missing_tools=!missing_tools! git"
    ) else (
        call :print_success "Git est installé"
    )

    :: Vérifier curl ou wget
    where curl >nul 2>&1
    if %ERRORLEVEL% eq 0 (
        call :print_success "curl est installé"
        set "DOWNLOAD_CMD=curl -LJO"
    ) else (
        where wget >nul 2>&1
        if %ERRORLEVEL% eq 0 (
            call :print_success "wget est installé"
            set "DOWNLOAD_CMD=wget"
        ) else (
            set "missing_tools=!missing_tools! curl ou wget"
        )
    )

    :: Afficher les erreurs si des outils sont manquants
    if not "!missing_tools!"=="" (
        call :print_error "Outils manquants: !missing_tools!"
        echo Veuillez installer ces outils avant de continuer.
        exit /b 1
    )
    exit /b 0

:: Configurer le projet en utilisant le nom du dossier actuel
:configure_project
    call :print_header "Configuration du projet"

    :: Utiliser le nom du dossier courant comme nom du projet
    for %%I in (.) do set "PROJECT_NAME=%%~nxI"
    
    :: Valider le nom du projet
    echo %PROJECT_NAME% | findstr /r "^[a-zA-Z0-9_-]*$" >nul
    if %ERRORLEVEL% neq 0 (
        call :print_warning "Le nom du dossier actuel '%PROJECT_NAME%' contient des caractères non supportés."
        echo Pour une meilleure compatibilité, le dossier du projet devrait contenir uniquement des lettres, chiffres et tirets.
        echo Voulez-vous continuer quand même ? (o/n)
        set /p "confirm=> "
        echo !confirm! | findstr /r "^[oO]$" >nul
        if %ERRORLEVEL% neq 0 (
            call :print_error "Installation annulée. Veuillez renommer votre dossier et réessayer."
            exit /b 1
        )
    )
    
    echo Le nom du projet sera '%GREEN%%PROJECT_NAME%%NC%' (basé sur le nom du dossier actuel).
    
    echo Entrez une brève description de votre projet:
    set /p "PROJECT_DESCRIPTION=> "

    echo Entrez votre nom ou celui de votre organisation:
    set /p "PROJECT_AUTHOR=> "

    call :print_success "Projet configuré: %PROJECT_NAME%"
    exit /b 0

:: Télécharger le template depuis GitHub
:download_template
    call :print_header "Téléchargement du template"

    echo Téléchargement du template depuis GitHub...

    :: Sauvegarder le script actuel
    copy setup_template.bat setup_template.bat.bak

    :: Cloner le dépôt directement dans le répertoire courant
    git clone --depth 1 https://github.com/yelbakkali/yeb_app_template.git .
    if %ERRORLEVEL% neq 0 (
        call :print_error "Échec du téléchargement du template"
        exit /b 1
    )

    :: Restaurer notre script original
    move /y setup_template.bat.bak setup_template.bat
    
    call :print_success "Template téléchargé avec succès"

    :: Supprimer le répertoire .git pour recommencer l'historique
    rmdir /s /q .git

    :: Initialiser un nouveau dépôt Git
    git init
    git add .
    git commit -m "Initial commit from yeb_app_template"

    call :print_success "Nouveau dépôt Git initialisé"
    exit /b 0

:: Personnaliser le template pour le nouveau projet
:customize_template
    call :print_header "Personnalisation du template"

    echo Mise à jour des fichiers de configuration...

    :: Mettre à jour le pubspec.yaml principal
    if exist "pubspec.yaml" (
        powershell -Command "(Get-Content pubspec.yaml) -replace 'name: yeb_app_template', 'name: %PROJECT_NAME%' | Set-Content pubspec.yaml"
        powershell -Command "(Get-Content pubspec.yaml) -replace 'description: \"Template d''application Flutter/Python par YEB\"', 'description: \"%PROJECT_DESCRIPTION%\"' | Set-Content pubspec.yaml"
        call :print_success "pubspec.yaml mis à jour"
    )

    :: Mettre à jour les fichiers pyproject.toml
    if exist "web_backend\pyproject.toml" (
        powershell -Command "(Get-Content web_backend\pyproject.toml) -replace 'name = \"web_backend\"', 'name = \"%PROJECT_NAME%_web_backend\"' | Set-Content web_backend\pyproject.toml"
        powershell -Command "(Get-Content web_backend\pyproject.toml) -replace 'description = \"API Web pour yeb_app_template\"', 'description = \"API Web pour %PROJECT_NAME%\"' | Set-Content web_backend\pyproject.toml"
        powershell -Command "(Get-Content web_backend\pyproject.toml) -replace 'authors = \[\"Votre Nom <votre.email@example.com>\"\]', 'authors = [\"%PROJECT_AUTHOR%\"]' | Set-Content web_backend\pyproject.toml"
        call :print_success "web_backend\pyproject.toml mis à jour"
    )

    if exist "python_backend\pyproject.toml" (
        powershell -Command "(Get-Content python_backend\pyproject.toml) -replace 'name = \"python_backend\"', 'name = \"%PROJECT_NAME%_python_backend\"' | Set-Content python_backend\pyproject.toml"
        powershell -Command "(Get-Content python_backend\pyproject.toml) -replace 'description = \"Backend Python pour yeb_app_template\"', 'description = \"Backend Python pour %PROJECT_NAME%\"' | Set-Content python_backend\pyproject.toml"
        powershell -Command "(Get-Content python_backend\pyproject.toml) -replace 'authors = \[\"Votre Nom <votre.email@example.com>\"\]', 'authors = [\"%PROJECT_AUTHOR%\"]' | Set-Content python_backend\pyproject.toml"
        call :print_success "python_backend\pyproject.toml mis à jour"
    )

    :: Mettre à jour le README.md
    if exist "README.md" (
        powershell -Command "(Get-Content README.md) -replace '# Template d''Application Flutter/Python \(YEB\)', '# %PROJECT_NAME%' | Set-Content README.md"
        powershell -Command "(Get-Content README.md) -replace 'Ce template fournit une base pour développer des applications Flutter avec un backend Python.', '%PROJECT_DESCRIPTION%' | Set-Content README.md"
        call :print_success "README.md mis à jour"
    )

    :: Mettre à jour le fichier de configuration du projet Flutter
    if exist "flutter_app\lib\config\project_config.dart" (
        powershell -Command "(Get-Content flutter_app\lib\config\project_config.dart) -replace 'static const String projectName = \"yeb_app_template\";', 'static const String projectName = \"%PROJECT_NAME%\";' | Set-Content flutter_app\lib\config\project_config.dart"
        call :print_success "Fichier de configuration Flutter mis à jour"
    )

    call :print_success "Personnalisation terminée"
    exit /b 0

:: Exécuter le script d'installation du projet
:run_setup_script
    call :print_header "Installation du projet"

    echo Exécution du script d'installation...

    :: Rendre les scripts exécutables (pas nécessaire sous Windows, mais pour cohérence)
    if exist "template\entry-points\*.bat" (
        if exist "template\entry-points\setup_project.bat" (
            call template\entry-points\setup_project.bat
            if %ERRORLEVEL% equ 0 (
                call :print_success "Installation terminée avec succès"
            ) else (
                call :print_warning "L'installation a rencontré des problèmes. Vérifiez les logs ci-dessus."
            )
        )
    )
    
    :: Suppression du dossier template qui n'est plus nécessaire après l'installation
    if exist "template" (
        echo Suppression du dossier template qui n'est plus nécessaire...
        rmdir /s /q template
        call :print_success "Dossier template supprimé avec succès"
    )
    exit /b 0

:: Mise à jour des instructions pour GitHub Copilot
:update_copilot_instructions
    call :print_header "Mise à jour des instructions pour GitHub Copilot"

    echo Mise à jour des instructions pour GitHub Copilot...

    :: Vérifier l'existence des répertoires et fichiers
    if exist ".github" (
        if exist ".github\copilot-instructions.md" (
            :: Remplacer le nom du projet dans les instructions Copilot
            echo Mise à jour du fichier .github\copilot-instructions.md...
            powershell -Command "(Get-Content .github\copilot-instructions.md) -replace 'YEB App Template', '%PROJECT_NAME%' | Set-Content .github\copilot-instructions.md"
            powershell -Command "(Get-Content .github\copilot-instructions.md) -replace 'yeb_app_template', '%PROJECT_NAME%' | Set-Content .github\copilot-instructions.md"
        ) else (
            echo %YELLOW%Avertissement:%NC% Le fichier .github\copilot-instructions.md n'a pas été trouvé.
        )
    )

    :: Mettre à jour les informations dans le fichier de mémoire long terme
    if exist ".copilot" (
        if exist ".copilot\memoire_long_terme.md" (
            echo Mise à jour du fichier .copilot\memoire_long_terme.md...
            powershell -Command "(Get-Content .copilot\memoire_long_terme.md) -replace 'YEB App Template', '%PROJECT_NAME%' | Set-Content .copilot\memoire_long_terme.md"
            powershell -Command "(Get-Content .copilot\memoire_long_terme.md) -replace 'yeb_app_template', '%PROJECT_NAME%' | Set-Content .copilot\memoire_long_terme.md"
        )
    )

    :: Créer le fichier chat_resume.md s'il n'existe pas encore
    if not exist ".copilot\chat_resume.md" (
        echo Création du fichier .copilot\chat_resume.md...
        if not exist ".copilot" mkdir .copilot
        echo # Résumé des sessions de travail - Projet %PROJECT_NAME% > .copilot\chat_resume.md
        echo. >> .copilot\chat_resume.md
        echo Ce fichier sert à maintenir un résumé chronologique des sessions de travail avec GitHub Copilot sur le projet %PROJECT_NAME%. >> .copilot\chat_resume.md
        echo. >> .copilot\chat_resume.md
        echo ## Initialisation du projet >> .copilot\chat_resume.md
        echo. >> .copilot\chat_resume.md
        echo - Date: %date% >> .copilot\chat_resume.md
        echo - Actions: >> .copilot\chat_resume.md
        echo   - Création initiale du projet à partir du template yeb_app_template >> .copilot\chat_resume.md
        echo   - Personnalisation du projet avec le nom "%PROJECT_NAME%" >> .copilot\chat_resume.md
        echo   - Description du projet: "%PROJECT_DESCRIPTION%" >> .copilot\chat_resume.md
        echo   - Configuration de l'environnement de développement >> .copilot\chat_resume.md
        echo. >> .copilot\chat_resume.md
        echo ## Prochaines étapes >> .copilot\chat_resume.md
        echo. >> .copilot\chat_resume.md
        echo - Personnaliser l'interface utilisateur Flutter pour répondre aux besoins du projet >> .copilot\chat_resume.md
        echo - Adapter les scripts Python pour les calculs spécifiques au projet >> .copilot\chat_resume.md
        echo - Mettre en place la logique métier spécifique au projet >> .copilot\chat_resume.md
    )

    call :print_success "Instructions pour GitHub Copilot mises à jour"
    exit /b 0

:: Afficher les instructions finales
:show_final_instructions
    call :print_header "Félicitations! Votre projet est prêt."

    echo Le projet %GREEN%%PROJECT_NAME%%NC% a été créé et configuré avec succès.
    echo.
    echo Prochaines étapes recommandées :
    echo 1. Consultez la documentation dans le dossier %YELLOW%docs\%NC% pour plus d'informations
    echo 2. Lancez votre application en développement avec %YELLOW%run_dev.bat%NC% (Windows) ou %YELLOW%.\run_dev.sh%NC% (Unix)
    echo 3. Pour le développement web, utilisez %YELLOW%start_web_integrated.bat%NC% (Windows) ou %YELLOW%.\start_web_integrated.sh%NC% (Unix)
    echo 4. Créez une branche de développement avec: %YELLOW%git checkout -b dev%NC%
    echo 5. Utilisez git avec le workflow recommandé : développement sur %YELLOW%'dev'%NC%, fusion vers %YELLOW%'main'%NC%
    echo    Pour fusionner dev vers main : %YELLOW%scripts\merge_to_main.bat%NC%
    echo.
    echo Si vous utilisez VS Code avec GitHub Copilot, demandez à l'assistant de %YELLOW%'lire les fichiers dans .copilot'%NC%
    echo pour vous aider à personnaliser davantage votre projet.
    echo.
    echo %GREEN%Bon développement!%NC%
    exit /b 0

:: Fonction principale
:main
    call :print_header "Création d'un nouveau projet à partir du template yeb_app_template"

    call :check_prerequisites
    if %ERRORLEVEL% neq 0 exit /b 1
    
    call :configure_project
    if %ERRORLEVEL% neq 0 exit /b 1
    
    call :download_template
    if %ERRORLEVEL% neq 0 exit /b 1
    
    call :customize_template
    if %ERRORLEVEL% neq 0 exit /b 1
    
    call :update_copilot_instructions
    if %ERRORLEVEL% neq 0 exit /b 1
    
    call :run_setup_script
    if %ERRORLEVEL% neq 0 exit /b 1
    
    call :show_final_instructions
    exit /b 0

:: Exécuter la fonction principale
call :main
exit /b %ERRORLEVEL%