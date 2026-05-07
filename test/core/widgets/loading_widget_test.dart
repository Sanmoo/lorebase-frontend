import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/core/widgets/loading_widget.dart';

void main() {
  group('LoadingWidget', () {
    testWidgets('shows CircularProgressIndicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LoadingWidget()),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('does not show text when message is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LoadingWidget()),
        ),
      );
      // There should be no Text widget with the loading message
      expect(find.text('Loading...'), findsNothing);
    });

    testWidgets('shows message text when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
              body: LoadingWidget(message: 'Carregando...')),
        ),
      );
      expect(find.text('Carregando...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
