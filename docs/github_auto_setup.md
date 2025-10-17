<!--
RÉFÉRENCES CROISÉES:
- Ce fichier documente la fonctionnalité de création automatique de dépôt GitHub
- Ajouté dans: [setup_template.sh:355-454]
-->

# Création automatique de dépôt GitHub

## Vue d'ensemble

Le script `setup_template.sh` inclut maintenant une fonctionnalité de création automatique de dépôt GitHub. Cette fonctionnalité utilise GitHub CLI (`gh`) pour créer et configurer automatiquement un dépôt distant lors de l'initialisation d'un nouveau projet.

## Prérequis

### Installation de GitHub CLI

**Ubuntu/Debian :**

```bash
sudo apt install gh
```

**macOS :**

```bash
brew install gh
```

**Autres systèmes :**

Consultez [https://cli.github.com/](https://cli.github.com/)

### Authentification


Avant d'utiliser cette fonctionnalité, vous devez être authentifié avec GitHub :

```bash
gh auth login
```

Suivez les instructions interactives pour :

1. Choisir GitHub.com ou GitHub Enterprise
2. Choisir HTTPS ou SSH
3. Vous authentifier via navigateur ou token

## Fonctionnement

### Flux automatique


Lorsque vous exécutez `setup_template.sh`, le script :

1. ✅ **Vérifie GitHub CLI**
   - Si `gh` n'est pas installé → affiche les instructions manuelles
   - Si `gh` est installé → continue

2. ✅ **Vérifie l'authentification**
   - Si non authentifié → propose de lancer `gh auth login`
   - Si authentifié → continue

3. ✅ **Demande confirmation**
   - Propose de créer le dépôt GitHub
   - L'utilisateur peut refuser et le faire manuellement plus tard

4. ✅ **Configure la visibilité**
   - Demande si le dépôt doit être public ou privé
   - Par défaut : public

5. ✅ **Crée le dépôt**
   - Utilise le nom du projet
   - Ajoute la description du projet
   - Configure le remote `origin`

6. ✅ **Pousse le code initial**
   - Renomme la branche en `main`
   - Pousse vers GitHub
   - Affiche l'URL du dépôt

### Exemple d'interaction

```text
==================================================================
 Configuration du dépôt GitHub
==================================================================
✓ Authentification GitHub vérifiée

Voulez-vous créer un dépôt GitHub pour mon_projet ? (o/N)
> o

Le dépôt doit-il être public ou privé ? (public/privé)
> public

ℹ Le dépôt sera public
ℹ Création du dépôt GitHub 'mon_projet'...
✓ Dépôt GitHub créé avec succès
ℹ Envoi du code initial vers GitHub...
✓ Code initial poussé vers GitHub

✨ Votre dépôt est disponible à :
   https://github.com/votre_username/mon_projet
```

## Cas d'utilisation

### Cas 1 : Création automatique réussie


Le workflow complet se déroule sans intervention :

```bash
# Exécuter le script
./setup_template.sh

# À l'étape 7, répondre :
# - "o" pour créer le dépôt
# - "public" ou "privé" pour la visibilité

# Le dépôt est créé et le code est poussé automatiquement
```

### Cas 2 : GitHub CLI non installé

Le script affiche des instructions manuelles :

```text
⚠ GitHub CLI (gh) n'est pas installé

Pour créer automatiquement un dépôt GitHub, installez GitHub CLI :
  https://cli.github.com/

Instructions pour créer le dépôt manuellement :

1. Allez sur https://github.com/new
2. Créez un nouveau dépôt nommé 'mon_projet'
3. N'initialisez PAS avec README, .gitignore ou licence (déjà présents)
4. Puis exécutez ces commandes :

   git remote add origin https://github.com/VOTRE_USERNAME/mon_projet.git
   git branch -M main
   git push -u origin main
```

### Cas 3 : Authentification manquante

Le script propose de lancer l'authentification :

```text
⚠ Vous n'êtes pas authentifié avec GitHub CLI

Pour vous authentifier, exécutez :
  gh auth login

Voulez-vous créer le dépôt GitHub manuellement plus tard ? (o/N)
> n

ℹ Lancement de l'authentification GitHub CLI...
```

### Cas 4 : Création reportée

L'utilisateur peut refuser et créer le dépôt plus tard :

```text
Voulez-vous créer un dépôt GitHub pour mon_projet ? (o/N)
> n

ℹ Création du dépôt GitHub ignorée

Pour créer le dépôt plus tard, exécutez :
  gh repo create mon_projet --public --source=. --push
```

## Commandes GitHub CLI utiles

### Créer un dépôt public


```bash
gh repo create mon_projet --public --source=. --push
```

### Créer un dépôt privé avec description


```bash
gh repo create mon_projet --private --source=. --description "Ma super application" --push
```

### Lister vos dépôts


```bash
gh repo list
```

### Voir les détails d'un dépôt


```bash
gh repo view
```

### Ouvrir le dépôt dans le navigateur


```bash
gh repo view --web
```

## Dépannage

### Erreur : "gh: command not found"

**Solution** : Installez GitHub CLI


```bash
# Ubuntu/Debian
sudo apt install gh

# macOS
brew install gh
```

### Erreur : "You are not logged into any GitHub hosts"

**Solution** : Authentifiez-vous


```bash
gh auth login
```

### Erreur : "Repository already exists"

**Solution** : Le dépôt existe déjà sur GitHub


```bash
# Option 1 : Utiliser un nom différent
# Renommez votre dossier de projet

# Option 2 : Supprimer le dépôt existant
gh repo delete OWNER/REPO --yes

# Option 3 : Ajouter le remote manuellement
git remote add origin https://github.com/OWNER/REPO.git
git push -u origin main
```

### Le push échoue

**Solution** : Vérifier les permissions et la branche


```bash
# Vérifier le remote
git remote -v

# Vérifier la branche
git branch

# Renommer la branche si nécessaire
git branch -M main

# Pousser manuellement
git push -u origin main
```

## Personnalisation

Si vous souhaitez modifier le comportement par défaut :

### Changer la visibilité par défaut


Éditez `setup_template.sh` ligne ~384 :

```bash
# Pour rendre privé par défaut
local visibility_flag="--private"
```

### Ajouter des paramètres supplémentaires

Consultez la documentation de `gh` :


```bash
gh repo create --help
```

Paramètres disponibles :

- `--add-readme` : Ajouter un README (non recommandé, déjà présent)
- `--homepage URL` : URL de la page d'accueil
- `--team TEAM` : Assigner à une équipe
- `--template REPO` : Utiliser un template
- `--enable-issues` : Activer les issues
- `--enable-wiki` : Activer le wiki

## Intégration dans le workflow

### Workflow complet recommandé


1. **Créer le dossier du projet**

   ```bash
   mkdir mon_projet
   cd mon_projet
   ```

2. **Télécharger et exécuter le script**

   ```bash
   curl -O https://raw.githubusercontent.com/yelbakkali/yeb_app_template/main/setup_template.sh
   chmod +x setup_template.sh
   ./setup_template.sh
   ```

3. **Suivre les étapes interactives**

   - Configuration du projet
   - Téléchargement du template
   - Personnalisation
   - **Création du dépôt GitHub** ← Nouvelle étape !

4. **Commencer à développer**

   ```bash
   git checkout -b dev
   # Développer...
   git add .
   git commit -m "Nouvelle fonctionnalité"
   git push origin dev
   ```

## Sécurité

### Bonnes pratiques


1. **Dépôts privés pour le code sensible**
   - Toujours choisir "privé" pour le code propriétaire
   - Vérifier les .gitignore avant le push

2. **Vérifier les secrets**
   - Ne jamais committer de clés API
   - Utiliser des variables d'environnement
   - Vérifier avec `git log` avant le push

3. **Permissions d'accès**
   - Configurer les collaborateurs sur GitHub
   - Utiliser les branch protection rules

### Révocation d'accès

Si vous devez révoquer l'accès de GitHub CLI :

```bash
gh auth logout
```

## Voir aussi

- [Documentation GitHub CLI](https://cli.github.com/manual/)
- [Guide Git du projet](git_workflow.md)
- [Guide d'installation](installation.md)
- [Configuration GitHub Actions](../github/workflows/)
