"""
Module utilitaire pour la gestion de la base de données SQLite.
Ce module fournit une classe de base pour ouvrir, lire et écrire dans une base SQLite.
Aucune fonction métier n'est encore implémentée.
"""
import sqlite3
from typing import Optional

class SQLiteManager:
    def __init__(self, db_path: str):
        self.db_path = db_path
        self.connection: Optional[sqlite3.Connection] = None

    def connect(self):
        if self.connection is None:
            self.connection = sqlite3.connect(self.db_path)

    def close(self):
        if self.connection:
            self.connection.close()
            self.connection = None

    def get_connection(self) -> sqlite3.Connection:
        if self.connection is None:
            self.connect()
        return self.connection

# À compléter avec des méthodes de lecture/écriture spécifiques selon les besoins.
