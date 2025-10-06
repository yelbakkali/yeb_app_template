@echo off
:: ==========================================================================
:: RÉFÉRENCES CROISÉES:
:: - Ce fichier est créé pour être utilisé par les scripts d'installation Windows
:: ==========================================================================

:: Script de vérification et configuration Git pour Windows
:: Ce script vérifie si Git est correctement configuré (user.name et user.email)
:: et aide l'utilisateur à configurer Git si nécessaire

setlocal enabledelayedexpansion

:: Couleurs pour les messages (codes ANSI même sous Windows 10+)
set "RED=[91m"
set "GREEN=[92m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "BOLD=[1m"
set "NC=[0m"

:: Fonctions utilitaires
:echo_info
echo %BLUE%%BOLD%[INFO]%NC% %*
goto :eof

:echo_success
echo %GREEN%%BOLD%[SUCCÈS]%NC% %*
goto :eof

:echo_warning
echo %YELLOW%%BOLD%[AVERTISSEMENT]%NC% %*
goto :eof

:echo_error
echo %RED%%BOLD%[ERREUR]%NC% %*
goto :eof

:: Fonction principale
:main
call :check_git_config
if %ERRORLEVEL% equ 0 (
    call :ask_setup_github
)
goto :eof

:: Fonction pour vérifier si Git est correctement configuré
:check_git_config
call :echo_info "Vérification de la configuration Git..."

:: Vérifier si Git est installé
where git >nul 2>&1
if %ERRORLEVEL% neq 0 (
    call :echo_error "Git n'est pas installé sur votre système."
    call :echo_info "Veuillez installer Git avant de continuer: https://git-scm.com/download/win"
    exit /b 1
)

:: Vérifier si user.name est configuré
for /f "tokens=*" %%a in ('git config --global user.name') do set "GIT_USER_NAME=%%a"
if "!GIT_USER_NAME!"=="" (
    call :echo_warning "Git user.name n'est pas configuré."
    call :echo_info "Configuration de Git user.name..."
    
    set /p "git_name=Entrez votre nom pour Git (ex: John Doe) : "
    if "!git_name!"=="" (
        call :echo_error "Aucun nom fourni. Configuration incomplète."
        exit /b 1
    )
    
    git config --global user.name "!git_name!"
    call :echo_success "Git user.name configuré : !git_name!"
) else (
    call :echo_success "Git user.name déjà configuré : !GIT_USER_NAME!"
)

:: Vérifier si user.email est configuré
for /f "tokens=*" %%a in ('git config --global user.email') do set "GIT_USER_EMAIL=%%a"
if "!GIT_USER_EMAIL!"=="" (
    call :echo_warning "Git user.email n'est pas configuré."
    call :echo_info "Configuration de Git user.email..."
    
    set /p "git_email=Entrez votre email pour Git (ex: john.doe@example.com) : "
    if "!git_email!"=="" (
        call :echo_error "Aucun email fourni. Configuration incomplète."
        exit /b 1
    )
    
    git config --global user.email "!git_email!"
    call :echo_success "Git user.email configuré : !git_email!"
) else (
    call :echo_success "Git user.email déjà configuré : !GIT_USER_EMAIL!"
)

:: Vérifier si la configuration par défaut de la branche est correcte
for /f "tokens=*" %%a in ('git config --global init.defaultBranch') do set "GIT_INIT_DEFAULT_BRANCH=%%a"
if "!GIT_INIT_DEFAULT_BRANCH!"=="" (
    call :echo_info "Configuration de la branche par défaut à 'main'..."
    git config --global init.defaultBranch main
    call :echo_success "Branche par défaut configurée à 'main'"
) else if "!GIT_INIT_DEFAULT_BRANCH!" neq "main" (
    call :echo_info "La branche par défaut est actuellement '!GIT_INIT_DEFAULT_BRANCH!'."
    call :echo_info "Pour ce projet, nous recommandons 'main'."
    set /p "change_branch=Voulez-vous changer la branche par défaut à 'main'? (o/n) : "
    if /I "!change_branch!"=="o" (
        git config --global init.defaultBranch main
        call :echo_success "Branche par défaut modifiée à 'main'"
    ) else (
        call :echo_warning "Vous avez choisi de conserver '!GIT_INIT_DEFAULT_BRANCH!' comme branche par défaut."
    )
) else (
    call :echo_success "Branche par défaut déjà configurée à 'main'"
)

call :echo_success "Configuration Git vérifiée avec succès!"
exit /b 0

:: Demande à l'utilisateur s'il souhaite configurer un dépôt GitHub
:ask_setup_github
call :echo_info "Souhaitez-vous créer un dépôt GitHub et le connecter à ce projet?"
set /p "create_github=Créer un dépôt GitHub? (o/n) : "
if /I "!create_github!"=="o" (
    call :setup_github_repository
) else (
    call :echo_info "Vous avez choisi de ne pas créer de dépôt GitHub."
    call :echo_info "Vous pourrez le faire plus tard manuellement avec les commandes:"
    echo 1. Créez un dépôt vide sur GitHub
    echo 2. git remote add origin https://github.com/VOTRE_NOM/VOTRE_REPO.git
    echo 3. git push -u origin main
    echo 4. git checkout -b dev ^&^& git push -u origin dev
)
goto :eof

:: Fonction pour créer un dépôt GitHub et le connecter au dépôt local
:setup_github_repository
call :echo_info "Configuration du dépôt GitHub..."

:: Vérifier si le projet est déjà un dépôt Git
if not exist ".git" (
    call :echo_warning "Ce dossier n'est pas un dépôt Git."
    call :echo_info "Initialisation du dépôt Git..."
    git init
    call :echo_success "Dépôt Git initialisé localement."
)

:: Demander les informations pour le dépôt GitHub
set /p "github_username=Nom d'utilisateur GitHub : "
if "!github_username!"=="" (
    call :echo_error "Aucun nom d'utilisateur fourni. Impossible de créer le dépôt GitHub."
    exit /b 1
)

set /p "github_repo=Nom du dépôt GitHub : "
if "!github_repo!"=="" (
    call :echo_error "Aucun nom de dépôt fourni. Impossible de créer le dépôt GitHub."
    exit /b 1
)

set /p "github_description=Description du dépôt (optionnelle) : "

set /p "is_private=Dépôt privé? (o/n) : "
if /I "!is_private!"=="o" (
    set "private_flag=--private"
) else (
    set "private_flag=--public"
)

call :echo_warning "Pour créer un dépôt GitHub, vous devez être authentifié avec un token."
call :echo_info "Si vous n'avez pas de token GitHub CLI, suivez ces étapes:"
echo 1. Installez GitHub CLI (gh): https://cli.github.com/manual/installation
echo 2. Exécutez 'gh auth login' et suivez les instructions

:: Vérifier si GitHub CLI est installé
where gh >nul 2>&1
if %ERRORLEVEL% neq 0 (
    call :echo_error "GitHub CLI (gh) n'est pas installé."
    call :echo_info "Installation de GitHub CLI..."
    call :echo_info "Téléchargement de GitHub CLI..."
    
    :: Vérifier si winget est disponible
    where winget >nul 2>&1
    if %ERRORLEVEL% equ 0 (
        winget install -e --id GitHub.cli
    ) else (
        call :echo_error "Impossible d'installer GitHub CLI automatiquement."
        call :echo_info "Veuillez l'installer manuellement depuis: https://cli.github.com/"
        call :echo_info "Vous pourrez créer le dépôt manuellement plus tard."
        exit /b 1
    )
)

:: Vérifier si l'utilisateur est authentifié avec GitHub CLI
gh auth status >nul 2>&1
if %ERRORLEVEL% neq 0 (
    call :echo_warning "Vous n'êtes pas authentifié avec GitHub CLI."
    call :echo_info "Veuillez vous authentifier maintenant..."
    
    gh auth login
    
    if %ERRORLEVEL% neq 0 (
        call :echo_error "Échec de l'authentification GitHub CLI."
        call :echo_info "Vous pourrez créer le dépôt manuellement plus tard."
        exit /b 1
    )
)

:: Créer le dépôt sur GitHub
call :echo_info "Création du dépôt GitHub '!github_username!/!github_repo!'..."
if "!github_description!" neq "" (
    gh repo create "!github_username!/!github_repo!" !private_flag! --description "!github_description!" --confirm
) else (
    gh repo create "!github_username!/!github_repo!" !private_flag! --confirm
)

if %ERRORLEVEL% neq 0 (
    call :echo_error "Échec de la création du dépôt GitHub."
    call :echo_info "Vous pourrez créer le dépôt manuellement plus tard."
    exit /b 1
)

call :echo_success "Dépôt GitHub créé avec succès!"

:: Ajouter le remote et pousser vers GitHub
call :echo_info "Configuration du remote GitHub..."
git remote add origin "https://github.com/!github_username!/!github_repo!.git"

:: Créer un premier commit s'il n'y en a pas
git log -1 >nul 2>&1
if %ERRORLEVEL% neq 0 (
    call :echo_info "Création d'un commit initial..."
    git add .
    git commit -m "🚀 Initial commit"
)

:: Renommer la branche principale en main si nécessaire
for /f "tokens=*" %%b in ('git branch --show-current') do set "current_branch=%%b"
if "!current_branch!" neq "main" (
    call :echo_info "Renommage de la branche '!current_branch!' en 'main'..."
    git branch -m "!current_branch!" main
)

:: Pousser vers GitHub
call :echo_info "Envoi du code vers GitHub (branche main)..."
git push -u origin main
if %ERRORLEVEL% neq 0 (
    call :echo_error "Échec de l'envoi vers GitHub."
    call :echo_info "Vous pourrez pousser le code manuellement plus tard avec 'git push -u origin main'"
    exit /b 1
)

:: Créer et pousser la branche dev
call :echo_info "Création de la branche de développement 'dev'..."
git checkout -b dev

call :echo_info "Envoi de la branche 'dev' vers GitHub..."
git push -u origin dev
if %ERRORLEVEL% neq 0 (
    call :echo_error "Échec de l'envoi de la branche 'dev' vers GitHub."
    call :echo_info "Vous pourrez pousser la branche manuellement plus tard avec 'git push -u origin dev'"
    exit /b 1
)

call :echo_success "Dépôt GitHub configuré avec succès!"
call :echo_info "URL du dépôt: https://github.com/!github_username!/!github_repo!"
call :echo_info "Branche principale: main (stable)"
call :echo_info "Branche de développement: dev (active)"

exit /b 0

:: Si le script est exécuté directement, lancer la fonction principale
:start
call :main
exit /b