import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/tracking/widgets/tracking_editor_sheet.dart';
import 'package:lorebase/l10n/strings.g.dart';

Future<void> main() async {
  await LocaleSettings.setLocale(AppLocale.enUs);

  testWidgets('saves status, rating, and review', (tester) async {
    String? savedStatus;
    int? savedRating;
    String? savedReview;

    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: TrackingEditorSheet(
              title: 'Add to List',
              initialStatus: 'WATCHING',
              initialRating: 7,
              initialReview: 'Nice',
              onSave: ({required status, rating, review}) async {
                savedStatus = status;
                savedRating = rating;
                savedReview = review;
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    expect(savedStatus, 'WATCHING');
    expect(savedRating, 7);
    expect(savedReview, 'Nice');
  });
}
