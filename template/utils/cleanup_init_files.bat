@echo off
:: ==========================================================================
:: RÉFÉRENCES CROISÉES:
:: - Ce fichier est référencé dans: [template/init_project.bat:348, 350]
:: - Ce fichier est référencé dans: [init_project.bat:348, 350]
:: - Ce fichier est référencé dans: [init_project.sh:6]
:: ==========================================================================

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
set "ARCHIVE_DIRECTORY=%PROJECT_ROOT%\archived_init_files"
if not exist "%ARCHIVE_DIRECTORY%" mkdir "%ARCHIVE_DIRECTORY%"

echo %YELLOW%Voulez-vous supprimer les fichiers définitivement ou les archiver ?%NC%
echo 1) Supprimer définitivement
echo 2) Archiver dans %ARCHIVE_DIRECTORY%
set /p ACTION_CHOICE=Choisissez une option (1/2, défaut: 2): 

if "%ACTION_CHOICE%"=="1" (
    set "ACTION=delete"
    echo Les fichiers seront supprimés définitivement.
) else (
    set "ACTION=archive"
    echo Les fichiers seront archivés dans %ARCHIVE_DIRECTORY%.
)

REM Liste des fichiers à nettoyer
set FILES_TO_CLEAN=^
bootstrap.sh ^
init_project.sh ^
init_project.bat ^
setup_project.sh ^
setup_project.bat

REM Traiter chaque fichier de la liste
echo %BLUE%===============================================%NC%
echo %BLUE%      DÉBUT DU NETTOYAGE DES FICHIERS         %NC%
echo %BLUE%===============================================%NC%
echo.

for %%f in (%FILES_TO_CLEAN%) do (
    call :process_file "%%f"
)

REM Gérer le répertoire template/ séparément
if exist "template\" (
    if "%ACTION%"=="delete" (
        echo %RED%Suppression du répertoire template/%NC%
        rmdir /s /q "template\"
    ) else (
        echo %BLUE%Archivage du répertoire template/ vers %ARCHIVE_DIRECTORY%\template%NC%
        xcopy "template\" "%ARCHIVE_DIRECTORY%\template\" /E /I /H /Y
        rmdir /s /q "template\"
    )
)

REM Nettoyer également ce script lui-même et les scripts associés
set INIT_SCRIPTS=^
scripts\cleanup_init_files.sh ^
scripts\cleanup_init_files.bat

echo.
echo %YELLOW%Le nettoyage des fichiers d'initialisation est terminé.%NC%
echo %YELLOW%Ce script et ses associés peuvent également être supprimés.%NC%
set /p CLEAN_SCRIPTS=Voulez-vous nettoyer ces scripts maintenant ? (O/N) 

if /i "%CLEAN_SCRIPTS%"=="O" (
    for %%f in (%INIT_SCRIPTS%) do (
        call :process_file "%%f"
    )
    echo %GREEN%Nettoyage complet des fichiers d'initialisation terminé.%NC%
) else (
    echo %YELLOW%Les scripts de nettoyage suivants ont été conservés :%NC%
    for %%f in (%INIT_SCRIPTS%) do (
        if exist "%%f" echo - %%f
    )
    echo %YELLOW%Vous pouvez les supprimer manuellement plus tard.%NC%
)

echo.
echo %GREEN%===============================================%NC%
echo %GREEN%  NETTOYAGE DES FICHIERS TERMINÉ AVEC SUCCÈS  %NC%
echo %GREEN%===============================================%NC%

exit /b 0

:process_file
set "file=%~1"
if not exist "%file%" (
    echo %YELLOW%Le fichier/répertoire '%file%' n'existe pas.%NC%
    exit /b
)

if "%ACTION%"=="delete" (
    if exist "%file%\" (
        echo %RED%Suppression du répertoire %file%%NC%
        rmdir /s /q "%file%"
    ) else (
        echo %RED%Suppression du fichier %file%%NC%
        del /f /q "%file%"
    )
) else (
    for %%I in ("%file%") do set "filename=%%~nxI"
    if exist "%file%\" (
        echo %BLUE%Archivage du répertoire %file% vers %ARCHIVE_DIRECTORY%\%filename%%NC%
        xcopy "%file%" "%ARCHIVE_DIRECTORY%\%filename%\" /E /I /H /Y
        rmdir /s /q "%file%"
    ) else (
        echo %BLUE%Archivage du fichier %file% vers %ARCHIVE_DIRECTORY%\%filename%%NC%
        copy "%file%" "%ARCHIVE_DIRECTORY%\%filename%" > nul
        del /f /q "%file%"
    )
)
exit /b