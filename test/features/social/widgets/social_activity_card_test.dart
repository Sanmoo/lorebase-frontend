import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/social/data/models/activity_event_model.dart';
import 'package:lorebase/features/social/data/models/social_media_model.dart';
import 'package:lorebase/features/social/data/models/social_user_model.dart';
import 'package:lorebase/features/social/widgets/social_activity_card.dart';
import 'package:lorebase/l10n/strings.g.dart';

void main() {
  ActivityEventModel event({
    String type = 'RATED',
    Map<String, dynamic>? metadata,
  }) => ActivityEventModel(
    eventId: 'evt-1',
    user: const SocialUserModel(userId: 'user-1', displayName: 'Fulano'),
    activityType: type,
    media: const SocialMediaModel(
      mediaId: 'media-1',
      mediaType: 'SERIES',
      title: 'One Piece',
    ),
    metadata: metadata ?? const {'rating': 8},
    createdAt: DateTime(2026, 5, 20),
  );

  Future<void> pumpCard(
    WidgetTester tester,
    ActivityEventModel event, {
    String? actorLabel,
    VoidCallback? onUserTap,
    VoidCallback? onMediaTap,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SocialActivityCard(
            event: event,
            actorLabel: actorLabel,
            onUserTap: onUserTap ?? () {},
            onMediaTap: onMediaTap ?? () {},
          ),
        ),
      ),
    );
  }

  testWidgets('RATED renders "avaliou" and rating', (tester) async {
    await pumpCard(tester, event());

    expect(find.textContaining('avaliou'), findsOneWidget);
    expect(find.text('⭐ 8/10'), findsOneWidget);
  });

  testWidgets('actorLabel overrides displayed actor name', (tester) async {
    await pumpCard(tester, event(), actorLabel: 'Você');

    expect(find.text('Você'), findsOneWidget);
    expect(find.text('Fulano'), findsNothing);
    expect(find.textContaining('avaliou'), findsOneWidget);
    expect(find.text('One Piece'), findsOneWidget);
  });

  ActivityEventModel bookEvent({String type = 'STARTED_READING'}) =>
      ActivityEventModel(
        eventId: 'evt-book-1',
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

  testWidgets('renders all activity verbs and review metadata fallbacks', (
    tester,
  ) async {
    for (final entry in {
      'REVIEWED': 'escreveu uma review de',
      'COMPLETED': 'completou',
      'STARTED_WATCHING': 'começou',
      'STARTED_PLAYING': 'começou a jogar',
      'DROPPED': 'abandonou',
      'ADDED_TO_LIST': 'adicionou à lista',
      'UNKNOWN': 'interagiu com',
    }.entries) {
      await pumpCard(
        tester,
        event(
          type: entry.key,
          metadata: const {'reviewSnippet': 'Gostei bastante'},
        ),
      );

      expect(find.textContaining(entry.value), findsOneWidget);
      expect(find.text('Gostei bastante'), findsOneWidget);
    }
  });

  testWidgets(
    'ADDED_TO_LIST renders media followed by list name when present',
    (tester) async {
      await pumpCard(
        tester,
        event(type: 'ADDED_TO_LIST', metadata: const {'listName': 'Favoritos'}),
      );

      expect(find.text('Fulano'), findsOneWidget);
      expect(find.text('adicionou'), findsOneWidget);
      expect(find.text('One Piece'), findsOneWidget);
      expect(find.text('à lista Favoritos'), findsOneWidget);
      expect(find.textContaining('adicionou à lista'), findsNothing);
    },
  );

  testWidgets('ADDED_TO_LIST keeps current fallback without list name', (
    tester,
  ) async {
    await pumpCard(
      tester,
      event(type: 'ADDED_TO_LIST', metadata: const {'status': 'WANT_TO_WATCH'}),
    );

    expect(find.textContaining('adicionou à lista'), findsOneWidget);
    expect(find.text('One Piece'), findsOneWidget);
  });

  testWidgets('STARTED_READING book renders reading verb and title', (
    tester,
  ) async {
    await pumpCard(tester, bookEvent());

    expect(find.text('Fulano'), findsOneWidget);
    expect(find.text('começou a ler'), findsOneWidget);
    expect(find.text('Dom Casmurro'), findsOneWidget);
  });

  testWidgets('COMPLETED book uses reading vocabulary', (tester) async {
    await pumpCard(tester, bookEvent(type: 'COMPLETED'));

    expect(find.text('concluiu a leitura de'), findsOneWidget);
    expect(find.text('Dom Casmurro'), findsOneWidget);
  });

  testWidgets('ADDED_TO_LIST book renders list sentence', (tester) async {
    await pumpCard(
      tester,
      bookEvent(type: 'ADDED_TO_LIST').copyWith(
        metadata: const {'listName': 'Favoritos'},
      ),
    );

    expect(find.text('adicionou'), findsOneWidget);
    expect(find.text('à lista Favoritos'), findsOneWidget);
    expect(find.text('Dom Casmurro'), findsOneWidget);
    expect(find.textContaining('adicionou à lista'), findsNothing);
  });

  testWidgets('STARTED_READING book renders English reading verb', (
    tester,
  ) async {
    await tester.runAsync(() => LocaleSettings.setLocale(AppLocale.en));
    await pumpCard(tester, bookEvent());

    expect(find.text('started reading'), findsOneWidget);
    expect(find.text('Dom Casmurro'), findsOneWidget);

    await tester.runAsync(() => LocaleSettings.setLocale(AppLocale.ptBr));
  });
  testWidgets('non-book COMPLETED keeps generic verb', (tester) async {
    await pumpCard(tester, event(type: 'COMPLETED'));

    expect(find.text('completou'), findsOneWidget);
    expect(find.text('One Piece'), findsOneWidget);
  });

  testWidgets('does not render empty review text', (tester) async {
    await pumpCard(tester, event(metadata: const {'review': ''}));

    expect(find.text(''), findsNothing);
  });

  testWidgets('tapping user invokes onUserTap', (tester) async {
    var tapped = false;
    await pumpCard(tester, event(), onUserTap: () => tapped = true);

    await tester.tap(find.text('Fulano'));

    expect(tapped, isTrue);
  });

  testWidgets('tapping media invokes onMediaTap', (tester) async {
    var tapped = false;
    await pumpCard(tester, event(), onMediaTap: () => tapped = true);

    await tester.tap(find.text('One Piece'));

    expect(tapped, isTrue);
  });
}
