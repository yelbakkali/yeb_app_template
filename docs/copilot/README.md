# Utilisation de GitHub Copilot avec ce projet

Ce document explique comment utiliser GitHub Copilot efficacement avec ce projet, et comment naviguer dans l'historique des sessions de collaboration.

## Introduction

Ce projet utilise un système structuré pour documenter les interactions avec GitHub Copilot. Cette approche permet de:
- Maintenir une continuité entre les sessions de travail
- Documenter les décisions techniques et leur justification
- Offrir un contexte clair pour les nouveaux contributeurs

## Structure de documentation

```
docs/
  ├── copilot/
  │   ├── sessions/               # Historique des sessions
  │   │   ├── session_DATE.md     # Une session par date
  │   │   └── template.md         # Template pour nouvelles sessions
  │   ├── instructions.md         # Instructions pour Copilot
  │   └── README.md               # Ce fichier
  └── chat_resume.md              # Résumé global du projet
```

## Comment démarrer une nouvelle session

1. Au début d'une nouvelle session avec GitHub Copilot, demandez-lui de "lire les fichiers dans docs/copilot"
2. L'assistant analysera ces fichiers et vous présentera un résumé de l'état actuel du projet
3. Vous pourrez alors continuer le travail là où il a été arrêté

## Bonnes pratiques

- Demandez à l'assistant de documenter les sessions importantes dans un nouveau fichier sous `docs/copilot/sessions/`
- Utilisez le format de validation proposé dans `instructions.md` pour les changements significatifs
- Consultez régulièrement le fichier `chat_resume.md` pour une vue d'ensemble du projet
