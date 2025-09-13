@echo off
REM Script pour nettoyer les fichiers d'initialisation après leur première utilisation

REM Couleurs pour l'affichage
set "GREEN=[92m"
set "YELLOW=[93m"
set "RED=[91m"
set "BLUE=[94m"
set "NC=[0m"

echo %BLUE%===============================================%NC%
echo %BLUE%  NETTOYAGE DES FICHIERS D'INITIALISATION     %NC%
echo %BLUE%===============================================%NC%

REM Vérifier que l'utilisateur est sûr de vouloir supprimer ces fichiers
echo %YELLOW%ATTENTION : Ce script va supprimer ou archiver les fichiers d'initialisation%NC%
echo %YELLOW%qui ne sont plus nécessaires après la première configuration du projet.%NC%
echo.
set /p CONTINUE=Êtes-vous sûr de vouloir continuer ? (O/N) 
if /i not "%CONTINUE%"=="O" (
    echo Nettoyage annulé.
    exit /b 0
)

REM Chemin du répertoire racine du projet
set "PROJECT_ROOT=%~dp0.."
cd "%PROJECT_ROOT%"

REM Créer un répertoire d'archive si l'utilisateur préfère archiver plutôt que supprimer
echo.
set /p ARCHIVE_CHOICE=Voulez-vous archiver les fichiers plutôt que les supprimer ? (O/N) 
set ARCHIVE=false
if /i "%ARCHIVE_CHOICE%"=="O" (
    set ARCHIVE=true
    set "ARCHIVE_DIR=%PROJECT_ROOT%\.init_archive"
    if not exist "%ARCHIVE_DIR%" mkdir "%ARCHIVE_DIR%"
    echo %GREEN%Les fichiers seront archivés dans %ARCHIVE_DIR%%NC%
)

REM Liste des fichiers d'initialisation à supprimer ou archiver
set INIT_FILES=^
init_project.sh^
init_project.bat^
scripts\setup.sh^
scripts\setup.bat^
scripts\setup_windows.bat^
scripts\setup_wsl.sh

echo.
echo %BLUE%Traitement des fichiers d'initialisation :%NC%

REM Supprimer ou archiver les fichiers
for %%f in (%INIT_FILES%) do (
    if exist "%PROJECT_ROOT%\%%f" (
        if "%ARCHIVE%"=="true" (
            REM Créer les sous-répertoires nécessaires dans l'archive
            for %%d in ("%%f") do (
                set "FILE_DIR=%%~dpf"
                set "FILE_DIR=!FILE_DIR:%PROJECT_ROOT%\=!"
                if not exist "%ARCHIVE_DIR%\!FILE_DIR!" mkdir "%ARCHIVE_DIR%\!FILE_DIR!"
            )
            echo Archivage de %%f...
            copy "%PROJECT_ROOT%\%%f" "%ARCHIVE_DIR%\%%f" > nul
            del "%PROJECT_ROOT%\%%f"
            echo %GREEN%✓ %%f archivé%NC%
        ) else (
            echo Suppression de %%f...
            del "%PROJECT_ROOT%\%%f"
            echo %GREEN%✓ %%f supprimé%NC%
        )
    ) else (
        echo %YELLOW%? %%f non trouvé%NC%
    )
)

REM Créer un fichier README dans le répertoire d'archive
if "%ARCHIVE%"=="true" (
    echo # Fichiers d'initialisation archivés > "%ARCHIVE_DIR%\README.md"
    echo. >> "%ARCHIVE_DIR%\README.md"
    echo Ce répertoire contient des fichiers d'initialisation qui ont été utilisés lors de la première >> "%ARCHIVE_DIR%\README.md"
    echo configuration du projet et qui ne sont plus nécessaires pour le développement quotidien. >> "%ARCHIVE_DIR%\README.md"
    echo. >> "%ARCHIVE_DIR%\README.md"
    echo Ils sont conservés ici à titre de référence, mais peuvent être supprimés en toute sécurité >> "%ARCHIVE_DIR%\README.md"
    echo si vous n'en avez plus besoin. >> "%ARCHIVE_DIR%\README.md"
    echo. >> "%ARCHIVE_DIR%\README.md"
    for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (
        for /f "tokens=1-2 delims=: " %%d in ('time /t') do (
            echo Date d'archivage : %%c-%%a-%%b %%d:%%e >> "%ARCHIVE_DIR%\README.md"
        )
    )
    echo %GREEN%Fichier README.md créé dans le répertoire d'archive%NC%
)

REM Mettre à jour le .gitignore pour ignorer le répertoire d'archive si nécessaire
if "%ARCHIVE%"=="true" (
    if exist "%PROJECT_ROOT%\.gitignore" (
        findstr /C:".init_archive/" "%PROJECT_ROOT%\.gitignore" > nul
        if errorlevel 1 (
            echo. >> "%PROJECT_ROOT%\.gitignore"
            echo # Répertoire d'archive des fichiers d'initialisation >> "%PROJECT_ROOT%\.gitignore"
            echo .init_archive/ >> "%PROJECT_ROOT%\.gitignore"
            echo %GREEN%Répertoire d'archive ajouté à .gitignore%NC%
        )
    ) else (
        echo # Répertoire d'archive des fichiers d'initialisation > "%PROJECT_ROOT%\.gitignore"
        echo .init_archive/ >> "%PROJECT_ROOT%\.gitignore"
        echo %GREEN%Fichier .gitignore créé avec le répertoire d'archive%NC%
    )
)

REM Créer un script de remplacement minimal pour init_project.sh/bat
echo #!/bin/bash > "%PROJECT_ROOT%\init_project.sh"
echo echo "Ce script a déjà été exécuté et les fichiers d'initialisation ont été supprimés." >> "%PROJECT_ROOT%\init_project.sh"
echo echo "Si vous devez réinitialiser le projet, veuillez vous référer à la documentation dans le dossier docs/." >> "%PROJECT_ROOT%\init_project.sh"
echo exit 0 >> "%PROJECT_ROOT%\init_project.sh"

REM Version Windows
echo @echo off > "%PROJECT_ROOT%\init_project.bat"
echo echo Ce script a déjà été exécuté et les fichiers d'initialisation ont été supprimés. >> "%PROJECT_ROOT%\init_project.bat"
echo echo Si vous devez réinitialiser le projet, veuillez vous référer à la documentation dans le dossier docs/. >> "%PROJECT_ROOT%\init_project.bat"
echo exit /b 0 >> "%PROJECT_ROOT%\init_project.bat"

echo %GREEN%Scripts d'initialisation remplacés par des versions minimales%NC%

REM Proposer de committer les changements
echo.
set /p COMMIT_CHOICE=Voulez-vous committer ces changements ? (O/N) 
if /i "%COMMIT_CHOICE%"=="O" (
    git add -A
    git commit -m "🧹 Nettoyage des fichiers d'initialisation"
    echo %GREEN%Changements commités%NC%
)

echo.
echo %BLUE%===============================================%NC%
echo %BLUE%  NETTOYAGE TERMINÉ AVEC SUCCÈS               %NC%
echo %BLUE%===============================================%NC%
echo.
if "%ARCHIVE%"=="true" (
    echo Les fichiers d'initialisation ont été archivés dans %YELLOW%%ARCHIVE_DIR%%NC%
    echo Vous pouvez supprimer ce répertoire ultérieurement si vous n'en avez plus besoin.
) else (
    echo Les fichiers d'initialisation ont été supprimés.
)
echo Des versions minimales des scripts ont été laissées en place pour informer les futurs utilisateurs.
echo.