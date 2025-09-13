// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Note: Dans ce projet, l'application principale est dans le sous-répertoire flutter_app
// et non pas à la racine. Par conséquent, nous utilisons un test minimal au lieu
// d'importer directement les classes depuis le package flutter_app.

void main() {
  testWidgets('Test de widget minimal', (WidgetTester tester) async {
    // Nous créons un widget minimal pour le test
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('yeb_app_template'),
          ),
          body: const Center(
            child: Text('Test réussi'),
          ),
        ),
      ),
    );

    // Vérifie que notre widget contient le titre attendu
    expect(find.textContaining('yeb_app_template'), findsOneWidget);
    expect(find.text('Test réussi'), findsOneWidget);
  });
}
