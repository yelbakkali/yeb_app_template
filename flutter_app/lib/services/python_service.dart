import 'dart:io';

/// Service centralisé pour l'appel aux scripts Python selon la plateforme.
class PythonService {
  /// Exécute un script Python avec des arguments et retourne la sortie.
  /// [scriptPath] : chemin du script Python à exécuter
  /// [args] : liste des arguments à passer au script
  static Future<String> runScript(String scriptPath, List<String> args) async {
    if (Platform.isWindows) {
      // Exemple : exécution via Python portable embarqué
      final pythonExe = 'python_embedded/python.exe'; // À adapter selon l'intégration
      final result = await Process.run(pythonExe, [scriptPath, ...args]);
      return result.stdout.toString();
    } else if (Platform.isAndroid) {
      // TODO : Intégration Chaquopy via Platform Channel
      throw UnimplementedError('Intégration Chaquopy non implémentée');
    } else if (Platform.isIOS) {
      // TODO : Intégration Python-Apple-support via FFI ou Platform Channel
      throw UnimplementedError('Intégration Python-Apple-support non implémentée');
    } else if (Platform.isLinux || Platform.isMacOS) {
      // Exécution standard si Python est disponible
      final result = await Process.run('python3', [scriptPath, ...args]);
      return result.stdout.toString();
    } else {
      throw UnsupportedError('Plateforme non supportée');
    }
  }
}
