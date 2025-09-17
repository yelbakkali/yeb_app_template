# Gestion des connexions WSL dans VS Code

## Problème identifié

Lors de l'utilisation de VS Code avec WSL (Windows Subsystem for Linux), nous avons observé une accumulation excessive de redirections de ports. Ce problème se manifeste par :

- Une augmentation progressive du nombre de ports redirigés (jusqu'à 45 observés)
- Des ralentissements potentiels dans les performances de VS Code
- Des erreurs occasionnelles de connexion entre VS Code et l'environnement WSL

## Causes identifiées

1. **Création de nouvelles connexions à chaque redémarrage** : VS Code crée de nouvelles redirections de ports à chaque redémarrage sans nettoyer correctement les anciennes.
2. **Absence de mécanisme de nettoyage** : Les anciennes connexions ne sont pas automatiquement fermées, même après fermeture de VS Code.
3. **Accumulation sur le long terme** : Sans intervention manuelle, ces redirections s'accumulent au fil du temps.

## Solution mise en place : Script de lancement optimisé

Pour résoudre ce problème de manière simple et efficace, nous avons créé un script de lancement optimisé qui :

1. Nettoie automatiquement les anciennes redirections avant chaque démarrage de VS Code
2. Lance VS Code avec des paramètres optimisés pour WSL
3. Évite l'accumulation des redirections de ports

Le script `scripts/start_vscode_wsl.sh` :

```bash
#!/bin/bash

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
```

## Utilisation du script

Pour utiliser cette solution, exécutez simplement :

```bash
./scripts/start_vscode_wsl.sh
```

Ce script devrait être utilisé systématiquement pour démarrer VS Code dans l'environnement WSL au lieu d'utiliser la commande `code` directement ou de lancer VS Code depuis le menu Windows.

## Recommandations additionnelles

1. **Redémarrer VS Code régulièrement** : Si vous constatez des ralentissements, fermez complètement VS Code et relancez-le avec le script.
2. **Limiter les instances** : Évitez d'avoir plusieurs instances de VS Code connectées au même environnement WSL.
3. **Mise à jour régulière** : Maintenez VS Code et l'extension Remote-WSL à jour.

## Résolution de problèmes

Si vous continuez à rencontrer des problèmes malgré l'utilisation du script :

1. Fermez toutes les instances de VS Code
2. Exécutez manuellement dans PowerShell (ou via WSL) : `netsh interface portproxy reset`
3. Redémarrez votre environnement WSL avec la commande `wsl --shutdown`
4. Relancez votre distribution WSL et utilisez à nouveau le script pour démarrer VS Code
