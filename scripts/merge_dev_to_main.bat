@echo off
REM Script d'automatisation pour merger la branche dev vers main
REM Ce script est destiné à l'utilisateur final du projet

REM Couleurs pour l'affichage
set "GREEN=[92m"
set "YELLOW=[93m"
set "RED=[91m"
set "BLUE=[94m"
set "NC=[0m"

echo %BLUE%===============================================%NC%
echo %BLUE%  FUSION DE LA BRANCHE DEV VERS MAIN          %NC%
echo %BLUE%===============================================%NC%

REM Fonction pour demander une confirmation
:confirmation
set /p choice=%~1 (O/N) 
if /i "%choice%"=="O" exit /b 0
if /i "%choice%"=="o" exit /b 0
exit /b 1

echo.
echo %GREEN%1. Vérification de l'état actuel%NC%
REM Vérifier qu'on est sur la branche dev
for /f "tokens=*" %%a in ('git branch --show-current') do set current_branch=%%a
if not "%current_branch%"=="dev" (
    echo %YELLOW%Vous n'êtes pas sur la branche dev (branche actuelle : %current_branch%).%NC%
    call :confirmation "Voulez-vous passer à la branche dev ?"
    if not errorlevel 1 (
        git checkout dev || (
            echo %RED%Échec du passage à la branche dev.%NC%
            exit /b 1
        )
    ) else (
        exit /b 0
    )
)

REM Vérifier qu'il n'y a pas de modifications non commitées
git status --porcelain > nul
if not errorlevel 1 (
    echo %YELLOW%Il y a des modifications non commitées.%NC%
    git status
    call :confirmation "Voulez-vous committer ces modifications avant de continuer ?"
    if not errorlevel 1 (
        echo Entrez un message de commit :
        set /p commit_message=
        git add .
        git commit -m "%commit_message%"
    ) else (
        echo %RED%Veuillez commiter ou stasher vos modifications d'abord.%NC%
        exit /b 1
    )
)

echo.
echo %GREEN%2. Mise à jour de la branche dev%NC%
echo Récupération des dernières modifications...
git pull origin dev
if errorlevel 1 (
    echo %YELLOW%Il pourrait y avoir des conflits avec le dépôt distant.%NC%
    call :confirmation "Voulez-vous continuer quand même ?"
    if not errorlevel 1 (
        echo %YELLOW%Continuons sans mettre à jour depuis le dépôt distant.%NC%
    ) else (
        echo %RED%Fusion annulée. Veuillez résoudre les conflits avant de continuer.%NC%
        exit /b 1
    )
)

REM Vérification des tests si présents
if exist "tests\" goto run_tests
if exist "test\" goto run_tests
goto skip_tests

:run_tests
echo.
echo %GREEN%3. Exécution des tests%NC%
call :confirmation "Voulez-vous exécuter les tests avant de fusionner ?"
if errorlevel 1 goto skip_tests

REM Détection du type de projet pour exécuter les tests appropriés
if exist "pubspec.yaml" (
    echo Exécution des tests Flutter...
    call flutter test
    if errorlevel 1 (
        echo %RED%Les tests ont échoué.%NC%
        call :confirmation "Voulez-vous continuer malgré les erreurs de test ?"
        if errorlevel 1 (
            echo %RED%Fusion annulée. Veuillez corriger les tests avant de continuer.%NC%
            exit /b 1
        )
        echo %YELLOW%Continuons malgré les erreurs de test.%NC%
    )
) else if exist "package.json" (
    echo Exécution des tests Node.js...
    call npm test
    if errorlevel 1 (
        echo %RED%Les tests ont échoué.%NC%
        call :confirmation "Voulez-vous continuer malgré les erreurs de test ?"
        if errorlevel 1 (
            echo %RED%Fusion annulée. Veuillez corriger les tests avant de continuer.%NC%
            exit /b 1
        )
        echo %YELLOW%Continuons malgré les erreurs de test.%NC%
    )
) else if exist "pyproject.toml" (
    echo Exécution des tests Python...
    where pytest >nul 2>&1
    if not errorlevel 1 (
        call pytest
        if errorlevel 1 (
            echo %RED%Les tests ont échoué.%NC%
            call :confirmation "Voulez-vous continuer malgré les erreurs de test ?"
            if errorlevel 1 (
                echo %RED%Fusion annulée. Veuillez corriger les tests avant de continuer.%NC%
                exit /b 1
            )
            echo %YELLOW%Continuons malgré les erreurs de test.%NC%
        )
    ) else (
        echo %YELLOW%Pytest non trouvé. Skipping des tests Python.%NC%
    )
) else (
    echo %YELLOW%Aucun framework de test reconnu. Skipping des tests.%NC%
)

:skip_tests
echo.
echo %GREEN%4. Fusion vers main%NC%
echo Passage à la branche main...
git checkout main
if errorlevel 1 (
    echo %RED%Échec du passage à la branche main.%NC%
    exit /b 1
)

echo Récupération des dernières modifications de main...
git pull origin main
if errorlevel 1 (
    echo %YELLOW%Warning: Impossible de mettre à jour main depuis l'origine.%NC%
)

echo.
echo %GREEN%5. Merge de dev vers main%NC%
echo Fusion de la branche dev dans main...
git merge dev
if errorlevel 1 (
    echo %RED%Conflit de fusion !%NC%
    echo Veuillez résoudre les conflits, puis exécutez les commandes suivantes :
    echo git add .
    echo git commit -m "Résolution des conflits de fusion"
    echo git push origin main
    echo git checkout dev
    exit /b 1
)

echo.
echo %GREEN%6. Push vers le dépôt distant%NC%
call :confirmation "Voulez-vous pousser les modifications vers la branche main distante ?"
if not errorlevel 1 (
    git push origin main
    if errorlevel 1 (
        echo %RED%Échec du push vers main.%NC%
        exit /b 1
    )
    echo %GREEN%Push vers main réussi !%NC%
) else (
    echo %YELLOW%Les changements n'ont pas été poussés.%NC%
    echo Vous pouvez les pousser plus tard avec: git push origin main
)

echo.
echo %GREEN%7. Retour à la branche dev%NC%
git checkout dev
if errorlevel 1 (
    echo %RED%Échec du retour à la branche dev.%NC%
    exit /b 1
)

echo.
echo %BLUE%===============================================%NC%
echo %BLUE%  FUSION TERMINÉE AVEC SUCCÈS                 %NC%
echo %BLUE%===============================================%NC%
echo.
echo Branche actuelle: %YELLOW%%current_branch%%NC%
echo La branche %YELLOW%main%NC% a été mise à jour avec le contenu de %YELLOW%dev%NC%
echo.