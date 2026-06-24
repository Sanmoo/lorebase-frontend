import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/social/widgets/social_activity_verb.dart';
import 'package:lorebase/l10n/strings.g.dart';

void main() {
  test('STARTED_PLAYING returns game verb', () async {
    await LocaleSettings.setLocale(AppLocale.enUs);
    expect(
      localizedSocialActivityVerb('STARTED_PLAYING'),
      t.social_activity_started_playing,
    );
  });
}
