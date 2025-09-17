@echo off
REM Script pour démarrer l'application en mode web avec le serveur Python intégré
REM Version Windows

echo Démarrage de l'environnement web intégré pour yeb_app_template...

REM Répertoire du projet (répertoire contenant ce script)
set PROJECT_DIR=%~dp0
cd %PROJECT_DIR%

REM Vérifier si Poetry est installé
where poetry >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Poetry n'est pas installé. Installation...
    powershell -Command "(Invoke-WebRequest -Uri https://install.python-poetry.org -UseBasicParsing).Content | python -"
)

REM Installer les dépendances avec l'extra web
echo Installation des dépendances Python pour le web...
cd shared_python
poetry install --extras web

REM Démarrer le serveur Python en arrière-plan
echo Démarrage du serveur Python...
start /b cmd /c "poetry run python -c "from web_adapter import start_server; start_server()""
set PYTHON_SERVER_PID=%ERRORLEVEL%

REM Attendre que le serveur soit prêt (3 secondes)
echo Attente du démarrage du serveur...
ping -n 4 127.0.0.1 >nul

REM Démarrer l'application Flutter en mode web
echo Démarrage de l'application Flutter en mode web...
cd %PROJECT_DIR%flutter_app
flutter run -d web-server

REM Arrêter le serveur Python lorsque Flutter se termine
taskkill /F /PID %PYTHON_SERVER_PID% 2>nul

echo Application terminée.