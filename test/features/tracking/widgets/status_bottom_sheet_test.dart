import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/tracking/widgets/status_bottom_sheet.dart';

void main() {
  group('StatusBottomSheet', () {
    testWidgets('shows "Update Status" title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showModalBottomSheet(
                  context: context,
                  builder: (_) => StatusBottomSheet(
                    currentStatus: 'WATCHING',
                    onStatusSelected: (_) {},
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Update Status'), findsOneWidget);
    });

    testWidgets('shows all 4 TrackingStatus labels', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showModalBottomSheet(
                  context: context,
                  builder: (_) => StatusBottomSheet(
                    currentStatus: 'WATCHING',
                    onStatusSelected: (_) {},
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Want to Watch'), findsOneWidget);
      expect(find.text('Watching'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Dropped'), findsOneWidget);
    });

    testWidgets('current status has check_circle icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showModalBottomSheet(
                  context: context,
                  builder: (_) => StatusBottomSheet(
                    currentStatus: 'WATCHING',
                    onStatusSelected: (_) {},
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byIcon(Icons.circle_outlined), findsNWidgets(3));
    });

    testWidgets('tapping option calls onStatusSelected', (tester) async {
      String? selected;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showModalBottomSheet(
                  context: context,
                  builder: (_) => StatusBottomSheet(
                    currentStatus: 'WATCHING',
                    onStatusSelected: (s) => selected = s,
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Completed'));
      expect(selected, 'COMPLETED');
    });
  });
}
