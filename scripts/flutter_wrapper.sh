#!/bin/bash
# Script wrapper pour exécuter Flutter avec la bonne architecture sur les Mac avec Apple Silicon

# Déterminer si nous sommes sur un Mac avec Apple Silicon
if [[ "$OSTYPE" == "darwin"* ]] && [[ $(uname -m) == "arm64" ]]; then
    # Vérifier si l'utilisateur a demandé explicitement d'utiliser l'architecture native
    if [ "$FLUTTER_FORCE_NATIVE" = "1" ]; then
        # Utiliser l'architecture ARM native
        echo "Exécution de Flutter en mode natif ARM64..."
        flutter "$@"
    else
        # Utiliser Rosetta 2 pour la compatibilité
        echo "Exécution de Flutter via Rosetta 2 (x86_64)..."
        arch -x86_64 flutter "$@"
    fi
else
    # Sur les autres systèmes, exécuter Flutter normalement
    flutter "$@"
fi