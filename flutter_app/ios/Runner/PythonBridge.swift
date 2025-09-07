import Foundation
import Flutter
import PythonKit

class PythonBridge {
    static let shared = PythonBridge()
    private var sys: PythonObject?
    private var os: PythonObject?
    
    init() {
        setupPythonPath()
    }
    
    private func setupPythonPath() {
        // Obtenir le chemin vers le bundle Python
        guard let bundlePath = Bundle.main.path(forResource: "PythonBundle", ofType: nil) else {
            print("Erreur: Impossible de trouver le chemin vers PythonBundle")
            return
        }
        
        // Initialiser les modules Python nécessaires
        sys = Python.import("sys")
        os = Python.import("os")
        
        // Ajouter le chemin du bundle au sys.path Python
        sys?.path.append(bundlePath)
        print("Python path configuré avec succès: \(bundlePath)")
    }
    
    func runScript(scriptName: String, args: [String]) -> String {
        do {
            // Supprimer l'extension .py si présente
            let moduleName = scriptName.replacingOccurrences(of: ".py", with: "")
            
            // Importer le module Python
            let module = Python.import(moduleName)
            
            // Convertir les arguments en flottants si possible
            let numericArgs = args.map { arg -> PythonObject in
                if let floatValue = Float(arg) {
                    return Python.convertFromSwift(floatValue)
                }
                return Python.convertFromSwift(arg)
            }
            
            // Appeler la fonction main avec les arguments
            let result: PythonObject
            if numericArgs.count >= 2 {
                result = module.main(numericArgs[0], numericArgs[1])
            } else {
                result = module.main()
            }
            
            // Convertir et retourner le résultat
            return String(describing: result)
            
        } catch let error {
            return "Erreur Python: \(error)"
        }
    }
}
