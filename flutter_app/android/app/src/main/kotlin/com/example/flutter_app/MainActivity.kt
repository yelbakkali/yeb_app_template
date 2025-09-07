package com.example.flutter_app

import androidx.annotation.NonNull
import com.chaquo.python.PyException
import com.chaquo.python.Python
import com.chaquo.python.android.AndroidPlatform
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.flutter_app/python"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Initialiser Python si ce n'est pas déjà fait
        if (!Python.isStarted()) {
            Python.start(AndroidPlatform(applicationContext))
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            when (call.method) {
                "runPythonScript" -> {
                    val scriptPath = call.argument<String>("scriptPath") ?: ""
                    val args = call.argument<List<String>>("args") ?: listOf()
                    
                    try {
                        val py = Python.getInstance()
                        val scriptName = scriptPath.substringBeforeLast(".py")
                        val pyModule = py.getModule(scriptName)
                        val pyResult = pyModule.callAttr("main", args.toTypedArray())
                        
                        // Conversion du résultat Python en Map pour Flutter
                        val resultMap = pyResult.toString()
                        result.success(resultMap)
                    } catch (e: PyException) {
                        result.error("PYTHON_ERROR", e.message, e.toString())
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, e.toString())
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
