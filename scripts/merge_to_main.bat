@echo off
:: ==========================================================================
:: RÉFÉRENCES CROISÉES:
:: - Ce fichier est référencé dans: [.copilot/methodologie_temp.md:53, 73, 81]
:: - Ce fichier est référencé dans: [scripts/merge_to_main.sh:40]
:: ==========================================================================

:: Script d'automatisation pour fusionner la branche 'dev' vers 'main' sur Windows
:: Ce script implémente les règles définies dans .copilot/methodologie_temp.md
:: en excluant automatiquement certains fichiers lors de la fusion.
::
:: ⚠️ ATTENTION: Ce script ne doit JAMAIS être inclus dans la branche main ⚠️

setlocal EnableDelayedExpansion

:: Définition des couleurs (pour Windows 10 ou supérieur)
set "GREEN=[92m"
set "YELLOW=[93m"
set "RED=[91m"
set "BLUE=[94m"
set "BOLD=[1m"
set "NC=[0m"

:: Fonction pour afficher un message d'en-tête
:print_header
echo %BLUE%===============================================%NC%
echo %BLUE%  %~1%NC%
echo %BLUE%===============================================%NC%
goto :eof

:: Fonction pour afficher un message de succès
:print_success
echo %GREEN%✓ %~1%NC%
goto :eof

:: Fonction pour afficher un message d'erreur
:print_error
echo %RED%✗ %~1%NC%
goto :eof

:: Fonction pour afficher un avertissement
:print_warning
echo %YELLOW%⚠ %~1%NC%
goto :eof

:: Fonction pour afficher une étape
:print_step
echo.
echo %BOLD%%~1%NC%
goto :eof

:: Affichage du message d'introduction
call :print_header "FUSION AUTOMATIQUE DE DEV VERS MAIN"

:: ÉTAPE 1: Vérification de l'état actuel
call :print_step "ÉTAPE 1: Vérification de l'état actuel"

:: Vérifier qu'on est sur la branche dev
for /f "tokens=*" %%a in ('git branch --show-current') do set "current_branch=%%a"
if not "%current_branch%"=="dev" (
    call :print_warning "Vous n'êtes pas sur la branche 'dev' (branche actuelle: %current_branch%)"
    set /p confirm=Voulez-vous basculer sur la branche 'dev' ? (o/N)
    if /i "!confirm!"=="o" (
        git checkout dev
        if !errorlevel! neq 0 (
            call :print_error "Échec du passage à la branche dev."
            exit /b 1
        )
        call :print_success "Basculé sur la branche 'dev'"
    ) else (
        call :print_error "Le script doit être exécuté depuis la branche 'dev'"
        exit /b 1
    )
)

:: Vérifier qu'il n'y a pas de modifications non commitées
for /f "tokens=*" %%a in ('git status --porcelain') do set "has_changes=yes"
if defined has_changes (
    call :print_error "Il y a des modifications non commitées!"
    echo Liste des fichiers modifiés:
    git status --short

    set /p commit_confirm=Voulez-vous continuer en commitant ces modifications? (o/N)
    if /i "!commit_confirm!"=="o" (
        set /p commit_message=Message de commit:
        git add .
        git commit -m "!commit_message!"
        call :print_success "Modifications commitées"
    ) else (
        call :print_warning "Veuillez commiter ou stasher vos modifications d'abord"
        exit /b 1
    )
)

:: ÉTAPE 2: Mise à jour des branches
call :print_step "ÉTAPE 2: Mise à jour des branches"

:: Synchroniser la branche dev avec le dépôt distant
echo Synchronisation de la branche 'dev' avec le dépôt distant...
git pull origin dev
if !errorlevel! neq 0 (
    call :print_error "Échec de la mise à jour de la branche dev."
    exit /b 1
)
call :print_success "Branche 'dev' synchronisée"

:: ÉTAPE 3: Création d'une branche temporaire
call :print_step "ÉTAPE 3: Création d'une branche temporaire"

:: Créer une branche temporaire pour la fusion
for /f "tokens=*" %%a in ('powershell -Command "Get-Date -Format 'yyyyMMddHHmmss'"') do set "timestamp=%%a"
set "temp_branch=temp_merge_to_main_!timestamp!"
git checkout -b !temp_branch!
if !errorlevel! neq 0 (
    call :print_error "Échec de la création de la branche temporaire."
    exit /b 1
)
call :print_success "Branche temporaire '!temp_branch!' créée"

:: ÉTAPE 4: Exclusion des fichiers spécifiques au développement
call :print_step "ÉTAPE 4: Exclusion des fichiers spécifiques au développement"

:: Liste des fichiers à exclure complètement
echo Fichiers à exclure complètement:

:: Traitement des fichiers à exclure
set "file=.copilot\methodologie_temp.md"
echo • %file%:
if exist "%file%" (
    git rm -f "%file%" 2>nul
    if !errorlevel! equ 0 (
        echo   Exclu avec succès
    ) else (
        del /f /q "%file%" 2>nul
        echo   Supprimé (non suivi par git)
    )
) else (
    echo   Non trouvé, déjà exclu
)

set "file=scripts\merge_to_main.sh"
echo • %file%:
if exist "%file%" (
    git rm -f "%file%" 2>nul
    if !errorlevel! equ 0 (
        echo   Exclu avec succès
    ) else (
        del /f /q "%file%" 2>nul
        echo   Supprimé (non suivi par git)
    )
) else (
    echo   Non trouvé, déjà exclu
)

set "file=scripts\merge_to_main.bat"
echo • %file%:
if exist "%file%" (
    git rm -f "%file%" 2>nul
    if !errorlevel! equ 0 (
        echo   Exclu avec succès
    ) else (
        del /f /q "%file%" 2>nul
        echo   Supprimé (non suivi par git)
    )
) else (
    echo   Non trouvé, déjà exclu
)

:: Fichier chat_resume.md à vider
echo • .copilot\chat_resume.md:
if exist ".copilot\chat_resume.md" (
    :: Créer un contenu minimal pour le fichier
    (
        echo # Résumé des sessions de travail avec GitHub Copilot
        echo.
        echo Ce document résume les sessions de travail avec GitHub Copilot pour faciliter la reprise du contexte.
        echo.
        echo ## Initialisation du projet
        echo.
        echo Utilisez ce fichier pour documenter vos sessions de travail avec GitHub Copilot.
    ) > .copilot\chat_resume.md

    git add .copilot\chat_resume.md
    echo   Vidé avec succès
) else (
    echo   Non trouvé
)

:: Vider tous les fichiers de sessions
echo • Fichiers dans .copilot\sessions\:
if exist ".copilot\sessions\" (
    for /f "tokens=*" %%f in ('dir /b /a-d ".copilot\sessions\*.md" 2^>nul') do (
        set "filename=%%~nf"
        echo   - !filename!:

        :: Vider le fichier avec un contenu minimal
        (
            echo # Session !filename!
            echo.
            echo Cette session a été vidée lors de la fusion vers la branche main.
        ) > ".copilot\sessions\%%f"

        git add ".copilot\sessions\%%f"
        echo     Vidé
    )
) else (
    echo   Répertoire non trouvé
)

:: ÉTAPE 5: Commit des modifications sur la branche temporaire
call :print_step "ÉTAPE 5: Commit des modifications sur la branche temporaire"

:: Commit des modifications pour l'exclusion des fichiers
for /f "tokens=*" %%a in ('git status --porcelain') do set "has_changes=yes"
if defined has_changes (
    git commit -m "Préparation de la fusion vers main - Exclusion des fichiers spécifiques au développement"
    if !errorlevel! neq 0 (
        call :print_error "Échec du commit des modifications"
        git checkout dev
        git branch -D "!temp_branch!"
        exit /b 1
    )
    call :print_success "Modifications commitées sur la branche temporaire"
) else (
    call :print_warning "Aucun fichier à exclure n'a été trouvé ou modifié"
)

:: ÉTAPE 6: Fusion vers main
call :print_step "ÉTAPE 6: Fusion vers main"

:: Basculer sur la branche main
echo Passage à la branche 'main'...
git checkout main
if !errorlevel! neq 0 (
    call :print_error "Échec du passage à la branche main."
    git checkout dev
    git branch -D "!temp_branch!"
    exit /b 1
)

:: Synchroniser la branche main avec le dépôt distant
echo Synchronisation de la branche 'main' avec le dépôt distant...
git pull origin main
if !errorlevel! neq 0 (
    call :print_error "Échec de la mise à jour de la branche main."
    git checkout dev
    git branch -D "!temp_branch!"
    exit /b 1
)

:: Fusion de la branche temporaire dans main
echo Fusion de '!temp_branch!' vers 'main'...
git merge "!temp_branch!" -m "Merge automatique de dev vers main avec exclusion des fichiers spécifiques"
if !errorlevel! neq 0 (
    call :print_error "Conflit de fusion détecté!"
    echo.
    echo Suivez ces étapes pour résoudre les conflits:
    echo 1. Résolvez les conflits manuellement dans les fichiers marqués
    echo 2. Utilisez 'git add ^<fichier^>' pour marquer les conflits comme résolus
    echo 3. Exécutez 'git commit -m "Résolution des conflits de fusion"'
    echo 4. Exécutez 'git push origin main'
    echo 5. Revenez à la branche dev: 'git checkout dev'
    echo 6. Supprimez la branche temporaire: 'git branch -D !temp_branch!'
    exit /b 1
)

call :print_success "Fusion réussie"

:: ÉTAPE 7: Vérification des fichiers exclus
call :print_step "ÉTAPE 7: Vérification des fichiers exclus"

:: Vérifier que les fichiers critiques ont bien été exclus
echo Vérification que les fichiers sensibles ont bien été exclus de 'main'...
set "errors_found=0"

:: Vérifier l'exclusion des fichiers
for %%f in (".copilot\methodologie_temp.md" "scripts\merge_to_main.sh" "scripts\merge_to_main.bat") do (
    git ls-tree -r main --name-only | find "%%f" > nul
    if !errorlevel! equ 0 (
        call :print_error "Le fichier '%%f' est toujours présent dans la branche main"
        set /a errors_found+=1
    ) else (
        call :print_success "Le fichier '%%f' a été correctement exclu"
    )
)

:: Vérifier que chat_resume.md a été vidé
git show main:.copilot/chat_resume.md | find "Résumé des sessions de travail" > nul
if !errorlevel! equ 0 (
    call :print_success "Le fichier '.copilot\chat_resume.md' a été correctement vidé"
) else (
    call :print_warning "Le fichier '.copilot\chat_resume.md' n'a pas été correctement vidé ou n'existe pas"
)

if !errors_found! gtr 0 (
    call :print_warning "Des problèmes ont été détectés avec l'exclusion des fichiers"
    set /p continue_confirm=Voulez-vous continuer quand même? (o/N)
    if /i not "!continue_confirm!"=="o" (
        call :print_error "Fusion annulée"
        git checkout dev
        git branch -D "!temp_branch!"
        exit /b 1
    )
)

:: ÉTAPE 8: Push vers le dépôt distant
call :print_step "ÉTAPE 8: Push vers le dépôt distant"

:: Push des modifications
echo Push des modifications vers le dépôt distant...
set /p push_confirm=Voulez-vous pusher les modifications vers la branche 'main' distante? (O/n)
if /i not "!push_confirm!"=="n" (
    git push origin main
    if !errorlevel! neq 0 (
        call :print_error "Échec du push vers main."
        git checkout dev
        exit /b 1
    )
    call :print_success "Les modifications ont été pushées vers 'main'"
) else (
    call :print_warning "Les modifications n'ont pas été pushées vers le dépôt distant"
)

:: ÉTAPE 9: Nettoyage et retour à dev
call :print_step "ÉTAPE 9: Nettoyage et retour à dev"

:: Retour à la branche dev
echo Retour à la branche 'dev'...
git checkout dev
if !errorlevel! neq 0 (
    call :print_error "Échec du retour à la branche dev."
    exit /b 1
)

:: Suppression de la branche temporaire
echo Suppression de la branche temporaire '!temp_branch!'...
git branch -D "!temp_branch!"
if !errorlevel! neq 0 (
    call :print_error "Échec de la suppression de la branche temporaire."
    exit /b 1
)

call :print_header "FUSION TERMINÉE"

echo.
echo Résumé de l'opération:
for /f "tokens=*" %%a in ('git branch --show-current') do set "current_branch=%%a"
echo • Branche actuelle: %YELLOW%!current_branch!%NC%
echo • La branche %YELLOW%main%NC% a été mise à jour avec le contenu de %YELLOW%dev%NC%
echo • Les fichiers spécifiques au développement ont été exclus

if !errors_found! gtr 0 (
    echo.
    echo %YELLOW%⚠ Avertissement: Des problèmes ont été détectés lors de la vérification%NC%
    echo   Vérifiez manuellement que tous les fichiers sensibles ont bien été exclus
) else (
    echo.
    echo %GREEN%✓ Tous les fichiers sensibles ont été correctement exclus%NC%
)

echo.
echo Merci d'avoir utilisé le script d'automatisation de fusion!

endlocal
