@echo off
setlocal enabledelayedexpansion

:: ==========================================================================
:: RÉFÉRENCES CROISÉES:
:: - Ce fichier est référencé dans: [.github/copilot-instructions.md:18]
:: - Ce fichier est référencé dans: [.copilot/memoire_long_terme.md:37]
:: - Ce fichier est référencé dans: [scripts/merge_to_main.bat:84]
:: ==========================================================================

:: git_autocommit.bat
:: Script d'automatisation des opérations Git courantes (add, commit, push)
:: Ce script détecte les fichiers modifiés, génère un message de commit, puis effectue toutes les actions nécessaires
::
:: Utilisation:
::   git_autocommit.bat                  # Mode automatique (non-interactif)
::   git_autocommit.bat -i               # Mode interactif (questions pour le message et le push)
::   git_autocommit.bat --interactive    # Mode interactif (questions pour le message et le push)
::   git_autocommit.bat -m "Message"     # Mode automatique avec message personnalisé
::   git_autocommit.bat --message "Message" # Mode automatique avec message personnalisé

:: Couleurs pour l'affichage (codes ANSI pour Windows 10+)
set "GREEN=[0;32m"
set "YELLOW=[1;33m"
set "RED=[0;31m"
set "BLUE=[0;34m"
set "NC=[0m"

echo %BLUE%===============================================%NC%
echo %BLUE%  AUTOMATISATION GIT - ADD, COMMIT, PUSH       %NC%
echo %BLUE%===============================================%NC%
echo.

:: Vérifier l'état actuel du dépôt Git
echo %GREEN%1. Vérification de l'état actuel du dépôt Git%NC%
git status --porcelain > "%TEMP%\git_status.txt"

:: Vérifier si des changements existent
for %%I in ("%TEMP%\git_status.txt") do set size=%%~zI
if %size% EQU 0 (
    echo %YELLOW%Aucun changement détecté dans le dépôt.%NC%
    echo Statut Git actuel:
    git status
    del "%TEMP%\git_status.txt"
    exit /b 0
)

:: Afficher les fichiers modifiés
echo.
echo Fichiers modifiés:
type "%TEMP%\git_status.txt"
echo.

:: Variables pour le message de commit
set commit_message=
set interactive=0
set custom_message=0

:: Vérifier les paramètres
if "%1"=="--message" (
    set "commit_message=%~2"
    set custom_message=1
) else if "%1"=="-m" (
    set "commit_message=%~2"
    set custom_message=1
) else if "%1"=="--interactive" (
    set interactive=1
) else if "%1"=="-i" (
    set interactive=1
)

:: Générer un message de commit si pas de message personnalisé
if %custom_message%==0 (
    :: Initialiser les compteurs
    set /a md_files=0
    set /a sh_files=0
    set /a py_files=0
    set /a dart_files=0
    set /a docs_modified=0
    set /a scripts_modified=0
    set /a flutter_modified=0
    set /a python_modified=0
    set first_file=
    set /a num_files=0

    :: Compter les fichiers par type
    for /f "tokens=*" %%F in ('type "%TEMP%\git_status.txt" ^| findstr /R /C:"^[ ]*[AM]"') do (
        set /a num_files+=1
        set "file_path=%%F"
        set "file_path=!file_path:~3!"
        if "!first_file!"=="" set "first_file=!file_path!"

        if "!file_path:~-3!"==".md" set /a md_files+=1
        if "!file_path:~-3!"==".sh" set /a sh_files+=1
        if "!file_path:~-4!"==".bat" set /a sh_files+=1
        if "!file_path:~-3!"==".py" set /a py_files+=1
        if "!file_path:~-5!"==".dart" set /a dart_files+=1

        if "!file_path:~0,5!"=="docs\" set /a docs_modified+=1
        if "!file_path:~0,8!"=="scripts\" set /a scripts_modified+=1
        if "!file_path:~0,11!"=="flutter_app\" set /a flutter_modified+=1
        if "!file_path:~0,14!"=="python_backend" set /a python_modified+=1
        if "!file_path:~0,11!"=="web_backend" set /a python_modified+=1
        if "!file_path:~0,13!"=="shared_python" set /a python_modified+=1
    )

    :: Construire un message de commit pertinent
    set "commit_message=Mise à jour: "

    if !docs_modified! GTR 0 (
        if !md_files! GTR 0 (
            set "commit_message=!commit_message!documentation "
        )
    )

    if !scripts_modified! GTR 0 (
        if !sh_files! GTR 0 (
            set "commit_message=!commit_message!scripts d'automatisation "
        )
    )

    if !flutter_modified! GTR 0 (
        if !dart_files! GTR 0 (
            set "commit_message=!commit_message!code Flutter "
        )
    )

    if !python_modified! GTR 0 (
        if !py_files! GTR 0 (
            set "commit_message=!commit_message!code Python "
        )
    )

    :: Si le message est trop générique, utiliser une liste de fichiers
    if "!commit_message!"=="Mise à jour: " (
        if !num_files!==1 (
            set "commit_message=Mise à jour de !first_file!"
        ) else (
            set /a other_files=!num_files!-1
            set "commit_message=Mise à jour de !first_file! et !other_files! autres fichiers"
        )
    )
)

echo %GREEN%Message de commit généré:%NC% !commit_message!

:: En mode interactif, permettre la modification du message
if %interactive%==1 (
    echo %YELLOW%Voulez-vous utiliser ce message? [o/n/e] %NC%
    echo (o = oui, n = non (saisir un nouveau message), e = éditer ce message)
    set /p response=

    if "!response!"=="n" (
        echo %YELLOW%Entrez votre message de commit:%NC%
        set /p commit_message=
    ) else if "!response!"=="e" (
        echo !commit_message! > "%TEMP%\commit_msg_temp.txt"
        notepad "%TEMP%\commit_msg_temp.txt"
        set /p commit_message=<"%TEMP%\commit_msg_temp.txt"
        del "%TEMP%\commit_msg_temp.txt"
    )
) else (
    echo %GREEN%Utilisation du message généré automatiquement.%NC%
)

:: Ajouter tous les fichiers modifiés à l'index
echo.
echo %GREEN%2. Ajout des fichiers modifiés à l'index%NC%
git add .
echo %GREEN%Fichiers ajoutés avec succès.%NC%

:: Créer le commit avec le message validé
echo.
echo %GREEN%3. Création du commit%NC%
git commit -m "!commit_message!"
echo %GREEN%Commit créé avec succès.%NC%

:: Pousser les modifications vers la branche distante
echo.
echo %GREEN%4. Push vers le dépôt distant%NC%

if %interactive%==1 (
    echo %YELLOW%Voulez-vous pousser les changements vers le dépôt distant? [o/n]%NC%
    set /p push_response=

    if "!push_response!"=="o" (
        for /f "tokens=*" %%B in ('git branch --show-current') do set current_branch=%%B
        git push origin !current_branch!
        echo %GREEN%Push réussi vers la branche !current_branch!.%NC%
    ) else (
        echo %YELLOW%Les changements n'ont pas été poussés.%NC%
        for /f "tokens=*" %%B in ('git branch --show-current') do set current_branch=%%B
        echo Vous pouvez les pousser plus tard avec: git push origin !current_branch!
    )
) else (
    :: En mode non-interactif, push automatiquement
    for /f "tokens=*" %%B in ('git branch --show-current') do set current_branch=%%B
    git push origin !current_branch!
    echo %GREEN%Push automatique réussi vers la branche !current_branch!.%NC%
)

echo.
echo %GREEN%===============================================%NC%
echo %GREEN%  OPÉRATION TERMINÉE AVEC SUCCÈS              %NC%
echo %GREEN%===============================================%NC%

:: Nettoyer les fichiers temporaires
del "%TEMP%\git_status.txt"

endlocal
