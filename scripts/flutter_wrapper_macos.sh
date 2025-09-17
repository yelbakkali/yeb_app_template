#!/bin/bash

# ==========================================================================
# RÉFÉRENCES CROISÉES:
# - Ce fichier est référencé dans: [docs/script_organization.md:16]
# - Ce fichier est référencé dans: [template/entry-points/setup_project.sh:135, 136, 137, 144]
#
# Note sur l'utilisation pendant le développement:
# Ce script n'est pas directement référencé dans les scripts de développement
# mais est utilisé de manière transparente lorsque la commande 'flutter' est
# appelée, si l'utilisateur a ajouté le lien symbolique bin/flutter à son PATH
# pendant l'initialisation du projet. Les commandes comme celles dans run_dev.sh:63
# utilisent ce wrapper implicitement si le PATH est configuré correctement.
# ==========================================================================

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
