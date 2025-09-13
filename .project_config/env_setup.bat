@echo off
REM Configuration des chemins et de l'environnement du projet
REM Ce fichier est chargé automatiquement par les scripts de développement

REM Obtenir le répertoire du script
set "SCRIPT_DIR=%~dp0"
set "PROJECT_ROOT=%SCRIPT_DIR%.."

REM Charger les informations du projet
if exist "%PROJECT_ROOT%\.project_config\project_info.bat" (
    call "%PROJECT_ROOT%\.project_config\project_info.bat"
)

REM Ajouter les répertoires bin au PATH
set "PATH=%PROJECT_ROOT%\bin;%PATH%"

REM Configuration spécifique à Windows
set "PATH=%USERPROFILE%\.poetry\bin;%PATH%"

REM Détecter et configurer les chemins des environnements virtuels
where poetry >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    REM Pour le backend web
    if exist "%PROJECT_ROOT%\web_backend" (
        for /f "tokens=*" %%i in ('cd "%PROJECT_ROOT%\web_backend" ^& poetry env info --path 2^>nul') do set "WEB_BACKEND_VENV=%%i"
        if defined WEB_BACKEND_VENV (
            if exist "%WEB_BACKEND_VENV%" (
                set "PATH=%WEB_BACKEND_VENV%\Scripts;%PATH%"
            )
        )
    )
    
    REM Pour le backend Python
    if exist "%PROJECT_ROOT%\python_backend" (
        for /f "tokens=*" %%i in ('cd "%PROJECT_ROOT%\python_backend" ^& poetry env info --path 2^>nul') do set "PYTHON_BACKEND_VENV=%%i"
        if defined PYTHON_BACKEND_VENV (
            if exist "%PYTHON_BACKEND_VENV%" (
                set "PATH=%PYTHON_BACKEND_VENV%\Scripts;%PATH%"
            )
        )
    )
)

REM Afficher un message sur la configuration
echo Environnement du projet configure avec succes
echo Projet: %PROJECT_NAME%
echo Plateforme: Windows