"""
Tests pour le module calcul_demo.
"""
import pytest
import sys
import os

# Assurez-vous que le module parent est dans le chemin d'importation
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

# Import le module à tester
from scripts import calcul_demo

def test_calcul_simple():
    """Test de la fonction calcul_simple."""
    # Test avec des valeurs positives
    resultat = calcul_demo.calcul_simple(10, 5)
    assert resultat['somme'] == 15
    assert resultat['différence'] == 5
    assert resultat['produit'] == 50
    assert resultat['quotient'] == 2.0

    # Test avec des valeurs négatives
    resultat = calcul_demo.calcul_simple(-10, 5)
    assert resultat['somme'] == -5
    assert resultat['différence'] == -15
    assert resultat['produit'] == -50
    assert resultat['quotient'] == -2.0

    # Test avec zéro
    resultat = calcul_demo.calcul_simple(10, 0)
    assert resultat['somme'] == 10
    assert resultat['différence'] == 10
    assert resultat['produit'] == 0
    assert resultat['quotient'] == 'Division par zéro'

def test_main_function_valide():
    """Test de la fonction principale avec des arguments valides."""
    # Test avec des arguments numériques
    resultat = calcul_demo.main("10", "5")
    assert resultat['somme'] == 15
    assert resultat['différence'] == 5
    assert resultat['produit'] == 50
    assert resultat['quotient'] == 2.0

def test_main_function_erreurs():
    """Test de la fonction principale avec des erreurs."""
    # Test avec un nombre insuffisant d'arguments
    resultat = calcul_demo.main("10")
    assert 'erreur' in resultat

    # Test avec des arguments non numériques
    resultat = calcul_demo.main("dix", "cinq")
    assert 'erreur' in resultat

def test_main_function_types():
    """Test de la fonction principale avec différents types d'arguments."""
    # Test avec des entiers
    resultat = calcul_demo.main(10, 5)
    assert resultat['somme'] == 15

    # Test avec des flottants
    resultat = calcul_demo.main(10.5, 5.5)
    assert resultat['somme'] == 16.0

    # Test avec une combinaison
    resultat = calcul_demo.main(10, 5.5)
    assert resultat['somme'] == 15.5
