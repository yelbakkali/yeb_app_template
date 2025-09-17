<!--
RÉFÉRENCES CROISÉES:
- Ce fichier est référencé dans: [docs/installation.md:110]
- Ce fichier est référencé dans: [scripts/setup_wsl.sh:143]
-->

# Optimisation de VS Code pour WSL

Ce document décrit un problème connu avec VS Code lors de son utilisation dans un environnement WSL (Windows Subsystem for Linux) et présente la solution implémentée dans ce template.

## Problème des redirections de ports dans VS Code avec WSL

Lors de l'utilisation de VS Code avec l'extension Remote-WSL, un problème récurrent peut survenir : à chaque redémarrage de VS Code, de nouvelles redirections de ports sont créées sans que les anciennes ne soient nettoyées. Avec le temps, ces redirections s'accumulent (parfois jusqu'à 40 ou 50 redirections), ce qui peut entraîner :

- Des ralentissements lors du démarrage de VS Code
- Des erreurs de connexion entre Windows et WSL
- Des conflits de ports
- Une utilisation excessive de ressources système

## Solution : Lanceur VS Code optimisé pour WSL

Ce template inclut un script spécial qui nettoie les redirections de ports existantes avant de lancer VS Code, évitant ainsi l'accumulation des redirections :

```bash
scripts/start_vscode_wsl.sh
```

### Fonctionnement du script

Le script effectue les opérations suivantes :

1. Vérifie que l'environnement est bien WSL
2. Arrête les processus VSCode-WSL existants qui pourraient causer des problèmes
3. Réinitialise toutes les redirections de ports via PowerShell
4. Lance VS Code avec des paramètres optimisés pour l'environnement WSL

### Utilisation

Lors de l'installation du template via le script `template/utils/setup_wsl.sh`, un alias `code-wsl` est automatiquement ajouté à votre profil bash. Pour l'utiliser :

```bash
# Pour ouvrir VS Code dans le répertoire courant
code-wsl

# Pour ouvrir VS Code avec un fichier ou dossier spécifique
code-wsl chemin/vers/dossier
```

Si l'alias n'est pas disponible, vous pouvez toujours utiliser le script directement :

```bash
/chemin/vers/votre/projet/scripts/start_vscode_wsl.sh
```

### Intégration dans VS Code

Une tâche VS Code a également été ajoutée pour faciliter l'accès au lanceur optimisé. Vous pouvez l'exécuter depuis la palette de commandes de VS Code (Ctrl+Shift+P) en cherchant "Tasks: Run Task" puis en sélectionnant "Optimized VS Code Launch (WSL)".

## Pourquoi cette approche ?

Cette solution a été choisie car elle :

1. Résout efficacement le problème d'accumulation des redirections de ports
2. N'interfère pas avec le fonctionnement normal de VS Code
3. S'intègre de manière transparente au flux de travail de développement
4. Est automatiquement configurée lors de l'installation du projet

## Dépannage

Si vous rencontrez toujours des problèmes de connexion après avoir utilisé le lanceur optimisé :

1. Fermez complètement VS Code (y compris les instances en arrière-plan)
2. Redémarrez le service WSL : `wsl --shutdown` puis relancez votre distribution
3. Utilisez à nouveau la commande `code-wsl` pour lancer VS Code

Pour plus d'informations sur le développement avec WSL, consultez la [documentation officielle de VS Code](https://code.visualstudio.com/docs/remote/wsl).
