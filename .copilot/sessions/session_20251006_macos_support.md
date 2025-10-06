<!--
RÉFÉRENCES CROISÉES:
- Ce fichier est référencé dans: [.copilot/chat_resume.md:272]
-->

# Session du 6 octobre 2025: Support macOS pour le Template

## Contexte et objectifs

Cette session a été consacrée à l'amélioration de la compatibilité macOS pour le template d'application. L'utilisateur a signalé des problèmes d'installation sur macOS, notamment des erreurs "404:: command not found" et des problèmes liés aux répertoires non vides. L'objectif était de créer des scripts spécifiques pour macOS et de mettre en place un framework de test pour valider ces installations.

## Problèmes identifiés

1. **Différences de syntaxe `sed`** : Sur macOS, la commande `sed -i` requiert un argument vide (`sed -i ''`) contrairement à Linux où l'on utilise simplement `sed -i`.

2. **Détection de l'architecture** : Nécessité de détecter si l'ordinateur utilise une puce Apple Silicon (M1/M2) ou Intel pour configurer correctement le chemin Homebrew.

3. **Chemins d'installation spécifiques** : Les chemins d'installation pour Homebrew, Poetry, et Flutter diffèrent entre macOS et Linux/WSL.

4. **Support Xcode et iOS** : Configuration spécifique pour le développement iOS avec vérification de la présence de Xcode et installation de CocoaPods.

## Solutions mises en œuvre

1. **Scripts spécifiques à macOS** :
   - Création de `macos_setup.sh` pour l'initialisation du template
   - Création de `setup_macos.sh` pour l'installation des dépendances

2. **Adaptation de la syntaxe** :
   - Modification de toutes les commandes `sed` pour utiliser la syntaxe macOS (`sed -i ''`)
   - Ajustement des chemins pour les profils shell (utilisation de `~/.zprofile`)

3. **Détection d'architecture** :

   ```bash
   if [[ "$(uname -m)" == "arm64" ]]; then
       # Pour Apple Silicon (M1, M2...)
       eval "$(/opt/homebrew/bin/brew shellenv)"
   else
       # Pour Intel
       eval "$(/usr/local/bin/brew shellenv)"
   fi
   ```

4. **Framework de test d'installation** :
   - Création de `test_installation.sh` pour valider automatiquement l'installation
   - Tests pour vérifier la présence et le bon fonctionnement des dépendances

5. **Support iOS spécifique** :
   - Vérification de la présence de Xcode
   - Installation de CocoaPods via Ruby Gems
   - Création d'un wrapper pour faciliter le développement Flutter sur macOS

## Fichiers créés ou modifiés

1. `/home/yassine/yeb_app_template/macos_setup.sh`
2. `/home/yassine/yeb_app_template/template/utils/setup_macos.sh`
3. `/home/yassine/yeb_app_template/template/tests/test_installation.sh`
4. `/home/yassine/yeb_app_template/README.md` (mise à jour pour les instructions macOS)
5. `/home/yassine/yeb_app_template/docs/installation.md` (mise à jour pour les instructions macOS)

## Résultat et validation

Les scripts macOS ont été créés avec la syntaxe appropriée pour macOS, notamment pour les commandes `sed`. Le framework de test d'installation a été mis en place pour valider automatiquement que toutes les dépendances sont correctement installées et configurées. Ces changements devraient éliminer les problèmes d'installation précédemment rencontrés sur macOS.

## Prochaines étapes

1. Tester les scripts sur un véritable système macOS
2. Recueillir des retours d'utilisateurs macOS pour valider l'expérience d'installation
3. Continuer à améliorer la documentation pour les utilisateurs macOS
4. Envisager l'ajout de scripts d'automatisation supplémentaires spécifiques à macOS (par exemple, pour le déploiement sur l'App Store)

