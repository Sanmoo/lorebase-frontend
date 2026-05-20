import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/core/i18n/date_formatter.dart';

void main() {
  testWidgets('formatLocalizedDate handles empty, invalid, and valid dates', (
    tester,
  ) async {
    late BuildContext capturedContext;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en', 'US'),
        home: Builder(
          builder: (context) {
            capturedContext = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(formatLocalizedDate(capturedContext, null), '—');
    expect(formatLocalizedDate(capturedContext, ''), '—');
    expect(formatLocalizedDate(capturedContext, 'not-a-date'), 'not-a-date');
    expect(formatLocalizedDate(capturedContext, '1995-09-22'), 'Sep 22, 1995');
  });
}
