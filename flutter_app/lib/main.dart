import 'dart:convert';
import 'package:flutter/material.dart';
import 'services/unified_python_service.dart';
import 'config/project_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser le service Python unifié
  await UnifiedPythonService.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: ProjectConfig.projectName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: MyHomePage(title: '${ProjectConfig.projectName} - Démo Python'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _valueAController = TextEditingController(text: "10");
  final TextEditingController _valueBController = TextEditingController(text: "5");
  String _result = "Résultat apparaîtra ici";
  bool _isLoading = false;

  @override
  void dispose() {
    _valueAController.dispose();
    _valueBController.dispose();
    super.dispose();
  }

  Future<void> _runPythonCalculation() async {
    setState(() {
      _isLoading = true;
      _result = "Calcul en cours...";
    });

    try {
      final a = _valueAController.text;
      final b = _valueBController.text;
      
      // Appel du script Python unifié sur toutes les plateformes
      final output = await UnifiedPythonService.runScript(
        'scripts/calcul_demo',     // Le nom du script Python avec le chemin dans shared_python
        [a, b],            // Les arguments à passer
      );
      
      // Afficher le résultat avec mise en forme
      try {
        final jsonResult = jsonDecode(output);
        setState(() {
          _result = "Résultat du calcul Python:\n";
          jsonResult.forEach((key, value) {
            _result += "\n• $key: $value";
          });
        });
      } catch (e) {
        // Si ce n'est pas du JSON valide, afficher tel quel
        setState(() {
          _result = "Résultat du calcul Python:\n$output";
        });
      }
    } catch (e) {
      setState(() {
        _result = "Erreur: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Démo d\'intégration Python (Android / Chaquopy)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _valueAController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Valeur A',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _valueBController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Valeur B',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _runPythonCalculation,
              child: _isLoading 
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text("Calcul en cours..."),
                    ],
                  )
                : const Text("Exécuter le calcul Python"),
            ),
            const SizedBox(height: 24),
            const Text(
              'Résultat:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_result),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : () async {
                setState(() {
                  _isLoading = true;
                  _result = "Analyse en cours...";
                });
                
                try {
                  // Appel du script d'analyse de données
                  final output = await UnifiedPythonService.runScript(
                    'scripts/analyse_data',  // Chemin complet incluant 'scripts/'
                    ["10, 20, 30, 40, 50"],  // Données de test
                  );
                  
                  // Afficher le résultat avec mise en forme
                  try {
                    final jsonResult = jsonDecode(output);
                    setState(() {
                      _result = "Résultat de l'analyse des données:\n";
                      jsonResult.forEach((key, value) {
                        _result += "\n• $key: $value";
                      });
                    });
                  } catch (e) {
                    setState(() {
                      _result = "Résultat de l'analyse:\n$output";
                    });
                  }
                } catch (e) {
                  setState(() {
                    _result = "Erreur: $e";
                  });
                } finally {
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
              child: const Text("Tester l'analyse de données"),
            ),
          ],
        ),
      ),
    );
  }
}
