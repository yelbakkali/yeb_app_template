"""
Module principal de calculs pour 737calcs.
Ce fichier est utilisé par toutes les plateformes (Android, iOS, Windows, Web).
"""

def calcul_simple(a, b):
    """Effectue un calcul simple entre deux nombres."""
    return {
        'somme': a + b,
        'différence': a - b,
        'produit': a * b,
        'quotient': a / b if b != 0 else 'Division par zéro'
    }

def main(*args):
    """
    Fonction principale appelée par toutes les plateformes.
    Gère différents formats d'arguments selon la plateforme d'appel.
    
    Pour Android/iOS: args sont des paramètres directs
    Pour Windows: args vient de sys.argv (après le nom du script)
    Pour Web API: args sont des paramètres JSON désérialisés
    """
    try:
        # Si on a au moins 2 arguments, tenter de les convertir en nombres
        if len(args) >= 2:
            # Convertir les 2 premiers arguments en flottants
            a = float(args[0])
            b = float(args[1])
            return calcul_simple(a, b)
        else:
            # Pas assez d'arguments
            return {'erreur': 'Arguments insuffisants. Format attendu: a b'}
    except ValueError:
        # Erreur de conversion
        return {'erreur': 'Arguments invalides. Veuillez fournir des nombres.'}
    except Exception as e:
        # Autre erreur
        return {'erreur': str(e)}
