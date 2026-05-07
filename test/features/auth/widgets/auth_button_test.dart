import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/auth/widgets/auth_button.dart';

void main() {
  group('AuthButton', () {
    testWidgets('renders text label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AuthButton(text: 'Entrar'))),
      );
      expect(find.text('Entrar'), findsOneWidget);
    });

    testWidgets('shows CircularProgressIndicator when isLoading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AuthButton(text: 'Entrar', isLoading: true)),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Entrar'), findsNothing);
    });

    testWidgets('onPressed fires callback when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthButton(
              text: 'Entrar',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.tap(find.text('Entrar'));
      expect(tapped, true);
    });

    testWidgets('button is disabled when isLoading', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthButton(
              text: 'Entrar',
              isLoading: true,
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.tap(find.byType(ElevatedButton));
      expect(tapped, false);
    });
  });
}
