"""
Package partagé pour les scripts Python utilisés dans l'application Flutter.
Cette structure unifiée permet d'organiser les scripts Python en un seul endroit,
tout en les rendant accessibles sur toutes les plateformes (Android, iOS, Windows, Web).

Organisation:
- scripts/: Contient des scripts Python simples directement exécutables
- packages/: Contient des packages Python plus complexes
- web_adapter.py: Mini serveur pour le mode web intégré à l'application
"""

__version__ = "1.0.0"

# Faciliter l'import des scripts et packages
from . import scripts
from . import packages

# Exposer le démarrage du serveur web
try:
    from .web_adapter import start_server
except ImportError:
    # Les dépendances web ne sont pas installées
    def start_server(*args, **kwargs):
        raise ImportError("Les dépendances pour le mode web ne sont pas installées. "
                         "Installez-les avec: poetry install --extras web")
