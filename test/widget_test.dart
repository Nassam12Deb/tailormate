import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tailormate/main.dart';

void main() {
  testWidgets('App starts and shows login screen when not logged in', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the login screen is shown by checking for key elements
    expect(find.text('TailorMate'), findsOneWidget);
    expect(find.text('Connexion à votre compte'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2)); // Email and password fields
    expect(find.text('Se connecter'), findsOneWidget);
  });

  testWidgets('Register screen shows correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    
    // Navigate to register screen
    await tester.tap(find.text('Créer un compte'));
    await tester.pumpAndSettle();

    // Verify register screen elements
    expect(find.text('Créez votre compte'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(6)); // All form fields
    expect(find.text('Créer mon compte'), findsOneWidget);
  });
}