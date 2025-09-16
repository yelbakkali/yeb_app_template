@echo off
:: ==========================================================================
:: RÉFÉRENCES CROISÉES:
:: - Ce fichier est référencé dans: [setup_project.bat:59]
:: - Ce fichier est référencé dans: [scripts/cleanup_init_files.bat:43, 118, 119, 120, 121]
:: - Ce fichier est référencé dans: [scripts/cleanup_init_files.sh:45, 117]
:: - Ce fichier est référencé dans: [docs/installation.md:162]
:: - Ce fichier est référencé dans: [docs/copilot/template_initialization.md:15]
:: - Ce fichier est référencé dans: [.copilot/methodologie_temp.md:35]
:: - Ce fichier est référencé dans: [template/docs/copilot/template_initialization.md:15]
:: ==========================================================================

REM Script d'initialisation du projet après l'utilisation du template

REM Couleurs pour les messages (Windows)
set "RED=[91m"
set "GREEN=[92m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "NC=[0m"

REM Vérifier si le script de prérequis existe et l'exécuter
set "SCRIPT_DIR=%~dp0"
set "PREREQ_SCRIPT=%SCRIPT_DIR%scripts\check_prerequisites.bat"

if exist "%PREREQ_SCRIPT%" (
    echo Vérification des prérequis avant l'initialisation...
    call "%PREREQ_SCRIPT%"

    REM Si le script de prérequis a affiché des avertissements, demander si l'utilisateur veut continuer
    if %ERRORLEVEL% NEQ 0 (
        echo %YELLOW%Des prérequis sont manquants. Voulez-vous continuer quand même ? (O/N)%NC%
        set /p CONTINUE_CHOICE=
        if /i not "%CONTINUE_CHOICE%"=="O" (
            echo Initialisation annulée. Veuillez installer les prérequis manquants et réessayer.
            exit /b 1
        )
    )
)

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

REM Vérifier si PowerShell est disponible
where powershell >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    call :print_error "PowerShell n'est pas disponible. Ce script nécessite PowerShell pour fonctionner correctement."
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
echo set PROJECT_CREATED_DATE=%ISO_DATE% >> .project_config\project_info.bat

REM Obtenir la date au format ISO (YYYY-MM-DD)
for /f "tokens=2 delims==" %%I in ('powershell -Command "Get-Date -Format 'yyyy-MM-dd'"') do set "ISO_DATE=%%I"

REM Version Bash (pour WSL ou Git Bash)
echo #!/bin/bash > .project_config\project_info.sh
echo # Informations sur le projet - générées automatiquement >> .project_config\project_info.sh
echo PROJECT_NAME="%PROJECT_NAME%" >> .project_config\project_info.sh
echo PROJECT_CREATED_DATE="%ISO_DATE%" >> .project_config\project_info.sh

REM Création d'un fichier Dart pour les constantes du projet
if not exist "flutter_app\lib\config" mkdir flutter_app\lib\config
echo // Fichier généré automatiquement - Contient les informations de base du projet > flutter_app\lib\config\project_config.dart
echo class ProjectConfig { >> flutter_app\lib\config\project_config.dart
echo   static const String projectName = '%PROJECT_NAME%'; >> flutter_app\lib\config\project_config.dart
echo   static const String projectCreatedDate = '%ISO_DATE%'; >> flutter_app\lib\config\project_config.dart
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
powershell -Command "try { Get-ChildItem -Path . -Include *.dart -Recurse | ForEach-Object { (Get-Content $_.FullName) -replace 'package:yeb_app_template/', 'package:%PROJECT_NAME%/' | Set-Content $_.FullName }; exit 0 } catch { Write-Host \"Erreur: $_\"; exit 1 }"
if %ERRORLEVEL% NEQ 0 (
    call :print_warning "Problème détecté lors de la mise à jour des imports. Certains fichiers peuvent ne pas avoir été mis à jour correctement."
) else (
    call :print_success "Imports mis à jour dans les fichiers Dart"
)

REM Mettre à jour les fichiers web
REM Mettre à jour les fichiers pour le Web
if exist "flutter_app\web\index.html" (
    echo Mise à jour du fichier index.html...
    REM Utiliser le chemin normalisé avec des slashes avant pour PowerShell
    set "WEB_INDEX=flutter_app/web/index.html"
    powershell -Command "(Get-Content '%WEB_INDEX%') -replace 'content=""Application yeb_app_template', 'content=""Application %PROJECT_NAME%' | Set-Content '%WEB_INDEX%'"
    powershell -Command "(Get-Content '%WEB_INDEX%') -replace 'content=""yeb_app_template""', 'content=""%PROJECT_NAME%""' | Set-Content '%WEB_INDEX%'"
    powershell -Command "(Get-Content '%WEB_INDEX%') -replace '<title>yeb_app_template<', '<title>%PROJECT_NAME%<' | Set-Content '%WEB_INDEX%'"

    if exist "flutter_app\web\manifest.json" (
        echo Mise à jour du manifest.json Web...
        set "WEB_MANIFEST=flutter_app/web/manifest.json"
        powershell -Command "(Get-Content '%WEB_MANIFEST%') -replace '""name"": ""flutter_app""', '""name"": ""%PROJECT_NAME%""' | Set-Content '%WEB_MANIFEST%'"
        powershell -Command "(Get-Content '%WEB_MANIFEST%') -replace '""short_name"": ""flutter_app""', '""short_name"": ""%PROJECT_NAME%""' | Set-Content '%WEB_MANIFEST%'"
        powershell -Command "(Get-Content '%WEB_MANIFEST%') -replace '""description"": ""A new Flutter project.""', '""description"": ""%PROJECT_NAME% application""' | Set-Content '%WEB_MANIFEST%'"
    )
    call :print_success "Fichiers web mis à jour"
)

REM Mettre à jour les fichiers pour Android
if exist "flutter_app\android\app\src\main\AndroidManifest.xml" (
    echo Mise à jour de AndroidManifest.xml...
    set "ANDROID_MANIFEST=flutter_app/android/app/src/main/AndroidManifest.xml"
    powershell -Command "(Get-Content '%ANDROID_MANIFEST%') -replace 'android:label=""flutter_app""', 'android:label=""%PROJECT_NAME%""' | Set-Content '%ANDROID_MANIFEST%'"

    REM Mise à jour du package dans build.gradle s'il existe
    if exist "flutter_app\android\app\build.gradle" (
        set "ANDROID_BUILD_GRADLE=flutter_app/android/app/build.gradle"
        powershell -Command "(Get-Content '%ANDROID_BUILD_GRADLE%') -replace 'applicationId ""com.example.flutter_app""', 'applicationId ""com.example.%PROJECT_NAME%""' | Set-Content '%ANDROID_BUILD_GRADLE%'"
    )

    call :print_success "Fichiers Android mis à jour"
)

REM Mettre à jour les fichiers pour iOS
if exist "flutter_app\ios\Runner\Info.plist" (
    echo Mise à jour de Info.plist pour iOS...
    set "IOS_PLIST=flutter_app/ios/Runner/Info.plist"
    powershell -Command "(Get-Content '%IOS_PLIST%') -replace '<key>CFBundleName</key>[^<]*<string>flutter_app</string>', '<key>CFBundleName</key>^M	<string>%PROJECT_NAME%</string>' | Set-Content '%IOS_PLIST%'"
    powershell -Command "(Get-Content '%IOS_PLIST%') -replace '<key>CFBundleDisplayName</key>[^<]*<string>flutter_app</string>', '<key>CFBundleDisplayName</key>^M	<string>%PROJECT_NAME%</string>' | Set-Content '%IOS_PLIST%'"
    call :print_success "Fichiers iOS mis à jour"
)

REM Mettre à jour les fichiers pour macOS
if exist "flutter_app\macos\Runner\Configs\AppInfo.xcconfig" (
    echo Mise à jour des fichiers pour macOS...
    set "MACOS_CONFIG=flutter_app/macos/Runner/Configs/AppInfo.xcconfig"
    powershell -Command "(Get-Content '%MACOS_CONFIG%') -replace 'PRODUCT_NAME = flutter_app', 'PRODUCT_NAME = %PROJECT_NAME%' | Set-Content '%MACOS_CONFIG%'"
    call :print_success "Fichiers macOS mis à jour"
)

REM Mettre à jour les fichiers pour Windows
if exist "flutter_app\windows\runner\Runner.rc" (
    echo Mise à jour des fichiers pour Windows...
    set "WINDOWS_RC=flutter_app/windows/runner/Runner.rc"
    powershell -Command "(Get-Content '%WINDOWS_RC%') -replace 'VALUE ""FileDescription"", ""flutter_app""', 'VALUE ""FileDescription"", ""%PROJECT_NAME%""' | Set-Content '%WINDOWS_RC%'"
    powershell -Command "(Get-Content '%WINDOWS_RC%') -replace 'VALUE ""ProductName"", ""flutter_app""', 'VALUE ""ProductName"", ""%PROJECT_NAME%""' | Set-Content '%WINDOWS_RC%'"
    call :print_success "Fichiers Windows mis à jour"
)

REM Mettre à jour les fichiers pour Linux
if exist "flutter_app\linux\CMakeLists.txt" (
    echo Mise à jour des fichiers pour Linux...
    set "LINUX_CMAKE=flutter_app/linux/CMakeLists.txt"
    powershell -Command "(Get-Content '%LINUX_CMAKE%') -replace 'set\(BINARY_NAME ""flutter_app""\)', 'set(BINARY_NAME ""%PROJECT_NAME%"")' | Set-Content '%LINUX_CMAKE%'"
    powershell -Command "(Get-Content '%LINUX_CMAKE%') -replace 'set\(APPLICATION_ID ""com.example.flutter_app""\)', 'set(APPLICATION_ID ""com.example.%PROJECT_NAME%"")' | Set-Content '%LINUX_CMAKE%'"
    call :print_success "Fichiers Linux mis à jour"
)

call :print_success "Renommage terminé"

REM Configuration automatique de VS Code
call :print_header "Configuration de l'environnement VS Code"
if not exist ".vscode" mkdir .vscode

REM Création du fichier settings.json
echo Création du fichier settings.json...
powershell -Command "Add-Content -Path .vscode\settings.json -Value '{'"
powershell -Command "Add-Content -Path .vscode\settings.json -Value '  // Configuration Flutter'"
powershell -Command "Add-Content -Path .vscode\settings.json -Value '  \"dart.lineLength\": 100,'"
powershell -Command "Add-Content -Path .vscode\settings.json -Value '  \"[dart]\": {'"
powershell -Command "Add-Content -Path .vscode\settings.json -Value '    \"editor.formatOnSave\": true,'"
powershell -Command "Add-Content -Path .vscode\settings.json -Value '    \"editor.formatOnType\": true,'"
powershell -Command "Add-Content -Path .vscode\settings.json -Value '    \"editor.rulers\": [100],'"
powershell -Command "Add-Content -Path .vscode\settings.json -Value '    \"editor.selectionHighlight\": false,'"
powershell -Command "Add-Content -Path .vscode\settings.json -Value '    \"editor.suggestSelection\": \"first\",'"
powershell -Command "Add-Content -Path .vscode\settings.json -Value '    \"editor.tabCompletion\": \"onlySnippets\",'"
powershell -Command "Add-Content -Path .vscode\settings.json -Value '    \"editor.wordBasedSuggestions\": \"off\"'"
powershell -Command "Add-Content -Path .vscode\settings.json -Value '  },'"
powershell -Command "Add-Content -Path .vscode\settings.json -Value ''"
powershell -Command "Add-Content -Path .vscode\settings.json -Value '  // Configuration Python'"
powershell -Command "Add-Content -Path .vscode\settings.json -Value '  \"python.defaultInterpreterPath\": \"${workspaceFolder}/web_backend/.venv/bin/python\",'"
powershell -Command "Add-Content -Path .vscode\settings.json -Value '  \"python.linting.enabled\": true,'"
powershell -Command "Add-Content -Path .vscode\settings.json -Value '  \"python.linting.pylintEnabled\": true,'"
powershell -Command "Add-Content -Path .vscode\settings.json -Value '  \"python.formatting.provider\": \"black\",'"
powershell -Command "Add-Content -Path .vscode\settings.json -Value '  \"python.formatting.blackPath\": \"${workspaceFolder}/web_backend/.venv/bin/black\",'"
powershell -Command "Add-Content -Path .vscode\settings.json -Value '  \"python.formatting.blackArgs\": [\"--line-length\", \"88\"],'"
powershell -Command "Add-Content -Path .vscode\settings.json -Value '  \"[python]\": {'"
powershell -Command "Add-Content -Path .vscode\settings.json -Value '    \"editor.formatOnSave\": true,'"
powershell -Command "Add-Content -Path .vscode\settings.json -Value '    \"editor.codeActionsOnSave\": {'"
powershell -Command "Add-Content -Path .vscode\settings.json -Value '      \"source.organizeImports\": \"explicit\"'"
powershell -Command "Add-Content -Path .vscode\settings.json -Value '    }'"
powershell -Command "Add-Content -Path .vscode\settings.json -Value '  },'"
powershell -Command "Add-Content -Path .vscode\settings.json -Value ''"
powershell -Command "Add-Content -Path .vscode\settings.json -Value '  // Configuration générale'"
powershell -Command "Add-Content -Path .vscode\settings.json -Value '  \"files.autoSave\": \"afterDelay\",'"
powershell -Command "Add-Content -Path .vscode\settings.json -Value '  \"files.autoSaveDelay\": 1000,'"
powershell -Command "Add-Content -Path .vscode\settings.json -Value '  \"editor.tabSize\": 2,'"
powershell -Command "Add-Content -Path .vscode\settings.json -Value '  \"git.enableSmartCommit\": true,'"
powershell -Command "Add-Content -Path .vscode\settings.json -Value '  \"git.confirmSync\": false'"
powershell -Command "Add-Content -Path .vscode\settings.json -Value '}'"

REM Création du fichier extensions.json
echo Création du fichier extensions.json...
powershell -Command "Add-Content -Path .vscode\extensions.json -Value '{'"
powershell -Command "Add-Content -Path .vscode\extensions.json -Value '  \"recommendations\": ['"
powershell -Command "Add-Content -Path .vscode\extensions.json -Value '    \"dart-code.flutter\",'"
powershell -Command "Add-Content -Path .vscode\extensions.json -Value '    \"dart-code.dart-code\",'"
powershell -Command "Add-Content -Path .vscode\extensions.json -Value '    \"ms-python.python\",'"
powershell -Command "Add-Content -Path .vscode\extensions.json -Value '    \"ms-python.vscode-pylance\",'"
powershell -Command "Add-Content -Path .vscode\extensions.json -Value '    \"littlefoxteam.vscode-python-test-adapter\",'"
powershell -Command "Add-Content -Path .vscode\extensions.json -Value '    \"mhutchie.git-graph\",'"
powershell -Command "Add-Content -Path .vscode\extensions.json -Value '    \"eamodio.gitlens\",'"
powershell -Command "Add-Content -Path .vscode\extensions.json -Value '    \"dbaeumer.vscode-eslint\",'"
powershell -Command "Add-Content -Path .vscode\extensions.json -Value '    \"esbenp.prettier-vscode\"'"
powershell -Command "Add-Content -Path .vscode\extensions.json -Value '  ]'"
powershell -Command "Add-Content -Path .vscode\extensions.json -Value '}'"

REM Création du fichier launch.json
echo Création du fichier launch.json...
powershell -Command "Add-Content -Path .vscode\launch.json -Value '{'"
powershell -Command "Add-Content -Path .vscode\launch.json -Value '  \"version\": \"0.2.0\",'"
powershell -Command "Add-Content -Path .vscode\launch.json -Value '  \"configurations\": ['"
powershell -Command "Add-Content -Path .vscode\launch.json -Value '    {'"
powershell -Command "Add-Content -Path .vscode\launch.json -Value '      \"name\": \"Flutter App\",'"
powershell -Command "Add-Content -Path .vscode\launch.json -Value '      \"type\": \"dart\",'"
powershell -Command "Add-Content -Path .vscode\launch.json -Value '      \"request\": \"launch\",'"
powershell -Command "Add-Content -Path .vscode\launch.json -Value '      \"program\": \"flutter_app/lib/main.dart\"'"
powershell -Command "Add-Content -Path .vscode\launch.json -Value '    },'"
powershell -Command "Add-Content -Path .vscode\launch.json -Value '    {'"
powershell -Command "Add-Content -Path .vscode\launch.json -Value '      \"name\": \"Web Backend (Python)\",'"
powershell -Command "Add-Content -Path .vscode\launch.json -Value '      \"type\": \"python\",'"
powershell -Command "Add-Content -Path .vscode\launch.json -Value '      \"request\": \"launch\",'"
powershell -Command "Add-Content -Path .vscode\launch.json -Value '      \"program\": \"${workspaceFolder}/web_backend/main.py\",'"
powershell -Command "Add-Content -Path .vscode\launch.json -Value '      \"console\": \"integratedTerminal\"'"
powershell -Command "Add-Content -Path .vscode\launch.json -Value '    }'"
powershell -Command "Add-Content -Path .vscode\launch.json -Value '  ]'"
powershell -Command "Add-Content -Path .vscode\launch.json -Value '}'"

call :print_success "Configuration VS Code créée. Les extensions recommandées seront proposées à l'ouverture du projet."

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
call :print_header "Installation des dépendances Flutter"

where flutter >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo Installation des dépendances Flutter...
    pushd flutter_app
    flutter pub get
    if %ERRORLEVEL% NEQ 0 (
        call :print_error "Erreur lors de l'installation des dépendances Flutter. Vérifiez les messages d'erreur ci-dessus."
        call :print_warning "Vous pouvez essayer de résoudre les problèmes et exécuter 'cd flutter_app && flutter pub get' manuellement."
    ) else (
        call :print_success "Dépendances Flutter installées avec succès"
    )
    popd
) else (
    call :print_warning "Flutter non trouvé dans le PATH."
    call :print_warning "Pour installer Flutter:"
    echo 1. Visitez https://docs.flutter.dev/get-started/install
    echo 2. Téléchargez et extrayez Flutter SDK
    echo 3. Ajoutez le dossier flutter\bin au PATH système
    echo 4. Puis exécutez 'cd flutter_app && flutter pub get' pour installer les dépendances
)

REM Installation des dépendances Python
call :print_header "Installation des dépendances Python"

REM Vérification de l'installation de Poetry
where poetry >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    call :print_warning "Poetry n'est pas installé ou n'est pas dans le PATH"
    echo Installation automatique de Poetry...

    REM Tente d'installer Poetry avec PowerShell
    powershell -Command "try { (Invoke-WebRequest -Uri https://install.python-poetry.org -UseBasicParsing).Content | python -; exit 0 } catch { Write-Host \"Erreur lors de l'installation de Poetry: $_\"; exit 1 }"

    if %ERRORLEVEL% EQU 0 (
        call :print_success "Poetry installé avec succès"
        REM Ajout de Poetry au PATH pour cette session
        set "PATH=%USERPROFILE%\.poetry\bin;%PATH%"
        where poetry >nul 2>nul
        if %ERRORLEVEL% NEQ 0 (
            set "PATH=%APPDATA%\Python\Scripts;%PATH%"
            where poetry >nul 2>nul
            if %ERRORLEVEL% NEQ 0 (
                call :print_error "Poetry installé mais non trouvé dans le PATH. Ajoutez manuellement le chemin de Poetry à votre PATH."
                call :print_warning "Veuillez exécuter manuellement 'poetry install' dans les dossiers python_backend et web_backend."
                set "POETRY_INSTALLED=false"
            ) else (
                set "POETRY_INSTALLED=true"
            )
        ) else (
            set "POETRY_INSTALLED=true"
        )
    ) else (
        call :print_error "Échec de l'installation de Poetry. Veuillez l'installer manuellement: https://python-poetry.org/docs/#installation"
        call :print_warning "Veuillez exécuter manuellement 'poetry install' dans les dossiers python_backend et web_backend."
        set "POETRY_INSTALLED=false"
    )
) else (
    set "POETRY_INSTALLED=true"
)

REM Si Poetry est installé, installer les dépendances
if "%POETRY_INSTALLED%"=="true" (
    REM Installation pour python_backend
    echo Installation des dépendances Python pour le backend local...
    pushd python_backend
    poetry install
    if %ERRORLEVEL% NEQ 0 (
        call :print_error "Erreur lors de l'installation des dépendances Python dans python_backend"
    )
    popd

    REM Installation pour web_backend
    echo Installation des dépendances Python pour le backend web...
    pushd web_backend
    poetry install
    if %ERRORLEVEL% NEQ 0 (
        call :print_error "Erreur lors de l'installation des dépendances Python dans web_backend"
    )
    popd

    call :print_success "Tentative d'installation des dépendances Python terminée"
)

REM Configuration de VS Code pour l'installation automatique des dépendances Flutter
call :print_header "Configuration de VS Code"
if exist "%SCRIPT_DIR%scripts\configure_vscode_for_flutter.bat" (
    echo Configuration de VS Code pour Flutter...
    call "%SCRIPT_DIR%scripts\configure_vscode_for_flutter.bat"
    call :print_success "VS Code configuré pour l'installation automatique des dépendances Flutter"
) else (
    call :print_warning "Le script de configuration de VS Code n'a pas été trouvé."
)

REM Installation des dépendances du projet
call :print_header "Installation des dépendances"
if exist "%SCRIPT_DIR%scripts\install_dependencies.bat" (
    echo Installation des dépendances du projet...
    call "%SCRIPT_DIR%scripts\install_dependencies.bat"
    call :print_success "Dépendances installées avec succès"
) else (
    call :print_warning "Le script d'installation des dépendances n'a pas été trouvé."
)

REM Configuration Git et création des branches
call :print_header "Configuration Git"
if exist ".git" (
    echo Préparation du premier commit...
    git add .
    git commit -m "🚀 Initialisation du projet %PROJECT_NAME% à partir du template yeb_app_template"
    call :print_success "Premier commit créé"

    REM Vérifier si la branche main existe déjà
    git rev-parse --verify main >nul 2>nul
    if %ERRORLEVEL% EQU 0 (
        echo La branche main existe déjà
    ) else (
        REM Renommer la branche actuelle en main si ce n'est pas déjà le cas
        for /f "tokens=*" %%a in ('git branch --show-current') do set current_branch=%%a
        if not "!current_branch!"=="main" (
            echo Renommage de la branche '!current_branch!' en 'main'...
            git branch -m !current_branch! main
            call :print_success "Branche renommée en 'main'"
        )
    )

    REM Création de la branche dev
    echo Création de la branche dev...
    git rev-parse --verify dev >nul 2>nul
    if %ERRORLEVEL% EQU 0 (
        echo La branche dev existe déjà
    ) else (
        git checkout -b dev
        call :print_success "Branche dev créée et activée"
    )

    echo Configuration du flux de travail Git : main (stable) et dev (développement)
) else (
    call :print_warning "Ce dossier n'est pas un dépôt Git. Initialisation Git..."
    git init
    git add .
    git commit -m "🚀 Initialisation du projet %PROJECT_NAME% à partir du template yeb_app_template"

    REM Renommer la branche par défaut en main
    git branch -m main
    call :print_success "Dépôt Git initialisé avec la branche principale 'main'"

    REM Création de la branche dev
    git checkout -b dev
    call :print_success "Branche dev créée et activée"

    echo Flux de travail Git configuré : main (stable) et dev (développement)

    echo.
    echo %YELLOW%Conseil : Pour connecter ce dépôt à GitHub ou un autre service distant :%NC%
    echo 1. Créez un dépôt vide sur GitHub/GitLab/etc.
    echo 2. Exécutez : git remote add origin URL_DU_DEPOT
    echo 3. Exécutez : git push -u origin main
    echo 4. Exécutez : git push -u origin dev
)

REM Proposer de nettoyer les fichiers d'initialisation
call :print_header "Finalisation"
echo Souhaitez-vous supprimer les scripts d'initialisation maintenant qu'ils ont été exécutés ?
echo Ces scripts ne sont plus nécessaires après la première configuration et peuvent être supprimés.
set /p CLEANUP_CHOICE=Nettoyer les fichiers d'initialisation ? (O/N)
if /i "%CLEANUP_CHOICE%"=="O" (
    if exist "%SCRIPT_DIR%scripts\cleanup_init_files.bat" (
        echo Exécution du script de nettoyage...
        call "%SCRIPT_DIR%scripts\cleanup_init_files.bat"
    ) else (
        call :print_warning "Script de nettoyage non trouvé"
    )
) else (
    echo Les fichiers d'initialisation n'ont pas été supprimés.
    echo Vous pouvez les nettoyer ultérieurement en exécutant scripts\cleanup_init_files.bat
)

REM Instructions finales
call :print_header "Projet initialisé avec succès !"
echo Votre projet '%PROJECT_NAME%' est maintenant configuré et prêt à l'emploi.
echo.
echo Prochaines étapes recommandées :
echo 1. Consultez la documentation dans le dossier 'docs/' pour plus d'informations
echo 2. Lancez votre application en développement avec 'run_dev.bat'
echo 3. Pour le développement web, utilisez 'start_web_dev.bat'
echo 4. Utilisez git avec le workflow recommandé : développement sur 'dev', fusion vers 'main'
echo    Pour fusionner dev vers main : scripts\merge_to_main.bat
echo.
echo Si vous utilisez VS Code avec GitHub Copilot, demandez à l'assistant de 'lire la documentation dans docs/' pour vous aider à personnaliser davantage votre projet.
echo.
call :print_success "Bon développement !"
