import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/tracking/widgets/tracking_status_chip.dart';

void main() {
  group('TrackingStatusChip', () {
    testWidgets('WATCHING shows label "Watching"', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: TrackingStatusChip(status: 'WATCHING')),
        ),
      );
      expect(find.text('Watching'), findsOneWidget);
    });

    testWidgets('WANT_TO_WATCH shows label "Want to Watch"', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: TrackingStatusChip(status: 'WANT_TO_WATCH')),
        ),
      );
      expect(find.text('Want to Watch'), findsOneWidget);
    });

    testWidgets('COMPLETED shows label "Completed"', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: TrackingStatusChip(status: 'COMPLETED')),
        ),
      );
      expect(find.text('Completed'), findsOneWidget);
    });

    testWidgets('DROPPED shows label "Dropped"', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: TrackingStatusChip(status: 'DROPPED')),
        ),
      );
      expect(find.text('Dropped'), findsOneWidget);
    });

    testWidgets('unknown status falls back to "Want to Watch"', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: TrackingStatusChip(status: 'INVALID')),
        ),
      );
      expect(find.text('Want to Watch'), findsOneWidget);
    });
  });
}
