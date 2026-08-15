import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/core/widgets/media_type_toggle.dart';
import 'package:lorebase/features/tracking/data/models/media_type.dart';
import 'package:lorebase/l10n/strings.g.dart';

Future<void> main() async {
  await LocaleSettings.setLocale(AppLocale.enUs);

  testWidgets('renders both labels and forwards selection', (tester) async {
    MediaType? selected;

    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: MediaTypeToggle(
              selectedType: MediaType.series,
              onChanged: (value) => selected = value,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Series'), findsOneWidget);
    expect(find.text('Movies'), findsOneWidget);
    expect(find.text('Games'), findsOneWidget);
    expect(find.text('Books'), findsOneWidget);

    await tester.tap(find.text('Movies'));
    await tester.pumpAndSettle();
    expect(selected, MediaType.movie);

    await tester.tap(find.text('Books'));
    await tester.pumpAndSettle();

    expect(selected, MediaType.book);
  });
}
