import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'log_service.dart';
import 'python_dependency_manager.dart';

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
  
  /// Nouvelles propriétés pour la gestion du cache
  static const String _cacheVersionKey = 'scripts_version';
  static const String _currentScriptsVersion = '1.0.0'; // À incrémenter lors des mises à jour majeures
  static const String _metadataFileName = 'python_scripts_metadata.json';
  
  /// Tag pour les logs
  static const String _logTag = 'UnifiedPythonService';
  
  /// Gestionnaire des dépendances Python
  static final PythonDependencyManager _dependencyManager = PythonDependencyManager();

  /// Initialise le service et extrait les scripts si nécessaire
  static Future<void> initialize({
    bool enableLogging = true,
    LogLevel logLevel = LogLevel.info,
    bool logToFile = false,
  }) async {
    // Configurer le service de logs
    await LogService.configure(
      minimumLogLevel: logLevel,
      logToFile: logToFile,
    );
    
    LogService.info(_logTag, 'Initialisation du UnifiedPythonService');
    
    if (kIsWeb) {
      LogService.info(_logTag, 'Exécution en mode web, pas d\'extraction nécessaire');
      return;
    }
    
    if (!_scriptsExtracted) {
      // Vérifier si les scripts sont déjà extraits et à jour
      if (await _isCacheValid()) {
        _extractedScriptsPath = await _getCachedScriptsPath();
        _scriptsExtracted = true;
        LogService.info(_logTag, 'Cache de scripts Python valide, réutilisation du cache');
      } else {
        LogService.info(_logTag, 'Cache invalide ou inexistant, extraction des scripts...');
        await _extractPythonScripts();
        _scriptsExtracted = true;
      }
    }
  }
  
  /// Vérifie si le cache existant est valide
  static Future<bool> _isCacheValid() async {
    try {
      LogService.debug(_logTag, 'Vérification de la validité du cache...');
      final appDir = await getApplicationDocumentsDirectory();
      final scriptsExtractPath = path.join(appDir.path, 'python_scripts');
      final metadataFile = File(path.join(scriptsExtractPath, _metadataFileName));
      
      // Si le fichier de métadonnées n'existe pas, le cache n'est pas valide
      if (!await metadataFile.exists()) {
        LogService.info(_logTag, 'Fichier de métadonnées inexistant');
        return false;
      }
      
      // Lire les métadonnées du cache
      final metadataContent = await metadataFile.readAsString();
      final metadata = json.decode(metadataContent) as Map<String, dynamic>;
      
      // Vérifier la version des scripts
      if (metadata[_cacheVersionKey] != _currentScriptsVersion) {
        LogService.info(_logTag, 'Version des scripts différente, cache: ${metadata[_cacheVersionKey]}, actuelle: $_currentScriptsVersion');
        return false;
      }
      
      // Vérifier que tous les scripts nécessaires sont présents
      final cachedScripts = List<String>.from(metadata['scripts'] ?? []);
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      
      final currentScripts = manifestMap.keys
          .where((String key) => key.startsWith('assets/shared_python/') && key.endsWith('.py'))
          .toList();
      
      // Si le nombre de scripts est différent, le cache n'est pas valide
      if (cachedScripts.length != currentScripts.length) {
        LogService.info(_logTag, 'Nombre de scripts différent, cache: ${cachedScripts.length}, actuel: ${currentScripts.length}');
        return false;
      }
      
      // Vérifier que chaque script du manifest est dans le cache
      for (final scriptPath in currentScripts) {
        final scriptName = path.basename(scriptPath);
        if (!cachedScripts.contains(scriptName)) {
          LogService.info(_logTag, 'Script manquant dans le cache: $scriptName');
          return false;
        }
        
        // Vérifier que le fichier existe physiquement
        final scriptFile = File(path.join(scriptsExtractPath, scriptName));
        if (!await scriptFile.exists()) {
          LogService.warning(_logTag, 'Fichier script manquant sur disque: $scriptName');
          return false;
        }
      }
      
      // Si toutes les vérifications sont passées, le cache est valide
      LogService.debug(_logTag, 'Cache valide: ${cachedScripts.length} scripts');
      return true;
    } catch (e) {
      LogService.error(_logTag, 'Erreur lors de la vérification du cache', e);
      return false; // En cas d'erreur, réextraire pour être sûr
    }
  }
  
  /// Récupère le chemin du cache valide
  static Future<String> _getCachedScriptsPath() async {
    final appDir = await getApplicationDocumentsDirectory();
    return path.join(appDir.path, 'python_scripts');
  }
  
  /// Extrait les scripts Python des assets vers un dossier temporaire
  /// La nouvelle structure maintient l'arborescence des dossiers depuis shared_python/
  static Future<void> _extractPythonScripts() async {
    try {
      LogService.info(_logTag, 'Début de l\'extraction des scripts Python');
      
      // Obtenir le répertoire temporaire de l'application
      final appDir = await getApplicationDocumentsDirectory();
      final scriptsExtractPath = path.join(appDir.path, 'python_scripts');
      
      // Créer le dossier s'il n'existe pas
      final dir = Directory(scriptsExtractPath);
      if (!await dir.exists()) {
        LogService.debug(_logTag, 'Création du répertoire d\'extraction: $scriptsExtractPath');
        await dir.create(recursive: true);
      } else {
        // Nettoyer le dossier existant pour éviter les fichiers obsolètes
        LogService.debug(_logTag, 'Nettoyage du répertoire d\'extraction existant');
        await dir.delete(recursive: true);
        await dir.create(recursive: true);
      }
      
      // Lister les scripts à extraire
      LogService.debug(_logTag, 'Chargement du manifest d\'assets');
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      
      // Filtrer pour ne garder que les scripts Python
      final pythonScripts = manifestMap.keys
          .where((String key) => key.startsWith('assets/shared_python/') && key.endsWith('.py'))
          .toList();
      
      LogService.info(_logTag, 'Nombre de scripts Python à extraire: ${pythonScripts.length}');
      
      // Liste pour stocker les noms de fichiers extraits (pour les métadonnées)
      final List<String> extractedFileNames = [];
      
      // Extraire chaque script
      for (String assetPath in pythonScripts) {
        LogService.debug(_logTag, 'Extraction du script: $assetPath');
        final scriptData = await rootBundle.load(assetPath);
        
        // Extraire le chemin relatif depuis assets/shared_python/
        final relativePath = assetPath.replaceFirst('assets/shared_python/', '');
        final targetPath = path.join(scriptsExtractPath, relativePath);
        
        // Créer les dossiers intermédiaires si nécessaire
        final directory = File(targetPath).parent;
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
        
        // Extraire le fichier
        await File(targetPath).writeAsBytes(scriptData.buffer.asUint8List());
        extractedFileNames.add(relativePath);
        
        LogService.debug(_logTag, 'Script extrait vers: $targetPath');
      }
      
      // Sauvegarder les métadonnées du cache
      LogService.debug(_logTag, 'Sauvegarde des métadonnées du cache');
      final metadataFile = File(path.join(scriptsExtractPath, _metadataFileName));
      final metadata = {
        _cacheVersionKey: _currentScriptsVersion,
        'extractionDate': DateTime.now().toIso8601String(),
        'scripts': extractedFileNames,
      };
      
      await metadataFile.writeAsString(json.encode(metadata));
      
      _extractedScriptsPath = scriptsExtractPath;
      LogService.info(_logTag, 'Scripts Python extraits avec succès vers: $_extractedScriptsPath');
      
      // Initialiser le gestionnaire de dépendances
      try {
        LogService.info(_logTag, 'Initialisation du gestionnaire de dépendances Python');
        await _dependencyManager.initialize(scriptsExtractPath);
      } catch (e) {
        LogService.warning(_logTag, 'Erreur lors de l\'initialisation du gestionnaire de dépendances Python: $e');
        // Continuer même si Poetry n'est pas disponible
      }
    } catch (e, stackTrace) {
      LogService.error(_logTag, 'Erreur lors de l\'extraction des scripts Python', e, stackTrace);
      rethrow;
    }
  }
  
  /// Exécute un script Python avec des arguments et retourne la sortie.
  /// [scriptPath] : chemin du script Python à exécuter (ex: "scripts/calcul_demo")
  /// [args] : liste des arguments à passer au script
  static Future<String> runScript(String scriptPath, List<String> args) async {
    LogService.info(_logTag, 'Exécution du script: $scriptPath avec arguments: $args');
    
    // Vérifier que le service a été initialisé
    if (!kIsWeb && !_scriptsExtracted) {
      LogService.debug(_logTag, 'Service non initialisé, initialisation automatique');
      await initialize();
    }
    
    // Normaliser le chemin du script (sans extension .py)
    final normalizedPath = scriptPath.replaceAll('.py', '');
    // Chemin complet du script avec extension
    final fullScriptPath = '$normalizedPath.py';
    
    LogService.debug(_logTag, 'Chemin du script normalisé: $normalizedPath, chemin complet: $fullScriptPath');
    
    // Vérifier et installer les dépendances du script si nécessaire
    if (!kIsWeb && _scriptsExtracted) {
      try {
        LogService.debug(_logTag, 'Vérification des dépendances pour le script: $normalizedPath');
        await _dependencyManager.installScriptDependencies(normalizedPath);
      } catch (e) {
        LogService.warning(_logTag, 'Erreur lors de la vérification/installation des dépendances: $e');
        // Continuer l'exécution même si la gestion des dépendances échoue
      }
    }
    
    // Si l'application s'exécute sur le web, utiliser l'API
    if (kIsWeb) {
      LogService.debug(_logTag, 'Exécution en mode web, appel de l\'API');
      return _callWebApi(normalizedPath, args);
    }
    
    try {
      String result;
      
      // Pour les plateformes natives
      if (Platform.isWindows) {
        LogService.debug(_logTag, 'Exécution sur Windows');
        // En mode développement, utiliser les scripts Python du projet
        if (Platform.environment.containsKey('FLUTTER_DEV_MODE')) {
          LogService.debug(_logTag, 'Mode développement, utilisation des scripts du projet');
          // Chemin du projet basé sur le répertoire de travail actuel
          final projectDir = Directory.current.path;
          final pythonExe = path.join(projectDir, 'windows', 'python_embedded', 
                                    'python-3.11.9-embed-amd64', 'python.exe');
          // Chemin adapté à la nouvelle structure scripts/
          final sharedScriptPath = path.join(projectDir, '..', 'shared_python', 'scripts', fullScriptPath);
          
          if (await File(sharedScriptPath).exists()) {
            LogService.debug(_logTag, 'Exécution du script: $sharedScriptPath avec Python: $pythonExe');
            final processResult = await Process.run(pythonExe, [sharedScriptPath, ...args]);
            if (processResult.stderr.toString().isNotEmpty) {
              LogService.warning(_logTag, 'Erreur stderr: ${processResult.stderr}');
            }
            result = processResult.stdout.toString();
          } else {
            throw FileSystemException('Script non trouvé: $sharedScriptPath');
          }
        } else {
          // En mode production, utiliser les scripts extraits
          LogService.debug(_logTag, 'Mode production, utilisation des scripts extraits');
          final pythonExe = 'windows/python_embedded/python-3.11.9-embed-amd64/python.exe';
          final extractedScriptPath = path.join(_extractedScriptsPath!, fullScriptPath);
          
          if (!await File(extractedScriptPath).exists()) {
            throw FileSystemException('Script extrait non trouvé: $extractedScriptPath');
          }
          
          LogService.debug(_logTag, 'Exécution du script: $extractedScriptPath avec Python: $pythonExe');
          final processResult = await Process.run(pythonExe, [extractedScriptPath, ...args]);
          if (processResult.stderr.toString().isNotEmpty) {
            LogService.warning(_logTag, 'Erreur stderr: ${processResult.stderr}');
          }
          result = processResult.stdout.toString();
        }
      } else if (Platform.isAndroid || Platform.isIOS) {
        LogService.debug(_logTag, 'Exécution sur ${Platform.isAndroid ? 'Android' : 'iOS'}');
        // Intégration via Platform Channel pour Android et iOS
        try {
          // Pour Chaquopy/iOS, le mécanisme de chargement est déjà géré nativement
          LogService.debug(_logTag, 'Appel de la méthode native: $normalizedPath');
          final channelResult = await _channel.invokeMethod<String>(
            'runPythonScript', 
            {
              'scriptPath': normalizedPath,  // Sans l'extension pour Chaquopy/iOS
              'args': args,
            }
          );
          result = channelResult ?? 'Pas de résultat';
        } catch (e) {
          LogService.error(_logTag, 'Erreur lors de l\'appel de la méthode native', e);
          result = 'Erreur Python : $e';
        }
      } else if (Platform.isLinux || Platform.isMacOS) {
        LogService.debug(_logTag, 'Exécution sur ${Platform.isLinux ? 'Linux' : 'macOS'}');
        // En mode développement, utiliser les scripts Python du projet
        if (Platform.environment.containsKey('FLUTTER_DEV_MODE')) {
          LogService.debug(_logTag, 'Mode développement, utilisation des scripts du projet');
          final projectDir = Directory.current.path;
          // Chemin adapté à la nouvelle structure scripts/
          final sharedScriptPath = path.join(projectDir, '..', 'shared_python', 'scripts', fullScriptPath);
          
          if (await File(sharedScriptPath).exists()) {
            LogService.debug(_logTag, 'Exécution du script: $sharedScriptPath avec Python3');
            final processResult = await Process.run('python3', [sharedScriptPath, ...args]);
            if (processResult.stderr.toString().isNotEmpty) {
              LogService.warning(_logTag, 'Erreur stderr: ${processResult.stderr}');
            }
            result = processResult.stdout.toString();
          } else {
            throw FileSystemException('Script non trouvé: $sharedScriptPath');
          }
        } else {
          // En mode production, utiliser les scripts extraits
          LogService.debug(_logTag, 'Mode production, utilisation des scripts extraits');
          final extractedScriptPath = path.join(_extractedScriptsPath!, scriptPath);
          
          if (!await File(extractedScriptPath).exists()) {
            throw FileSystemException('Script extrait non trouvé: $extractedScriptPath');
          }
          
          LogService.debug(_logTag, 'Exécution du script: $extractedScriptPath avec Python3');
          final processResult = await Process.run('python3', [extractedScriptPath, ...args]);
          if (processResult.stderr.toString().isNotEmpty) {
            LogService.warning(_logTag, 'Erreur stderr: ${processResult.stderr}');
          }
          result = processResult.stdout.toString();
        }
      } else {
        final errorMessage = 'Plateforme non supportée: ${Platform.operatingSystem}';
        LogService.error(_logTag, errorMessage);
        throw UnsupportedError(errorMessage);
      }
      
      // Tronquer le résultat dans les logs s'il est trop long
      final truncatedResult = result.length > 200 
          ? '${result.substring(0, 200)}... (${result.length - 200} caractères de plus)'
          : result;
      LogService.debug(_logTag, 'Résultat de l\'exécution: $truncatedResult');
      
      return result;
    } catch (e, stackTrace) {
      LogService.error(_logTag, 'Erreur lors de l\'exécution du script $normalizedPath', e, stackTrace);
      rethrow;
    }
  }

  /// Appelle l'API web pour exécuter le script Python
  static Future<String> _callWebApi(String scriptPath, List<String> args) async {
    LogService.info(_logTag, 'Appel de l\'API web pour le script: $scriptPath');
    try {
      // Construction de la requête API
      final uri = Uri.parse('$apiBaseUrl/run_script');
      final body = jsonEncode({
        'script_path': scriptPath,
        'args': args,
      });
      
      LogService.debug(_logTag, 'URL API: $uri');
      LogService.debug(_logTag, 'Corps de la requête: $body');
      
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );
      
      if (response.statusCode == 200) {
        // Parser la réponse JSON pour extraire seulement le résultat
        LogService.debug(_logTag, 'Réponse API réussie (200 OK)');
        final jsonResponse = jsonDecode(response.body);
        final result = jsonEncode(jsonResponse['result']);
        
        // Tronquer le résultat dans les logs s'il est trop long
        final truncatedResult = result.length > 200 
            ? '${result.substring(0, 200)}... (${result.length - 200} caractères de plus)'
            : result;
        LogService.debug(_logTag, 'Résultat API: $truncatedResult');
        
        return result;
      } else {
        final errorMessage = 'Erreur API: ${response.statusCode} - ${response.body}';
        LogService.warning(_logTag, errorMessage);
        return errorMessage;
      }
    } catch (e, stackTrace) {
      final errorMessage = 'Erreur réseau: $e';
      LogService.error(_logTag, errorMessage, e, stackTrace);
      return errorMessage;
    }
  }
  
  /// Force la réextraction des scripts, indépendamment de l'état du cache
  static Future<void> forceRefreshScripts() async {
    LogService.info(_logTag, 'Rafraîchissement forcé des scripts Python');
    _scriptsExtracted = false;
    await initialize();
    LogService.info(_logTag, 'Scripts Python réextraits avec succès');
  }
  
  /// Installe explicitement les dépendances Python pour un script spécifique
  static Future<bool> installScriptDependencies(String scriptName) async {
    if (kIsWeb) {
      LogService.info(_logTag, 'Environnement web détecté, pas d\'installation de dépendances nécessaire');
      return true;
    }
    
    if (!_scriptsExtracted) {
      LogService.warning(_logTag, 'Le service n\'est pas initialisé, initialisation automatique');
      await initialize();
    }
    
    // Standardiser le nom du script
    final standardName = scriptName.split('/').last.replaceAll('.py', '');
    
    try {
      LogService.info(_logTag, 'Installation des dépendances pour le script: $standardName');
      return await _dependencyManager.installScriptDependencies(standardName);
    } catch (e) {
      LogService.error(_logTag, 'Erreur lors de l\'installation des dépendances pour $standardName', e);
      return false;
    }
  }
  
  /// Installe toutes les dépendances Python définies dans le pyproject.toml
  static Future<bool> installAllDependencies() async {
    if (kIsWeb) {
      LogService.info(_logTag, 'Environnement web détecté, pas d\'installation de dépendances nécessaire');
      return true;
    }
    
    if (!_scriptsExtracted) {
      LogService.warning(_logTag, 'Le service n\'est pas initialisé, initialisation automatique');
      await initialize();
    }
    
    try {
      LogService.info(_logTag, 'Installation de toutes les dépendances Python');
      return await _dependencyManager.installDependencies();
    } catch (e) {
      LogService.error(_logTag, 'Erreur lors de l\'installation des dépendances Python', e);
      return false;
    }
  }
}
