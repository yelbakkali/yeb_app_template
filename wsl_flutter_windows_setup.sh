#!/bin/bash
# Script pour configurer l'environnement WSL pour le développement Flutter Windows

echo "Configuration de l'environnement Flutter pour le développement Windows dans WSL..."

# 1. Vérifier si les variables d'environnement nécessaires sont déjà configurées
if grep -q "WINDOWS_USERNAME" ~/.bashrc; then
    echo "La configuration semble déjà présente dans .bashrc"
else
    # 2. Déterminer le nom d'utilisateur Windows
    WINDOWS_USER=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')
    
    # 3. Ajouter les variables d'environnement et chemins nécessaires
    cat >> ~/.bashrc << EOL

# Configuration Flutter pour Windows dans WSL
export WINDOWS_USERNAME="${WINDOWS_USER}"
export WINDOWS_HOME="/mnt/c/Users/\${WINDOWS_USERNAME}"

# Permettre d'accéder aux outils Visual Studio depuis WSL
export PATH="\$PATH:/mnt/c/Program Files/Microsoft Visual Studio/2022/Community/VC/Tools/MSVC/14.32.31326/bin/Hostx64/x64"
export PATH="\$PATH:/mnt/c/Program Files (x86)/Windows Kits/10/bin/10.0.19041.0/x64"
export PATH="\$PATH:/mnt/c/Program Files (x86)/Microsoft Visual Studio/2022/BuildTools/MSBuild/Current/Bin"

# Configuration pour CMake
export CMAKE_PREFIX_PATH="\$WINDOWS_HOME/vcpkg/installed/x64-windows"
EOL

    echo "Configuration ajoutée au fichier .bashrc"
    echo "Veuillez redémarrer votre terminal ou exécuter 'source ~/.bashrc' pour appliquer les changements"
fi

echo ""
echo "NOTE IMPORTANTE : Cette configuration est expérimentale."
echo "La méthode recommandée est d'installer Flutter dans Windows et d'utiliser"
echo "VS Code avec Remote-WSL pour éditer votre code dans WSL."
echo ""
