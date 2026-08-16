import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/social/data/models/activity_event_model.dart';
import 'package:lorebase/features/social/data/models/social_media_model.dart';
import 'package:lorebase/features/social/data/models/social_user_model.dart';
import 'package:lorebase/features/social/widgets/social_activity_verb.dart';
import 'package:lorebase/l10n/strings.g.dart';

void main() {
  ActivityEventModel bookEvent({String type = 'STARTED_READING'}) =>
      ActivityEventModel(
        eventId: 'evt-1',
        user: const SocialUserModel(userId: 'user-1', displayName: 'Fulano'),
        activityType: type,
        media: const SocialMediaModel(
          mediaId: 'book-1',
          mediaType: 'BOOK',
          title: 'Dom Casmurro',
        ),
        metadata: const <String, dynamic>{},
        createdAt: DateTime(2026, 5, 20),
      );

  test('STARTED_PLAYING returns game verb', () async {
    await LocaleSettings.setLocale(AppLocale.enUs);
    expect(
      localizedSocialActivityVerb('STARTED_PLAYING'),
      t.social_activity_started_playing,
    );
  });

  group('STARTED_READING', () {
    test('returns reading verb', () async {
      await LocaleSettings.setLocale(AppLocale.enUs);
      expect(
        localizedSocialActivityVerb('STARTED_READING'),
        t.social_activity_started_reading,
      );
    });

    test('is localized to reading vocabulary in every locale', () async {
      await LocaleSettings.setLocale(AppLocale.ptBr);
      expect(localizedSocialActivityVerb('STARTED_READING'), 'começou a ler');

      await LocaleSettings.setLocale(AppLocale.en);
      expect(localizedSocialActivityVerb('STARTED_READING'), 'started reading');

      await LocaleSettings.setLocale(AppLocale.enUs);
      expect(localizedSocialActivityVerb('STARTED_READING'), 'started reading');

      await LocaleSettings.setLocale(AppLocale.es);
      expect(localizedSocialActivityVerb('STARTED_READING'), 'empezó a leer');
    });

    test('socialActivityTextFor composes the book sentence', () async {
      await LocaleSettings.setLocale(AppLocale.ptBr);
      expect(
        socialActivityTextFor(bookEvent()),
        'Fulano começou a ler Dom Casmurro',
      );
    });
  });

  group('COMPLETED with book media', () {
    test('uses reading vocabulary', () async {
      await LocaleSettings.setLocale(AppLocale.ptBr);
      expect(
        localizedSocialActivityVerb('COMPLETED', mediaType: 'BOOK'),
        'concluiu a leitura de',
      );
    });

    test('is localized in every locale', () async {
      await LocaleSettings.setLocale(AppLocale.en);
      expect(
        localizedSocialActivityVerb('COMPLETED', mediaType: 'BOOK'),
        'finished reading',
      );

      await LocaleSettings.setLocale(AppLocale.enUs);
      expect(
        localizedSocialActivityVerb('COMPLETED', mediaType: 'BOOK'),
        'finished reading',
      );

      await LocaleSettings.setLocale(AppLocale.es);
      expect(
        localizedSocialActivityVerb('COMPLETED', mediaType: 'BOOK'),
        'terminó de leer',
      );
    });

    test('keeps generic verb for other media types and unknown case', () async {
      await LocaleSettings.setLocale(AppLocale.ptBr);
      expect(localizedSocialActivityVerb('COMPLETED'), 'completou');
      expect(localizedSocialActivityVerb('COMPLETED', mediaType: 'SERIES'), 'completou');
      expect(
        localizedSocialActivityVerb('COMPLETED', mediaType: 'book'),
        'concluiu a leitura de',
      );
    });

    test('socialActivityTextFor composes the completed reading sentence', () async {
      await LocaleSettings.setLocale(AppLocale.ptBr);
      expect(
        socialActivityTextFor(bookEvent(type: 'COMPLETED')),
        'Fulano concluiu a leitura de Dom Casmurro',
      );
    });
  });

  group('socialActivityTextFor with book events', () {
    test('ADDED_TO_LIST with list name uses the list sentence', () async {
      await LocaleSettings.setLocale(AppLocale.ptBr);
      final event = bookEvent(type: 'ADDED_TO_LIST').copyWith(
        metadata: const {'listName': 'Favoritos'},
      );

      expect(
        socialActivityTextFor(event),
        'Fulano adicionou Dom Casmurro à lista Favoritos',
      );
    });

    test('COMPLETED uses the completed verb', () async {
      await LocaleSettings.setLocale(AppLocale.ptBr);
      expect(
        socialActivityTextFor(bookEvent(type: 'COMPLETED')),
        'Fulano concluiu a leitura de Dom Casmurro',
      );
    });
  });
}
