@echo off
:: ==========================================================================
:: RÉFÉRENCES CROISÉES:
:: - Ce fichier est référencé dans: [template/init_project.bat:29]
:: - Ce fichier est référencé dans: [template/setup_project.bat:40]
:: ==========================================================================

REM Script de vérification et d'installation des prérequis pour le template yeb_app_template
REM Ce script détecte et suggère l'installation des outils nécessaires pour le projet

REM Couleurs pour les messages (Windows)
set "RED=[91m"
set "GREEN=[92m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "NC=[0m"

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