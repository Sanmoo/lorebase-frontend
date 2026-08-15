import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/tracking/data/models/media_type.dart';
import 'package:lorebase/features/tracking/widgets/tracking_editor_sheet.dart';
import 'package:lorebase/l10n/strings.g.dart';

Future<void> main() async {
  await LocaleSettings.setLocale(AppLocale.enUs);

  testWidgets('saves platform and hours for games', (tester) async {
    String? savedStatus;
    String? savedPlatform;
    double? savedHours;

    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: TrackingEditorSheet(
              title: 'Add Game',
              initialStatus: 'WANT_TO_PLAY',
              initialRating: null,
              initialReview: '',
              initialSelectedPlatform: null,
              initialHoursPlayed: null,
              isGame: true,
              onSave:
                  ({
                    required status,
                    rating,
                    review,
                    selectedPlatform,
                    hoursPlayed,
                  }) async {
                    savedStatus = status;
                    savedPlatform = selectedPlatform;
                    savedHours = hoursPlayed;
                  },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('PS5'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Hours Played'),
      '12.5',
    );
    await tester.ensureVisible(find.text('Save Changes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    expect(savedStatus, 'WANT_TO_PLAY');
    expect(savedPlatform, 'PS5');
    expect(savedHours, 12.5);
  });

  testWidgets('offers only reading statuses for books', (tester) async {
    String? savedStatus;

    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: TrackingEditorSheet(
              title: 'Add Book',
              initialStatus: 'WANT_TO_READ',
              initialRating: null,
              initialReview: '',
              mediaType: MediaType.book,
              onSave:
                  ({
                    required status,
                    rating,
                    review,
                    selectedPlatform,
                    hoursPlayed,
                  }) async {
                    savedStatus = status;
                  },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Want to Read'), findsOneWidget);
    expect(find.text('Reading'), findsOneWidget);
    expect(find.text('Watching'), findsNothing);
    expect(find.text('Playing'), findsNothing);

    await tester.tap(find.text('Reading'));
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    expect(savedStatus, 'READING');
  });

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
              onSave:
                  ({
                    required status,
                    rating,
                    review,
                    selectedPlatform,
                    hoursPlayed,
                  }) async {
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
