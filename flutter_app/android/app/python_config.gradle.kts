import org.gradle.kotlin.dsl.kotlin

// Configuration Chaquopy pour l'intégration Python
chaquopy {
    defaultConfig {
        // Version de Python à utiliser (doit correspondre à la version disponible sur Android)
        version = "3.11"
        
        // Configuration Python pour accéder aux assets
        extractPackages("assets.shared_python")
        
        // Pip requirements (optionnel, ajoutez vos dépendances ici si nécessaire)
        // pip {
        //     install("numpy")
        //     install("pandas")
        // }
    }
}

// Tâche Gradle pour extraire les scripts Python des assets
tasks.register<Copy>("copyPythonScriptsFromAssets") {
    description = "Copie les scripts Python des assets vers src/main/python"
    
    // Chemin du projet Flutter (répertoire parent)
    val flutterProjectDir = rootProject.rootDir.parentFile
    
    // Chemin des scripts Python partagés
    val sharedPythonDir = File(flutterProjectDir, "shared_python")
    
    // Destination dans le projet Android
    val androidPythonDir = File(projectDir, "src/main/python")
    
    // Source et destination
    from(sharedPythonDir)
    into(androidPythonDir)
    
    // Inclure uniquement les fichiers Python
    include("**/*.py")
    
    doLast {
        println("Scripts Python copiés avec succès de ${sharedPythonDir} vers ${androidPythonDir}")
    }
}

// Intégrer la tâche dans le processus de build
tasks.findByName("preBuild")?.dependsOn("copyPythonScriptsFromAssets")
