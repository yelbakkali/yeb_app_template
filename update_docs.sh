#!/bin/bash

# Vérification du statut actuel
echo "Vérification du statut Git actuel..."
git status

# Ajout des nouveaux fichiers de documentation
echo "Ajout des fichiers de documentation..."
git add docs/project_structure.md
git add docs/installation.md
git add docs/contributing.md
git add docs/roadmap.md
git add CONTRIBUTORS.md
git add README.md.new

# Commit des changements
echo "Création du commit..."
git commit -m "Amélioration de la documentation du projet

- Ajout d'une documentation de structure du projet
- Ajout d'un guide d'installation détaillé
- Ajout d'un guide de contribution
- Ajout d'une feuille de route (roadmap) du projet
- Création d'un fichier CONTRIBUTORS.md
- Préparation d'une version améliorée du README.md"

# Renommer le README.md
echo "Mise à jour du README.md..."
mv README.md.new README.md
git add README.md
git commit -m "Mise à jour du README.md avec une documentation plus complète"

# Push des changements (à décommenter si nécessaire)
echo "Pour pousser les changements sur le dépôt distant, exécutez :"
echo "git push origin votre-branche"

echo "Terminé !"
