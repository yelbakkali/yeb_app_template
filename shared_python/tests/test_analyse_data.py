"""
Tests pour le module analyse_data.
"""
import pytest
import sys
import os

# On n'a pas besoin d'importer pandas et numpy directement,
# ils sont utilisés par le module analyse_data

# Assurez-vous que le module parent est dans le chemin d'importation
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

# Import le module à tester
from scripts import analyse_data

def test_analyser_donnees_success():
    """Test de la fonction analyser_donnees avec des données valides."""
    # Chaîne de test avec des nombres valides
    data_str = "10, 20, 30, 40, 50"
    resultat = analyse_data.analyser_donnees(data_str)
    
    # Vérifier la présence de toutes les statistiques
    assert 'moyenne' in resultat
    assert 'médiane' in resultat
    assert 'écart-type' in resultat
    assert 'min' in resultat
    assert 'max' in resultat
    assert 'somme' in resultat
    assert 'nombre' in resultat
    
    # Vérifier les valeurs des statistiques
    assert resultat['moyenne'] == 30.0
    assert resultat['médiane'] == 30.0
    assert resultat['min'] == 10.0
    assert resultat['max'] == 50.0
    assert resultat['somme'] == 150.0
    assert resultat['nombre'] == 5
    assert abs(resultat['écart-type'] - 15.811388300841896) < 0.0001  # Comparaison approximative pour les flottants

def test_analyser_donnees_error():
    """Test de la fonction analyser_donnees avec des données invalides."""
    # Chaîne de test avec des valeurs non numériques
    data_str = "10, vingt, 30, quarante, 50"
    resultat = analyse_data.analyser_donnees(data_str)
    
    # Vérifier la présence de l'erreur
    assert 'erreur' in resultat

def test_main_function_success():
    """Test de la fonction main avec des arguments valides."""
    # Test avec une liste de nombres comme argument
    resultat = analyse_data.main("10,20,30,40,50")
    assert resultat['moyenne'] == 30.0
    assert resultat['nombre'] == 5
    
    # Test avec plusieurs arguments séparés
    resultat = analyse_data.main("10", "20", "30", "40", "50")
    assert resultat['moyenne'] == 30.0
    assert resultat['nombre'] == 5

def test_main_function_error():
    """Test de la fonction main avec des erreurs."""
    # Test sans arguments
    resultat = analyse_data.main()
    assert 'erreur' in resultat
    
    # Test avec des arguments invalides
    resultat = analyse_data.main("abc", "def")
    assert 'erreur' in resultat

def test_main_function_edge_cases():
    """Test de la fonction main avec des cas limites."""
    # Test avec un seul nombre
    resultat = analyse_data.main("42")
    assert resultat['moyenne'] == 42.0
    assert resultat['médiane'] == 42.0
    assert resultat['min'] == 42.0
    assert resultat['max'] == 42.0
    assert resultat['nombre'] == 1
    
    # Test avec des espaces supplémentaires
    resultat = analyse_data.main(" 10 , 20 , 30 ")
    assert resultat['nombre'] == 3
    assert resultat['moyenne'] == 20.0
