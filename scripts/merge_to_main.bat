@echo off
REM Script d'automatisation pour merger la branche dev vers main (version Windows)
REM Ce script respecte les règles définies dans docs/copilot/methodologie_temp.md
REM Il ne doit jamais être inclus dans la branche main

setlocal enabledelayedexpansion

REM Couleurs pour l'affichage (Windows 10+)
set "YELLOW=[33m"
set "GREEN=[32m"
set "RED=[31m"
set "NC=[0m"

echo %YELLOW%===============================================%NC%
echo %YELLOW%  FUSION AUTOMATIQUE DE DEV VERS MAIN          %NC%
echo %YELLOW%===============================================%NC%

echo.
echo %GREEN%1. Vérification de l'état actuel%NC%
REM Vérifier qu'on est sur la branche dev
for /f "tokens=*" %%a in ('git branch --show-current') do set current_branch=%%a
if NOT "%current_branch%" == "dev" (
  echo %RED%Erreur: Vous n'êtes pas sur la branche dev!%NC%
  echo Passage à la branche dev...
  git checkout dev || (
    echo %RED%Échec du passage à la branche dev.%NC%
    exit /b 1
  )
)

REM Vérifier qu'il n'y a pas de modifications non commitées
git status --porcelain > temp_status.txt
for /f %%i in ("temp_status.txt") do set size=%%~zi
if %size% gtr 0 (
  echo %RED%Erreur: Il y a des modifications non commitées!%NC%
  echo Veuillez commiter ou stasher vos modifications d'abord.
  del temp_status.txt
  exit /b 1
)
del temp_status.txt

echo.
echo %GREEN%2. Mise à jour de la branche dev%NC%
git pull origin dev || (
  echo %RED%Échec de la mise à jour de la branche dev.%NC%
  exit /b 1
)

echo.
echo %GREEN%3. Création d'une branche temporaire%NC%
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (
  set mm=%%a
  set dd=%%b
  set yy=%%c
)
for /f "tokens=1-3 delims=:." %%a in ('time /t') do (
  set hh=%%a
  set min=%%b
)
set temp_branch=temp_merge_to_main_%yy%%mm%%dd%%hh%%min%
git checkout -b %temp_branch% || (
  echo %RED%Échec de la création de la branche temporaire.%NC%
  exit /b 1
)
echo Branche temporaire créée: %YELLOW%%temp_branch%%NC%

echo.
echo %GREEN%4. Exclusion des fichiers spécifiques au développement%NC%

REM Suppression de methodologie_temp.md
echo Suppression de methodologie_temp.md...
git rm -f .copilot/methodologie_temp.md 2>nul || echo %YELLOW%Note: methodologie_temp.md n'existe pas ou n'est pas suivi par Git.%NC%

REM Ne pas inclure ce script
echo Suppression de ce script d'automatisation...
git rm -f scripts/merge_to_main.bat 2>nul || echo %YELLOW%Note: Le script merge_to_main.bat n'est pas sous contrôle de version.%NC%

REM Vider chat_resume.md
echo Vidage de chat_resume.md...
echo # Résumé des sessions de travail avec GitHub Copilot > .copilot/chat_resume.md
echo. >> .copilot/chat_resume.md
echo Ce document résume les sessions de travail avec GitHub Copilot pour faciliter la reprise du contexte. >> .copilot/chat_resume.md
git add .copilot/chat_resume.md

REM Vider les fichiers de sessions
echo Vidage des fichiers de sessions...
for /r docs\copilot\sessions %%f in (*.md) do (
  set "filename=%%~nf"
  echo # Session !filename! > "%%f"
  git add "%%f"
)

echo.
echo %GREEN%5. Commit des modifications%NC%
git commit -m "Préparation de la fusion vers main - exclusion des fichiers de développement" || (
  echo %YELLOW%Aucun changement à commiter ou aucun fichier à exclure trouvé.%NC%
  echo Vérifiez si les fichiers à exclure existent déjà.
)

echo.
echo %GREEN%6. Fusion vers main%NC%
git checkout main || (
  echo %RED%Échec du passage à la branche main.%NC%
  exit /b 1
)
git pull origin main || (
  echo %RED%Échec de la mise à jour de la branche main.%NC%
  exit /b 1
)

echo.
echo %GREEN%7. Merge de la branche temporaire dans main%NC%
git merge %temp_branch% -m "Merge automatique de dev vers main" || (
  echo %RED%Conflit de fusion!%NC%
  echo Résolvez les conflits manuellement puis exécutez:
  echo git commit -m "Résolution des conflits de fusion"
  echo git push origin main
  echo git checkout dev
  echo git branch -D %temp_branch%
  exit /b 1
)

echo.
echo %GREEN%8. Vérification des fichiers exclus%NC%
git ls-tree -r main --name-only > temp_files.txt
findstr /c:".copilot/methodologie_temp.md" temp_files.txt >nul 2>&1
if not errorlevel 1 (
  echo %YELLOW%Attention: methodologie_temp.md est toujours présent dans main.%NC%
)

findstr /c:"scripts/merge_to_main.bat" temp_files.txt >nul 2>&1
if not errorlevel 1 (
  echo %YELLOW%Attention: Le script merge_to_main.bat est toujours présent dans main.%NC%
)
del temp_files.txt

echo.
echo %GREEN%9. Push vers le dépôt distant%NC%
git push origin main || (
  echo %RED%Échec du push vers main.%NC%
  exit /b 1
)
echo %GREEN%Push vers main réussi!%NC%

echo.
echo %GREEN%10. Nettoyage%NC%
git checkout dev || (
  echo %RED%Échec du retour à la branche dev.%NC%
  exit /b 1
)
echo Suppression de la branche temporaire %YELLOW%%temp_branch%%NC%...
git branch -D %temp_branch% || (
  echo %RED%Échec de la suppression de la branche temporaire.%NC%
  exit /b 1
)

echo.
echo %GREEN%===============================================%NC%
echo %GREEN%  FUSION TERMINÉE AVEC SUCCÈS                 %NC%
echo %GREEN%===============================================%NC%
echo.
for /f "tokens=*" %%a in ('git branch --show-current') do echo Branche actuelle: %YELLOW%%%a%NC%
echo La branche %YELLOW%main%NC% a été mise à jour avec le contenu de %YELLOW%dev%NC%
echo Les fichiers spécifiques au développement ont été exclus.
echo.

endlocal
