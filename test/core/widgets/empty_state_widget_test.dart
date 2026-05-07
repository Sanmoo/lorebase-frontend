import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/core/widgets/empty_state_widget.dart';

void main() {
  group('EmptyStateWidget', () {
    testWidgets('shows default icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: EmptyStateWidget(message: 'Nothing here')),
        ),
      );
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('shows message text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: EmptyStateWidget(message: 'Nothing here')),
        ),
      );
      expect(find.text('Nothing here'), findsOneWidget);
    });

    testWidgets('shows custom icon when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              message: 'Empty',
              icon: Icons.tv_off,
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.tv_off), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsNothing);
    });
  });
}
