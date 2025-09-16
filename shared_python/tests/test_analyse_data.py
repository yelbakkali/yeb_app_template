"""
Tests simples pour le module analyse_data.
"""
import sys
import os

# Ajouter le chemin parent au sys.path pour pouvoir importer les modules depuis scripts
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from scripts.analyse_data import analyser_donnees, main

def test_analyser_donnees():
    """Teste la fonction analyser_donnees avec des données simples."""
    result = analyser_donnees("10, 20, 30, 40, 50")
    
    assert 'moyenne' in result
    assert result['moyenne'] == 30.0
    assert result['médiane'] == 30.0
    assert result['min'] == 10.0
    assert result['max'] == 50.0
    assert result['somme'] == 150.0
    assert result['nombre'] == 5

def test_analyser_donnees_valeurs_negatives():
    """Teste la fonction analyser_donnees avec des valeurs négatives."""
    result = analyser_donnees("-10, -5, 0, 5, 10")
    
    assert result['moyenne'] == 0.0
    assert result['médiane'] == 0.0
    assert result['min'] == -10.0
    assert result['max'] == 10.0

def test_main_avec_arguments_valides():
    """Teste la fonction main avec des arguments valides."""
    result = main("10, 20, 30, 40, 50")
    
    assert 'moyenne' in result
    assert result['moyenne'] == 30.0

def test_main_sans_arguments():
    """Teste la fonction main sans arguments."""
    result = main()
    
    assert 'erreur' in result