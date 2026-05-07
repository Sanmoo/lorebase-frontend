import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/auth/widgets/auth_page_scaffold.dart';

void main() {
  group('AuthPageScaffold', () {
    testWidgets('renders children passed to it', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AuthPageScaffold(
            children: [Text('Child content')],
          ),
        ),
      );
      expect(find.text('Child content'), findsOneWidget);
    });

    testWidgets('shows lorebase branding', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AuthPageScaffold(children: []),
        ),
      );
      expect(find.text('lorebase'), findsOneWidget);
    });

    testWidgets('shows movie icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AuthPageScaffold(children: []),
        ),
      );
      expect(find.byIcon(Icons.local_movies), findsOneWidget);
    });
  });
}
