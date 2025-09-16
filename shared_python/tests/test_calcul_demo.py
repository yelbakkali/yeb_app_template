"""
Tests simples pour le module calcul_demo.
"""
import sys
import os

# Ajouter le chemin parent au sys.path pour pouvoir importer les modules depuis scripts
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from scripts.calcul_demo import calcul_simple, main

def test_calcul_simple():
    """Teste la fonction calcul_simple avec des valeurs simples."""
    result = calcul_simple(10, 5)
    
    assert result['somme'] == 15
    assert result['différence'] == 5
    assert result['produit'] == 50
    assert result['quotient'] == 2.0

def test_calcul_simple_division_par_zero():
    """Teste la gestion de la division par zéro."""
    result = calcul_simple(10, 0)
    
    assert result['somme'] == 10
    assert result['différence'] == 10
    assert result['produit'] == 0
    assert result['quotient'] == 'Division par zéro'

def test_main_avec_arguments_valides():
    """Teste la fonction main avec des arguments valides."""
    result = main(10, 5)
    
    assert 'somme' in result
    assert result['somme'] == 15

def test_main_avec_arguments_invalides():
    """Teste la fonction main avec des arguments invalides."""
    result = main('a', 'b')
    
    assert 'erreur' in result