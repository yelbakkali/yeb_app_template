import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Niveaux de log disponibles, du moins au plus critique
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// Service de logging pour faciliter le débogage et le suivi des opérations
class LogService {
  /// Niveau de log minimum à afficher (les logs de niveau inférieur sont ignorés)
  static LogLevel _minimumLogLevel = LogLevel.info;
  
  /// Indique si les logs doivent être écrits dans un fichier
  static bool _logToFile = false;
  
  /// Chemin du fichier de log
  static String? _logFilePath;
  
  /// Taille maximale du fichier de log en bytes (1 Mo par défaut)
  static const int _maxLogSizeBytes = 1024 * 1024;
  
  /// Configuration du service de log
  static Future<void> configure({
    LogLevel minimumLogLevel = LogLevel.info,
    bool logToFile = false,
  }) async {
    _minimumLogLevel = minimumLogLevel;
    _logToFile = logToFile;
    
    if (_logToFile) {
      await _initLogFile();
    }
  }
  
  /// Initialise le fichier de log
  static Future<void> _initLogFile() async {
    if (!kIsWeb) {
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final logDir = Directory(path.join(appDir.path, 'logs'));
        
        if (!await logDir.exists()) {
          await logDir.create(recursive: true);
        }
        
        _logFilePath = path.join(logDir.path, 'unified_python_service.log');
        
        // Vérifier la taille du fichier de log et le nettoyer si nécessaire
        final logFile = File(_logFilePath!);
        if (await logFile.exists()) {
          final fileStats = await logFile.stat();
          if (fileStats.size > _maxLogSizeBytes) {
            await logFile.writeAsString(''); // Vider le fichier s'il est trop gros
            await _log(LogLevel.info, 'LogService', 'Fichier de log nettoyé (taille > $_maxLogSizeBytes bytes)');
          }
        }
      } catch (e) {
        debugPrint('Erreur lors de l\'initialisation du fichier de log: $e');
        _logToFile = false;
      }
    } else {
      // Pas de logs fichier sur le web
      _logToFile = false;
    }
  }
  
  /// Enregistre un message de log au niveau debug
  static Future<void> debug(String tag, String message) async {
    await _log(LogLevel.debug, tag, message);
  }
  
  /// Enregistre un message de log au niveau info
  static Future<void> info(String tag, String message) async {
    await _log(LogLevel.info, tag, message);
  }
  
  /// Enregistre un message de log au niveau warning
  static Future<void> warning(String tag, String message) async {
    await _log(LogLevel.warning, tag, message);
  }
  
  /// Enregistre un message de log au niveau error
  static Future<void> error(String tag, String message, [dynamic error, StackTrace? stackTrace]) async {
    String fullMessage = message;
    if (error != null) {
      fullMessage += '\nErreur: $error';
      if (stackTrace != null) {
        fullMessage += '\nStackTrace: $stackTrace';
      }
    }
    await _log(LogLevel.error, tag, fullMessage);
  }
  
  /// Méthode interne pour enregistrer un log
  static Future<void> _log(LogLevel level, String tag, String message) async {
    // Ignorer les logs de niveau inférieur à celui configuré
    if (level.index < _minimumLogLevel.index) {
      return;
    }
    
    // Format: [TIMESTAMP] [LEVEL] [TAG] Message
    final timestamp = DateTime.now().toIso8601String();
    final levelString = level.toString().split('.').last.toUpperCase();
    final logMessage = '[$timestamp] [$levelString] [$tag] $message';
    
    // Afficher le log dans la console
    // Utiliser des couleurs différentes selon le niveau de log
    if (level == LogLevel.error) {
      debugPrint('\x1B[31m$logMessage\x1B[0m'); // Rouge
    } else if (level == LogLevel.warning) {
      debugPrint('\x1B[33m$logMessage\x1B[0m'); // Jaune
    } else if (level == LogLevel.info) {
      debugPrint('\x1B[36m$logMessage\x1B[0m'); // Cyan
    } else {
      debugPrint(logMessage);
    }
    
    // Écrire dans le fichier de log si configuré
    if (_logToFile && _logFilePath != null && !kIsWeb) {
      try {
        final file = File(_logFilePath!);
        await file.writeAsString('$logMessage\n', mode: FileMode.append);
      } catch (e) {
        debugPrint('Erreur lors de l\'écriture du log dans le fichier: $e');
      }
    }
  }
  
  /// Supprime le fichier de log
  static Future<void> clearLogs() async {
    if (_logToFile && _logFilePath != null && !kIsWeb) {
      try {
        final file = File(_logFilePath!);
        if (await file.exists()) {
          await file.writeAsString('');
          await _log(LogLevel.info, 'LogService', 'Fichier de log effacé');
        }
      } catch (e) {
        debugPrint('Erreur lors du nettoyage du fichier de log: $e');
      }
    }
  }
  
  /// Récupère le contenu du fichier de log
  static Future<String?> getLogContent() async {
    if (_logToFile && _logFilePath != null && !kIsWeb) {
      try {
        final file = File(_logFilePath!);
        if (await file.exists()) {
          return await file.readAsString();
        }
      } catch (e) {
        debugPrint('Erreur lors de la lecture du fichier de log: $e');
      }
    }
    return null;
  }
}