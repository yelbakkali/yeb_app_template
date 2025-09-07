"""
Script de calcul simple pour tester l'intégration Python portable sur Windows
"""

def calcul_simple(a, b):
    """Effectue un calcul simple entre deux nombres."""
    return {
        'somme': a + b,
        'différence': a - b,
        'produit': a * b,
        'quotient': a / b if b != 0 else 'Division par zéro'
    }

# Fonction principale appelée depuis Flutter
def main():
    import sys
    
    if len(sys.argv) < 3:
        print("{'erreur': 'Arguments insuffisants. Format attendu: a b'}")
        return
    
    try:
        a = float(sys.argv[1])
        b = float(sys.argv[2])
        result = calcul_simple(a, b)
        print(result)
    except ValueError:
        print("{'erreur': 'Arguments invalides. Veuillez fournir des nombres.'}")
    except Exception as e:
        print(f"{'erreur': '{str(e)}'}")

if __name__ == "__main__":
    main()
