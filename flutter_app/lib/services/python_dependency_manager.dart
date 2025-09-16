import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
// Suppression de l'import non utilisé: package:path_provider/path_provider.dart
import 'package:process_run/process_run.dart';
import 'log_service.dart';

/// Gestionnaire des dépendances Python utilisant Poetry
class PythonDependencyManager {
  static const String _tag = 'PythonDependencyManager';
  String? _pythonScriptsPath;
  bool _isInitialized = false;
  final Set<String> _installedDependencies = {};

  /// Initialise le gestionnaire de dépendances Python
  Future<void> initialize(String pythonScriptsPath) async {
    if (_isInitialized) return;
    
    _pythonScriptsPath = pythonScriptsPath;
    LogService.info(_tag, 'Initialisation du gestionnaire de dépendances Python avec Poetry');
    
    // Vérifier si Poetry est disponible
    if (!kIsWeb) {
      try {
        await _verifyPoetryInstallation();
        _isInitialized = true;
        LogService.info(_tag, 'Poetry est disponible');
      } catch (e) {
        LogService.error(_tag, 'Poetry n\'est pas disponible: $e');
        rethrow;
      }
    } else {
      LogService.info(_tag, 'Environnement web détecté, installation des dépendances ignorée');
      _isInitialized = true;
    }
  }

  /// Vérifie si Poetry est installé
  Future<void> _verifyPoetryInstallation() async {
    try {
      final result = await _runPoetryCommand(['--version']);
      LogService.info(_tag, 'Poetry version: ${result.stdout}');
    } catch (e) {
      LogService.error(_tag, 'Erreur lors de la vérification de Poetry: $e');
      throw Exception('Poetry n\'est pas installé ou accessible');
    }
  }

  /// Exécute une commande Poetry
  Future<ProcessResult> _runPoetryCommand(List<String> arguments) async {
    if (_pythonScriptsPath == null) {
      throw Exception('Le chemin des scripts Python n\'est pas défini');
    }

    final shell = Shell(workingDirectory: _pythonScriptsPath);
    
    LogService.debug(_tag, 'Exécution de la commande Poetry: poetry ${arguments.join(' ')}');
    try {
      // Utilisation correcte de shell.run avec une commande et ses arguments
      final result = await shell.run('poetry ${arguments.join(' ')}');
      // Corriger la création de ProcessResult avec 4 arguments positionnels
      return ProcessResult(
        result.first.pid,
        result.first.exitCode,
        result.first.stdout.toString(),
        result.first.stderr.toString(), // 4ème argument positionnel pour stderr
      );
    } catch (e) {
      LogService.error(_tag, 'Erreur lors de l\'exécution de la commande Poetry: $e');
      rethrow;
    }
  }

  /// Installe les dépendances spécifiées dans le fichier pyproject.toml
  Future<bool> installDependencies() async {
    if (kIsWeb) {
      LogService.info(_tag, 'Environnement web détecté, installation des dépendances ignorée');
      return true;
    }

    if (!_isInitialized) {
      LogService.error(_tag, 'Le gestionnaire de dépendances n\'est pas initialisé');
      return false;
    }

    try {
      LogService.info(_tag, 'Installation des dépendances Python avec Poetry');
      final result = await _runPoetryCommand(['install', '--no-dev']);
      
      if (result.exitCode == 0) {
        LogService.info(_tag, 'Dépendances installées avec succès');
        await _loadInstalledDependencies();
        return true;
      } else {
        LogService.error(_tag, 'Erreur lors de l\'installation des dépendances: ${result.stderr}');
        return false;
      }
    } catch (e) {
      LogService.error(_tag, 'Exception lors de l\'installation des dépendances: $e');
      return false;
    }
  }

  /// Charge la liste des dépendances installées
  Future<void> _loadInstalledDependencies() async {
    try {
      final result = await _runPoetryCommand(['show', '--no-ansi']);
      
      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        final lines = LineSplitter.split(output).toList();
        
        _installedDependencies.clear();
        for (final line in lines) {
          if (line.trim().isNotEmpty) {
            final packageName = line.split(' ').first.trim();
            _installedDependencies.add(packageName);
          }
        }
        
        LogService.debug(_tag, 'Dépendances installées: $_installedDependencies');
      }
    } catch (e) {
      LogService.error(_tag, 'Erreur lors du chargement des dépendances installées: $e');
    }
  }

  /// Vérifie si les dépendances requises pour un script spécifique sont installées
  Future<bool> checkScriptDependencies(String scriptName) async {
    if (kIsWeb) {
      LogService.info(_tag, 'Environnement web détecté, vérification des dépendances ignorée');
      return true;
    }

    if (!_isInitialized) {
      LogService.error(_tag, 'Le gestionnaire de dépendances n\'est pas initialisé');
      return false;
    }

    try {
      // Charger les dépendances du script depuis pyproject.toml
      final scriptDeps = await _getScriptDependencies(scriptName);
      
      if (scriptDeps.isEmpty) {
        LogService.info(_tag, 'Aucune dépendance spécifique trouvée pour $scriptName');
        return true;
      }

      // S'assurer que la liste des dépendances installées est à jour
      if (_installedDependencies.isEmpty) {
        await _loadInstalledDependencies();
      }

      // Vérifier si toutes les dépendances sont installées
      final missingDeps = scriptDeps.where((dep) => 
        !_installedDependencies.contains(dep)).toList();

      if (missingDeps.isEmpty) {
        LogService.info(_tag, 'Toutes les dépendances pour $scriptName sont installées');
        return true;
      } else {
        LogService.warning(_tag, 'Dépendances manquantes pour $scriptName: $missingDeps');
        return false;
      }
    } catch (e) {
      LogService.error(_tag, 'Erreur lors de la vérification des dépendances pour $scriptName: $e');
      return false;
    }
  }

  /// Récupère la liste des dépendances pour un script spécifique depuis pyproject.toml
  Future<List<String>> _getScriptDependencies(String scriptName) async {
    if (_pythonScriptsPath == null) {
      return [];
    }

    final pyprojectPath = path.join(_pythonScriptsPath!, 'pyproject.toml');
    if (!await File(pyprojectPath).exists()) {
      LogService.warning(_tag, 'Fichier pyproject.toml non trouvé à $pyprojectPath');
      return [];
    }

    try {
      final content = await File(pyprojectPath).readAsString();
      
      // Rechercher la section [tool.shared_scripts.dependencies]
      final regex = RegExp(r'\[tool\.shared_scripts\.dependencies\]([\s\S]*?)(?=\[|$)');
      final match = regex.firstMatch(content);
      
      if (match == null || match.group(1) == null) {
        LogService.warning(_tag, 'Section [tool.shared_scripts.dependencies] non trouvée dans pyproject.toml');
        return [];
      }

      // Rechercher la ligne spécifique au script
      final scriptRegex = RegExp('$scriptName = \\[(.*?)\\]');
      final scriptMatch = scriptRegex.firstMatch(match.group(1)!);
      
      if (scriptMatch == null || scriptMatch.group(1) == null) {
        LogService.info(_tag, 'Aucune dépendance spécifiée pour $scriptName');
        return [];
      }

      // Extraire les noms des dépendances
      final depsString = scriptMatch.group(1)!;
      final depsList = depsString.split(',')
          .map((s) => s.trim().replaceAll('"', '').replaceAll("'", ''))
          .where((s) => s.isNotEmpty)
          .toList();
      
      LogService.debug(_tag, 'Dépendances pour $scriptName: $depsList');
      return depsList;
    } catch (e) {
      LogService.error(_tag, 'Erreur lors de la lecture des dépendances depuis pyproject.toml: $e');
      return [];
    }
  }

  /// Installe les dépendances pour un script spécifique
  Future<bool> installScriptDependencies(String scriptName) async {
    if (kIsWeb) {
      LogService.info(_tag, 'Environnement web détecté, installation des dépendances ignorée');
      return true;
    }

    if (!_isInitialized) {
      LogService.error(_tag, 'Le gestionnaire de dépendances n\'est pas initialisé');
      return false;
    }

    // Vérifier si les dépendances sont déjà installées
    if (await checkScriptDependencies(scriptName)) {
      LogService.info(_tag, 'Les dépendances pour $scriptName sont déjà installées');
      return true;
    }

    try {
      // Installer les dépendances manquantes
      LogService.info(_tag, 'Installation des dépendances pour $scriptName');
      return await installDependencies();
    } catch (e) {
      LogService.error(_tag, 'Erreur lors de l\'installation des dépendances pour $scriptName: $e');
      return false;
    }
  }
}