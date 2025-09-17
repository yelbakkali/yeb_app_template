#!/bin/bash

# ==========================================================================
# RÉFÉRENCES CROISÉES:
# ==========================================================================

# Script pour lancer VS Code avec des options optimisées pour WSL
# Ce script permet de lancer VS Code en limitant les problèmes de redirection de ports

# Vérifier si nous sommes dans un environnement WSL
if ! grep -q "WSL" /proc/version; then
    echo "Ce script ne fonctionne que dans un environnement WSL"
    exit 1
fi

# Récupérer le nom de distribution WSL
DISTRO_NAME=$(wslpath -w / | cut -d'\' -f3)

# Nettoyer les anciennes connexions avant de démarrer
echo "Nettoyage des anciennes connexions VSCode-WSL..."
powershell.exe -Command "Get-Process | Where-Object {\$_.Name -like '*wsl*' -and \$_.Name -notlike '*wslservice*'} | Stop-Process -Force" || true
powershell.exe -Command "netsh interface portproxy reset" || true

# Détecter le chemin du répertoire actuel
CURRENT_DIR=$(pwd)
WINDOWS_PATH=$(wslpath -w "$CURRENT_DIR")

echo "Lancement de VS Code avec des paramètres optimisés..."

# Lancer VS Code avec des options optimisées
cmd.exe /C "code --disable-gpu --remote wsl+$DISTRO_NAME \"$WINDOWS_PATH\""

echo "VS Code a été lancé avec des paramètres optimisés pour WSL."
