import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    let pythonChannel = FlutterMethodChannel(
      name: "com.example.flutter_app/python",
      binaryMessenger: controller.binaryMessenger)
    
    pythonChannel.setMethodCallHandler { [weak self] (call, result) in
      guard call.method == "runPythonScript" else {
        result(FlutterMethodNotImplemented)
        return
      }
      
      guard let args = call.arguments as? [String: Any],
            let scriptPath = args["scriptPath"] as? String,
            let scriptArgs = args["args"] as? [String] else {
        result(FlutterError(code: "INVALID_ARGS", 
                           message: "Arguments invalides", 
                           details: nil))
        return
      }
      
      // Exécuter le script Python via le bridge
      let output = PythonBridge.shared.runScript(scriptName: scriptPath, args: scriptArgs)
      result(output)
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
