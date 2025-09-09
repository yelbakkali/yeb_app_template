import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

/// Service centralisé pour l'appel aux scripts Python selon la plateforme.
class PythonService {
  /// Canal de méthode pour la communication avec Chaquopy sur Android/iOS
  static const MethodChannel _channel = MethodChannel('com.example.flutter_app/python');
  
  /// URL de l'API pour la version web (en développement local)
  static const String apiBaseUrl = 'http://localhost:8000/api';
  
  /// Chemin standard des scripts Python
  static const String scriptsDir = '';

  /// Exécute un script Python avec des arguments et retourne la sortie.
  /// [scriptPath] : chemin du script Python à exécuter
  /// [args] : liste des arguments à passer au script
  /// Exécute un script Python avec des arguments et retourne la sortie.
  /// [scriptName] : nom du script Python à exécuter (sans le chemin ni l'extension)
  /// [args] : liste des arguments à passer au script
  static Future<String> runScript(String scriptName, List<String> args) async {
    // Standardiser le nom du script (sans chemin ni extension .py)
    final standardName = scriptName.split('/').last.replaceAll('.py', '');
    final scriptPath = '$scriptsDir/$standardName.py';
    
    // Si l'application s'exécute sur le web, utiliser l'API
    if (kIsWeb) {
      return _callWebApi(standardName, args);
    }
    
    // Pour les plateformes natives
    if (Platform.isWindows) {
      // Exécution via Python portable embarqué
      final pythonExe = 'windows/python_embedded/python-3.11.9-embed-amd64/python.exe';
      final scriptFullPath = 'windows/python_embedded/$scriptPath';
      final result = await Process.run(pythonExe, [scriptFullPath, ...args]);
      return result.stdout.toString();
    } else if (Platform.isAndroid || Platform.isIOS) {
      // Intégration via Platform Channel pour Android et iOS
      try {
        // Utiliser le canal de méthode pour appeler le script
        final result = await _channel.invokeMethod<String>(
          'runPythonScript', 
          {
            'scriptPath': standardName,  // Sans l'extension pour Chaquopy/iOS
            'args': args,
          }
        );
        return result ?? 'Pas de résultat';
      } catch (e) {
        return 'Erreur Python : $e';
      }
    } else if (Platform.isLinux || Platform.isMacOS) {
      // Exécution standard sur Linux/macOS pour le développement
      final result = await Process.run('python3', ['python_backend/$scriptPath', ...args]);
      return result.stdout.toString();
    } else {
      throw UnsupportedError('Plateforme non supportée');
    }
  }
  
  /// Appelle l'API web pour exécuter le script Python
  static Future<String> _callWebApi(String scriptName, List<String> args) async {
    try {
      // Construction de la requête API
      final response = await http.post(
        Uri.parse('$apiBaseUrl/run_script'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'script_name': scriptName,
          'args': args,
        }),
      );
      
      if (response.statusCode == 200) {
        // Parser la réponse JSON pour extraire seulement le résultat
        final jsonResponse = jsonDecode(response.body);
        return jsonEncode(jsonResponse['result']);
      } else {
        return 'Erreur API: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      return 'Erreur réseau: $e';
    }
  }
}
