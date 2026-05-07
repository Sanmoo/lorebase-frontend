import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/core/widgets/error_widget.dart';

void main() {
  group('AppErrorWidget', () {
    testWidgets('shows error message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppErrorWidget(message: 'Something broke')),
        ),
      );
      expect(find.text('Something broke'), findsOneWidget);
    });

    testWidgets('does not show retry button when onRetry is null',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppErrorWidget(message: 'Error')),
        ),
      );
      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('shows retry button when onRetry is provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppErrorWidget(
              message: 'Error',
              onRetry: () {},
            ),
          ),
        ),
      );
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('retry button calls onRetry when tapped', (tester) async {
      var retried = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppErrorWidget(
              message: 'Error',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );
      await tester.tap(find.text('Retry'));
      expect(retried, true);
    });
  });
}
