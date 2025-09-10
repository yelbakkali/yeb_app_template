@echo off
REM Script d'initialisation du projet après l'utilisation du template

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

REM Vérifier si git est disponible
where git >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    call :print_error "Git n'est pas installé. Veuillez l'installer pour continuer."
    exit /b 1
)

REM Détecter le nom du projet à partir du dossier racine
for %%I in (.) do set "PROJECT_NAME=%%~nxI"

REM Si le nom du projet est toujours yeb_app_template, demander à l'utilisateur de le personnaliser
if "%PROJECT_NAME%"=="yeb_app_template" (
    call :print_warning "Le nom du dossier racine est encore 'yeb_app_template'."
    set /p "CUSTOM_NAME=Entrez un nom personnalisé pour votre projet (sans espaces ni caractères spéciaux) : "
    if not "%CUSTOM_NAME%"=="" (
        set "PROJECT_NAME=%CUSTOM_NAME%"
    )
)

call :print_header "Initialisation du projet '%PROJECT_NAME%'"
echo Ce script va personnaliser le template pour votre projet.

REM Créer un fichier de configuration central pour le nom du projet
echo Création du fichier de configuration du projet...
if not exist ".project_config" mkdir .project_config

REM Version Windows
echo @echo off > .project_config\project_info.bat
echo REM Informations sur le projet - générées automatiquement >> .project_config\project_info.bat
echo set PROJECT_NAME=%PROJECT_NAME% >> .project_config\project_info.bat
echo set PROJECT_CREATED_DATE=%date% >> .project_config\project_info.bat

REM Version Bash (pour WSL ou Git Bash)
echo #!/bin/bash > .project_config\project_info.sh
echo # Informations sur le projet - générées automatiquement >> .project_config\project_info.sh
echo PROJECT_NAME="%PROJECT_NAME%" >> .project_config\project_info.sh
echo PROJECT_CREATED_DATE="%date%" >> .project_config\project_info.sh

REM Création d'un fichier Dart pour les constantes du projet
if not exist "flutter_app\lib\config" mkdir flutter_app\lib\config
echo // Fichier généré automatiquement - Contient les informations de base du projet > flutter_app\lib\config\project_config.dart
echo class ProjectConfig { >> flutter_app\lib\config\project_config.dart
echo   static const String projectName = '%PROJECT_NAME%'; >> flutter_app\lib\config\project_config.dart
echo   static const String projectCreatedDate = '%date%'; >> flutter_app\lib\config\project_config.dart
echo } >> flutter_app\lib\config\project_config.dart

call :print_success "Fichier de configuration créé avec le nom du projet : %PROJECT_NAME%"

REM Renommer le fichier .code-workspace et mettre à jour les fichiers clés
call :print_header "Mise à jour du projet avec le nouveau nom"

REM Vérifier si le fichier code-workspace existe
if exist "yeb_app_template.code-workspace" (
    echo Renommage du fichier code-workspace...
    copy "yeb_app_template.code-workspace" "%PROJECT_NAME%.code-workspace" > nul
    del "yeb_app_template.code-workspace"
    
    REM Remplacer le contenu du fichier
    powershell -Command "(Get-Content '%PROJECT_NAME%.code-workspace') -replace 'yeb_app_template', '%PROJECT_NAME%' | Set-Content '%PROJECT_NAME%.code-workspace'"
    call :print_success "Fichier code-workspace renommé en %PROJECT_NAME%.code-workspace"
) else (
    call :print_warning "Fichier code-workspace non trouvé"
)

REM Mettre à jour le fichier pubspec.yaml
if exist "pubspec.yaml" (
    echo Mise à jour du nom du package dans pubspec.yaml...
    powershell -Command "(Get-Content 'pubspec.yaml') -replace '^name: yeb_app_template', 'name: %PROJECT_NAME%' | Set-Content 'pubspec.yaml'"
    call :print_success "Nom du package mis à jour dans pubspec.yaml"
)

REM Mettre à jour tous les imports dans le code
echo Mise à jour des imports dans les fichiers Dart...
powershell -Command "Get-ChildItem -Path . -Include *.dart -Recurse | ForEach-Object { (Get-Content $_.FullName) -replace 'package:yeb_app_template/', 'package:%PROJECT_NAME%/' | Set-Content $_.FullName }"
call :print_success "Imports mis à jour dans les fichiers Dart"

REM Mettre à jour les fichiers web
if exist "flutter_app\web\index.html" (
    echo Mise à jour du fichier index.html...
    powershell -Command "(Get-Content 'flutter_app\web\index.html') -replace 'content=""Application yeb_app_template', 'content=""Application %PROJECT_NAME%' | Set-Content 'flutter_app\web\index.html'"
    powershell -Command "(Get-Content 'flutter_app\web\index.html') -replace 'content=""yeb_app_template""', 'content=""%PROJECT_NAME%""' | Set-Content 'flutter_app\web\index.html'"
    powershell -Command "(Get-Content 'flutter_app\web\index.html') -replace '<title>yeb_app_template<', '<title>%PROJECT_NAME%<' | Set-Content 'flutter_app\web\index.html'"
    call :print_success "Fichier index.html mis à jour"
)

call :print_success "Renommage terminé"

REM Ne pas mettre à jour le pubspec.yaml pour Flutter avec le nom du projet
if exist "flutter_app\pubspec.yaml" (
    echo Vérification du pubspec.yaml...
    call :print_success "pubspec.yaml laissé inchangé, comme demandé"
)

REM Installer les dépendances
call :print_header "Installation des dépendances"

REM Exécuter le script d'installation Windows
if exist "scripts\setup.bat" (
    echo Exécution de scripts\setup.bat...
    call scripts\setup.bat
    call :print_success "Configuration Windows terminée"
) else (
    call :print_error "Le script setup.bat n'a pas été trouvé"
)

REM Installation des dépendances Flutter
where flutter >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo Installation des dépendances Flutter...
    pushd flutter_app
    flutter pub get
    popd
    call :print_success "Dépendances Flutter installées"
) else (
    call :print_warning "Flutter non trouvé dans le PATH. Veuillez l'installer manuellement."
)

REM Installation des dépendances Python si Poetry est installé
where poetry >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo Installation des dépendances Python pour le backend local...
    pushd python_backend
    poetry install
    popd
    echo Installation des dépendances Python pour le backend web...
    pushd web_backend
    poetry install
    popd
    call :print_success "Dépendances Python installées"
) else (
    call :print_warning "Poetry non trouvé. Veuillez installer Poetry et exécuter manuellement 'poetry install' dans les dossiers python_backend et web_backend."
)

REM Préparation du premier commit Git
call :print_header "Configuration Git"
if exist ".git" (
    echo Préparation du premier commit...
    git add .
    git commit -m "🚀 Initialisation du projet %PROJECT_NAME% à partir du template yeb_app_template"
    call :print_success "Premier commit créé"
) else (
    call :print_warning "Ce dossier n'est pas un dépôt Git. Veuillez initialiser Git manuellement."
)

REM Instructions finales
call :print_header "Projet initialisé avec succès !"
echo Votre projet '%PROJECT_NAME%' est maintenant configuré et prêt à l'emploi.
echo.
echo Prochaines étapes recommandées :
echo 1. Consultez la documentation dans le dossier 'docs/' pour plus d'informations
echo 2. Lancez votre application en développement avec 'run_dev.bat'
echo 3. Pour le développement web, utilisez 'start_web_dev.bat'
echo.
echo Si vous utilisez VS Code avec GitHub Copilot, demandez à l'assistant de 'lire la documentation dans docs/' pour vous aider à personnaliser davantage votre projet.
echo.
call :print_success "Bon développement !"
