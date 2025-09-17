"""
Module d'analyse de données pour yeb_app_template.
Ce script démontre l'utilisation de pandas et numpy pour analyser des données.
"""

import pandas as pd
import numpy as np

def analyser_donnees(data_str):
    """Analyse une série de nombres séparés par des virgules."""
    try:
        # Convertir la chaîne en liste de nombres
        data = [float(x.strip()) for x in data_str.split(",")]

        # Créer un DataFrame pandas
        df = pd.DataFrame({"valeurs": data})

        # Calculer des statistiques
        stats = {
            "moyenne": df["valeurs"].mean(),
            "médiane": df["valeurs"].median(),
            "écart-type": df["valeurs"].std(),
            "min": df["valeurs"].min(),
            "max": df["valeurs"].max(),
            "somme": df["valeurs"].sum(),
            "nombre": len(df)
        }

        return stats
    except Exception as e:
        return {"erreur": str(e)}

def main(*args):
    """
    Fonction principale appelée par toutes les plateformes.

    Le premier argument doit être une chaîne contenant des nombres séparés par des virgules.
    Exemple: "1.5, 2.3, 5.7, 9.0, 11.2"
    """
    try:
        if len(args) < 1:
            return {"erreur": "Veuillez fournir une liste de nombres séparés par des virgules"}

        # Joindre tous les arguments en une seule chaîne au cas où ils seraient passés séparément
        data_str = ",".join([str(arg) for arg in args])

        return analyser_donnees(data_str)
    except Exception as e:
        return {"erreur": str(e)}

# Pour tester en exécution locale
if __name__ == "__main__":
    import sys
    if len(sys.argv) > 1:
        result = main(sys.argv[1])
    else:
        # Données de test par défaut
        result = main("10, 20, 30, 40, 50")

    print(result)
