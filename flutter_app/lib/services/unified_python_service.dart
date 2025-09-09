import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Service optimisé pour l'accès direct aux scripts Python sans synchronisation
class UnifiedPythonService {
  /// Canal de méthode pour la communication avec Chaquopy sur Android/iOS
  static const MethodChannel _channel = MethodChannel('com.example.flutter_app/python');
  
  /// URL de l'API pour la version web (en développement local)
  static const String apiBaseUrl = 'http://localhost:8000/api';
  
  /// Chemin standard des scripts Python
  static const String scriptsDir = '';
  
  /// Indique si les scripts ont déjà été extraits des assets
  static bool _scriptsExtracted = false;
  
  /// Chemin où les scripts sont extraits
  static String? _extractedScriptsPath;

  /// Initialise le service et extrait les scripts si nécessaire
  static Future<void> initialize() async {
    if (kIsWeb) return; // Pas besoin d'extraction sur le web
    
    if (!_scriptsExtracted) {
      await _extractPythonScripts();
      _scriptsExtracted = true;
    }
  }
  
  /// Extrait les scripts Python des assets vers un dossier temporaire
  static Future<void> _extractPythonScripts() async {
    try {
      // Obtenir le répertoire temporaire de l'application
      final appDir = await getApplicationDocumentsDirectory();
      final scriptsExtractPath = path.join(appDir.path, 'python_scripts');
      
      // Créer le dossier s'il n'existe pas
      final dir = Directory(scriptsExtractPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      
      // Nous n'avons plus besoin de créer un sous-répertoire calculs
      // car les scripts sont directement dans shared_python
      
      // Lister les scripts à extraire
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      
      // Filtrer pour ne garder que les scripts Python
      final pythonScripts = manifestMap.keys
          .where((String key) => key.startsWith('assets/shared_python/') && key.endsWith('.py'))
          .toList();
      
      // Extraire chaque script
      for (String assetPath in pythonScripts) {
        final scriptData = await rootBundle.load(assetPath);
        final fileName = path.basename(assetPath);
        final dirName = path.basename(path.dirname(assetPath));
        
        String targetPath;
        if (dirName == 'shared_python') {
          targetPath = path.join(scriptsExtractPath, fileName);
        } else {
          // Préserver la structure de dossiers
          final subDir = Directory(path.join(scriptsExtractPath, dirName));
          if (!await subDir.exists()) {
            await subDir.create();
          }
          targetPath = path.join(scriptsExtractPath, dirName, fileName);
        }
        
        final file = File(targetPath);
        await file.writeAsBytes(scriptData.buffer.asUint8List());
      }
      
      _extractedScriptsPath = scriptsExtractPath;
      debugPrint('Scripts Python extraits vers: $_extractedScriptsPath');
    } catch (e) {
      debugPrint('Erreur lors de l\'extraction des scripts Python: $e');
      rethrow;
    }
  }
  
  /// Exécute un script Python avec des arguments et retourne la sortie.
  /// [scriptName] : nom du script Python à exécuter (sans le chemin ni l'extension)
  /// [args] : liste des arguments à passer au script
  static Future<String> runScript(String scriptName, List<String> args) async {
    // Vérifier que le service a été initialisé
    if (!kIsWeb && !_scriptsExtracted) {
      await initialize();
    }
    
    // Standardiser le nom du script (sans chemin ni extension .py)
    final standardName = scriptName.split('/').last.replaceAll('.py', '');
    final scriptPath = '$scriptsDir/$standardName.py';
    
    // Si l'application s'exécute sur le web, utiliser l'API
    if (kIsWeb) {
      return _callWebApi(standardName, args);
    }
    
    // Pour les plateformes natives
    if (Platform.isWindows) {
      // En mode développement, utiliser les scripts Python du projet
      if (Platform.environment.containsKey('FLUTTER_DEV_MODE')) {
        // Chemin du projet basé sur le répertoire de travail actuel
        final projectDir = Directory.current.path;
        final pythonExe = path.join(projectDir, 'windows', 'python_embedded', 
                                  'python-3.11.9-embed-amd64', 'python.exe');
        final sharedScriptPath = path.join(projectDir, '..', 'shared_python', scriptPath);
        
        if (await File(sharedScriptPath).exists()) {
          final result = await Process.run(pythonExe, [sharedScriptPath, ...args]);
          return result.stdout.toString();
        }
      }
      
      // En mode production, utiliser les scripts extraits
      final pythonExe = 'windows/python_embedded/python-3.11.9-embed-amd64/python.exe';
      final extractedScriptPath = path.join(_extractedScriptsPath!, scriptPath);
      final result = await Process.run(pythonExe, [extractedScriptPath, ...args]);
      return result.stdout.toString();
    } else if (Platform.isAndroid || Platform.isIOS) {
      // Intégration via Platform Channel pour Android et iOS
      try {
        // Pour Chaquopy/iOS, le mécanisme de chargement est déjà géré nativement
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
      // En mode développement, utiliser les scripts Python du projet
      if (Platform.environment.containsKey('FLUTTER_DEV_MODE')) {
        final projectDir = Directory.current.path;
        final sharedScriptPath = path.join(projectDir, '..', 'shared_python', scriptPath);
        
        if (await File(sharedScriptPath).exists()) {
          final result = await Process.run('python3', [sharedScriptPath, ...args]);
          return result.stdout.toString();
        }
      }
      
      // En mode production, utiliser les scripts extraits
      final extractedScriptPath = path.join(_extractedScriptsPath!, scriptPath);
      final result = await Process.run('python3', [extractedScriptPath, ...args]);
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
