import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/auth/widgets/auth_text_field.dart';

void main() {
  group('AuthTextField', () {
    testWidgets('calls onSubmitted when TextFormField.onFieldSubmitted fires',
        (tester) async {
      String? submittedValue;
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthTextField(
              controller: controller,
              hint: 'Test',
              icon: Icons.abc,
              onSubmitted: (value) {
                submittedValue = value;
              },
            ),
          ),
        ),
      );

      controller.text = 'test@email.com';
      await tester.tap(find.byType(TextFormField));
      await tester.testTextInput.receiveAction(TextInputAction.done);

      expect(submittedValue, 'test@email.com');
    });

    testWidgets('does not crash when onSubmitted is null', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthTextField(
              controller: controller,
              hint: 'Test',
              icon: Icons.abc,
            ),
          ),
        ),
      );

      controller.text = 'test';
      await tester.tap(find.byType(TextFormField));
      await tester.testTextInput.receiveAction(TextInputAction.done);

      expect(find.byType(TextFormField), findsOneWidget);
    });
  });
}
