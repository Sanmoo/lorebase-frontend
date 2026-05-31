import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lorebase/core/errors/exceptions.dart';
import 'package:lorebase/features/social/data/avatar_image_picker.dart';
import 'package:lorebase/features/social/data/models/activity_event_model.dart';
import 'package:lorebase/features/social/data/models/avatar_upload_file.dart';
import 'package:lorebase/features/social/data/models/discover_user_model.dart';
import 'package:lorebase/features/social/data/models/follow_relationship_model.dart';
import 'package:lorebase/features/social/data/models/paginated_social_response.dart';
import 'package:lorebase/features/social/data/models/public_list_item_model.dart';
import 'package:lorebase/features/social/data/models/social_media_model.dart';
import 'package:lorebase/features/social/data/models/social_profile_model.dart';
import 'package:lorebase/features/social/data/models/social_user_model.dart';
import 'package:lorebase/features/social/data/repositories/social_repository.dart';
import 'package:lorebase/features/social/pages/edit_social_profile_page.dart';
import 'package:lorebase/features/social/pages/social_follow_list_page.dart';
import 'package:lorebase/features/social/pages/social_onboarding_page.dart';
import 'package:lorebase/features/social/pages/social_page.dart';
import 'package:lorebase/features/social/pages/social_profile_page.dart';
import 'package:lorebase/features/social/viewmodels/social_discover_viewmodel.dart';
import 'package:lorebase/features/social/viewmodels/social_follow_list_viewmodel.dart';
import 'package:lorebase/l10n/strings.g.dart';

void main() {
  test('Social discover provider disables automatic retry', () {
    final retry = socialDiscoverViewModelProvider.retry;

    expect(retry, isNotNull);
    expect(retry!(0, Exception('timeout')), isNull);
  });

  testWidgets('Social page missing profile state renders onboarding once', (
    tester,
  ) async {
    final repository = _FakeSocialRepository(missingProfile: true);
    await tester.pumpSocial(const SocialPage(), repository);
    await tester.pumpAndSettle();
    await tester.pump();
    await tester.pump();

    expect(find.text(t.social_create_profile_title), findsOneWidget);
    expect(repository.getMyProfileCallCount, 1);
  });

  testWidgets('Social page checks profile again after leaving missing state', (
    tester,
  ) async {
    final repository = _FakeSocialRepository(missingProfile: true);
    final child = ValueNotifier<Widget>(const SocialPage());
    await tester.pumpSocialHost(child, repository);
    await tester.pumpAndSettle();

    expect(find.text(t.social_create_profile_title), findsOneWidget);
    expect(repository.getMyProfileCallCount, 1);

    child.value = const Text('Home');
    await tester.pumpAndSettle();

    repository.missingProfile = false;
    child.value = const SocialPage();
    await tester.pumpAndSettle();

    expect(repository.getMyProfileCallCount, 2);
    expect(find.text(t.social_create_profile_title), findsNothing);
    expect(find.text(t.social_feed), findsOneWidget);
    expect(find.text(t.social_discover), findsOneWidget);
  });

  testWidgets(
    'Social page existing profile renders compact profile link and tabs',
    (tester) async {
      await tester.pumpSocial(const SocialPage(), _FakeSocialRepository());
      await tester.pumpAndSettle();

      expect(find.text(t.social_my_profile), findsOneWidget);
      expect(find.text('Meu perfil social'), findsNothing);
      expect(find.text(t.social_feed), findsOneWidget);
      expect(find.text(t.social_discover), findsOneWidget);
    },
  );

  testWidgets('Social page empty feed renders empty state CTA', (tester) async {
    await tester.pumpSocial(const SocialPage(), _FakeSocialRepository());
    await tester.pumpAndSettle();

    expect(find.text(t.social_empty_feed_title), findsOneWidget);
    expect(find.text(t.social_empty_feed_body), findsOneWidget);
    expect(find.text(t.social_discover_people_cta), findsOneWidget);
  });

  testWidgets('Social feed renders activity cards when feed has items', (
    tester,
  ) async {
    await tester.pumpSocial(
      const SocialPage(),
      _FakeSocialRepository(feedItems: [_event(title: 'Feed visível')]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Feed visível'), findsOneWidget);
    expect(find.text(t.social_discover_people_cta), findsNothing);
    expect(find.text(t.social_feed_load_error), findsNothing);
  });

  testWidgets('Social feed shows error when feed request fails', (
    tester,
  ) async {
    await tester.pumpSocial(
      const SocialPage(),
      _FakeSocialRepository(feedError: Exception('boom')),
    );
    await tester.pumpAndSettle();

    expect(find.text(t.social_feed_load_error), findsOneWidget);
    expect(find.text(t.social_discover_people_cta), findsNothing);
  });

  testWidgets('Onboarding page privacy choice is required', (tester) async {
    await tester.pumpSocial(
      const SocialOnboardingPage(),
      _FakeSocialRepository(),
    );
    await tester.enterText(find.byType(TextFormField).first, 'Fulano');
    await tester.tap(find.text(t.social_save_profile));
    await tester.pump();

    expect(find.text(t.social_privacy_required), findsOneWidget);
  });

  testWidgets('Onboarding page submit calls saveProfile', (tester) async {
    final repository = _FakeSocialRepository();
    await tester.pumpSocial(const SocialOnboardingPage(), repository);
    await tester.enterText(find.byType(TextFormField).first, 'Fulano');
    await tester.tap(find.text(t.social_public));
    await tester.pump();
    await tester.tap(find.text(t.social_save_profile));
    await tester.pumpAndSettle();

    expect(repository.savedProfile, isTrue);
  });

  testWidgets('Social page refreshes after onboarding creates profile', (
    tester,
  ) async {
    final repository = _FakeSocialRepository(missingProfile: true);
    await tester.pumpSocial(const SocialPage(), repository);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Fulano');
    await tester.tap(find.text(t.social_public));
    await tester.pump();
    await tester.tap(find.text(t.social_save_profile));
    await tester.pumpAndSettle();

    expect(repository.savedProfile, isTrue);
    expect(find.text(t.social_follow_suggestions), findsOneWidget);

    await tester.tap(find.text(t.social_finish));
    await tester.pumpAndSettle();

    expect(find.text(t.social_feed), findsOneWidget);
    expect(find.text(t.social_discover), findsOneWidget);
  });

  testWidgets(
    'Social page keeps onboarding suggestions during profile refresh',
    (tester) async {
      final repository = _FakeSocialRepository(
        missingProfile: true,
        discoverItems: [_discoverUser()],
      );
      await tester.pumpSocial(const SocialPage(), repository);
      await tester.pumpAndSettle();

      repository.pauseNextProfileLoad();
      await tester.enterText(find.byType(TextFormField).first, 'Fulano');
      await tester.tap(find.text(t.social_public));
      await tester.pump();
      await tester.tap(find.text(t.social_save_profile));
      await tester.pump();
      await tester.pump();

      expect(repository.savedProfile, isTrue);
      expect(find.text(t.social_follow_suggestions), findsOneWidget);
      expect(find.text('Ciclano'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text(t.social_create_profile_title), findsNothing);

      repository.resumeProfileLoad();
      await tester.pumpAndSettle();

      expect(find.text(t.social_follow_suggestions), findsOneWidget);
      expect(find.text('Ciclano'), findsOneWidget);
      expect(find.text(t.social_create_profile_title), findsNothing);
    },
  );

  testWidgets(
    'Social page does not show onboarding again after save without finish',
    (tester) async {
      final repository = _FakeSocialRepository(missingProfile: true);
      final child = ValueNotifier<Widget>(const SocialPage());
      await tester.pumpSocialHost(child, repository);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'Fulano');
      await tester.tap(find.text(t.social_public));
      await tester.pump();
      await tester.tap(find.text(t.social_save_profile));
      await tester.pumpAndSettle();

      expect(repository.savedProfile, isTrue);
      expect(find.text(t.social_follow_suggestions), findsOneWidget);
      expect(find.text(t.social_create_profile_title), findsNothing);

      child.value = const Text('Home');
      await tester.pumpAndSettle();

      child.value = const SocialPage();
      await tester.pumpAndSettle();

      expect(find.text(t.social_create_profile_title), findsNothing);
      expect(find.text(t.social_feed), findsOneWidget);
      expect(find.text(t.social_discover), findsOneWidget);
      expect(repository.getMyProfileCallCount, 2);
    },
  );

  testWidgets('Edit social profile loads current profile before saving', (
    tester,
  ) async {
    final repository = _FakeSocialRepository(
      profile: _profile(
        displayName: 'Beltrano',
        avatarUrl: 'https://example.com/avatar.png',
        isPublic: false,
      ),
    );
    await tester.pumpSocial(const EditSocialProfilePage(), repository);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextFormField, 'Beltrano'), findsOneWidget);
    expect(find.text('https://example.com/avatar.png'), findsNothing);
    expect(find.text(t.social_change_photo), findsOneWidget);
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isFalse,
    );

    await tester.tap(find.text(t.social_save_changes));
    await tester.pumpAndSettle();

    expect(repository.savedDisplayName, 'Beltrano');
    expect(repository.savedAvatarUrl, isNull);
    expect(repository.savedIsPublic, isFalse);
    expect(repository.getMyProfileCallCount, 2);
  });

  testWidgets(
    'Edit social profile save returns and refreshes previous profile',
    (tester) async {
      final repository = _FakeSocialRepository(
        profile: _profile(displayName: 'Nome antigo'),
      );
      final observer = _RecordingNavigatorObserver();
      final router = _router(
        const SocialProfilePage(userId: 'me', isMe: true),
        repository,
        observers: [observer],
      );
      await tester.pumpRouter(router);
      await tester.pumpAndSettle();

      expect(find.text('Nome antigo'), findsOneWidget);

      await tester.tap(find.text(t.social_edit_profile));
      await tester.pumpAndSettle();

      expect(find.text(t.social_edit_profile_title), findsOneWidget);
      expect(observer.pushCount, greaterThan(1));

      await tester.enterText(find.byType(TextFormField).first, 'Nome novo');
      await tester.tap(find.text(t.social_save_changes));
      await tester.pumpAndSettle();

      expect(router.routeInformationProvider.value.uri.path, '/');
      expect(observer.popCount, 1);
      expect(repository.savedDisplayName, 'Nome novo');
      expect(find.text(t.social_edit_profile_title), findsNothing);
      expect(find.text('Nome novo'), findsOneWidget);
      expect(find.text('Nome antigo'), findsNothing);
    },
  );

  testWidgets('Edit social profile save failure stays and shows feedback', (
    tester,
  ) async {
    final repository =
        _FakeSocialRepository(profile: _profile(displayName: 'Fulano'))
          ..updateProfileError = const ServerException(
            message: 'Save failed',
            statusCode: 500,
          );
    final observer = _RecordingNavigatorObserver();
    final router = _router(
      const SocialProfilePage(userId: 'me', isMe: true),
      repository,
      observers: [observer],
    );
    await tester.pumpRouter(router);
    await tester.pumpAndSettle();

    await tester.tap(find.text(t.social_edit_profile));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Nome novo');
    await tester.tap(find.text(t.social_save_changes));
    await tester.pumpAndSettle();

    expect(observer.popCount, 0);
    expect(find.text(t.social_edit_profile_title), findsOneWidget);
    expect(find.text(t.social_profile_save_error), findsOneWidget);
  });

  testWidgets('Edit social profile has no avatar URL field and changes photo', (
    tester,
  ) async {
    final repository = _FakeSocialRepository(
      profile: _profile(avatarUrl: 'https://example.com/avatar.png'),
    );
    await tester.pumpSocial(const EditSocialProfilePage(), repository);
    await tester.pumpAndSettle();

    expect(find.text(t.social_avatar_url), findsNothing);
    expect(find.text(t.social_change_photo), findsOneWidget);

    await tester.tap(find.text(t.social_change_photo));
    await tester.pumpAndSettle();
    expect(find.text(t.social_choose_from_gallery), findsOneWidget);
    expect(find.text(t.social_take_photo), findsOneWidget);

    await tester.tap(find.text(t.social_choose_from_gallery));
    await tester.pumpAndSettle();

    expect(repository.avatarUploadCallCount, 1);
    expect(repository.lastAvatarFilename, 'avatar.png');
    expect(find.text(t.social_avatar_updated_success), findsOneWidget);
  });

  testWidgets('Own profile avatar opens source choices and gallery uploads', (
    tester,
  ) async {
    final repository = _FakeSocialRepository();
    await tester.pumpSocial(
      const SocialProfilePage(userId: 'me', isMe: true),
      repository,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('socialProfileAvatarAction')));
    await tester.pumpAndSettle();
    expect(find.text(t.social_choose_from_gallery), findsOneWidget);
    expect(find.text(t.social_take_photo), findsOneWidget);
    expect(find.text(t.social_cancel), findsOneWidget);

    await tester.tap(find.text(t.social_choose_from_gallery));
    await tester.pumpAndSettle();

    expect(repository.avatarUploadCallCount, 1);
    expect(repository.lastAvatarFilename, 'avatar.png');
    expect(find.text(t.social_avatar_updated_success), findsOneWidget);
  });

  testWidgets(
    'Own profile cancellation after success does not show stale success',
    (tester) async {
      final repository = _FakeSocialRepository();
      final picker = _SequentialAvatarPickerClient([
        XFile.fromData(
          Uint8List.fromList([1, 2, 3]),
          name: 'avatar.png',
          mimeType: 'image/png',
        ),
        null,
      ]);
      await tester.pumpSocial(
        const SocialProfilePage(userId: 'me', isMe: true),
        repository,
        avatarPickerClient: picker,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('socialProfileAvatarAction')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(t.social_choose_from_gallery));
      await tester.pumpAndSettle();
      expect(find.text(t.social_avatar_updated_success), findsOneWidget);

      ScaffoldMessenger.of(
        tester.element(find.byType(SocialProfilePage)),
      ).clearSnackBars();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('socialProfileAvatarAction')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(t.social_choose_from_gallery));
      await tester.pumpAndSettle();

      expect(repository.avatarUploadCallCount, 1);
      expect(find.text(t.social_avatar_updated_success), findsNothing);
    },
  );

  testWidgets(
    'Profile page renders Activity, Lists, Followers, Following tabs',
    (tester) async {
      await tester.pumpSocial(
        const SocialProfilePage(userId: 'user-1'),
        _FakeSocialRepository(),
      );
      await tester.pumpAndSettle();

      expect(find.text(t.social_activity), findsOneWidget);
      expect(find.text(t.social_lists), findsOneWidget);
      expect(find.text(t.social_followers), findsOneWidget);
      expect(find.text(t.social_following), findsOneWidget);
    },
  );

  testWidgets('Profile Lists tab loads public lists by status sections', (
    tester,
  ) async {
    final repository = _FakeSocialRepository(
      publicListItemsByStatus: {
        'PLAN_TO_WATCH': [
          _publicListItem(
            mediaId: 'movie-1',
            status: 'PLAN_TO_WATCH',
            title: 'Interestelar',
          ),
        ],
        'WATCHING': [
          _publicListItem(
            mediaId: 'series-1',
            status: 'WATCHING',
            title: 'Reacher',
            mediaType: 'SERIES',
          ),
        ],
        'COMPLETED': [
          _publicListItem(
            mediaId: 'movie-2',
            status: 'COMPLETED',
            title: 'Batman Begins',
          ),
        ],
        'DROPPED': [
          _publicListItem(
            mediaId: 'series-2',
            status: 'DROPPED',
            title: 'Série abandonada',
            mediaType: 'SERIES',
          ),
        ],
      },
    );
    await tester.pumpSocial(
      const SocialProfilePage(userId: 'user-1'),
      repository,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(t.social_lists));
    await tester.pumpAndSettle();

    expect(repository.publicListCalls, [
      'user-1:PLAN_TO_WATCH',
      'user-1:WATCHING',
      'user-1:COMPLETED',
      'user-1:DROPPED',
    ]);
    expect(find.text(t.social_status_plan_to_watch), findsOneWidget);
    expect(find.text(t.social_status_watching), findsOneWidget);
    expect(find.text(t.social_status_completed), findsOneWidget);
    expect(find.text(t.social_status_dropped), findsOneWidget);
    expect(find.text('Interestelar'), findsOneWidget);
    expect(find.text('Reacher'), findsOneWidget);
    expect(find.text('Batman Begins'), findsOneWidget);
    expect(find.text('Série abandonada'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is SizedBox && widget.height == 24,
      ),
      findsAtLeastNWidgets(3),
    );
  });

  testWidgets('Profile Lists tab degrades only the failed status section', (
    tester,
  ) async {
    final repository = _FakeSocialRepository(
      publicListItemsByStatus: {
        'PLAN_TO_WATCH': [
          _publicListItem(
            mediaId: 'movie-1',
            status: 'PLAN_TO_WATCH',
            title: 'Interestelar',
          ),
        ],
        'COMPLETED': [
          _publicListItem(
            mediaId: 'movie-2',
            status: 'COMPLETED',
            title: 'Batman Begins',
          ),
        ],
      },
      publicListErrorsByStatus: const {
        'WATCHING': ServerException(message: 'Failed', statusCode: 500),
      },
    );
    await tester.pumpSocial(
      const SocialProfilePage(userId: 'user-1'),
      repository,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(t.social_lists));
    await tester.pumpAndSettle();

    expect(find.text('Interestelar'), findsOneWidget);
    expect(find.text('Batman Begins'), findsOneWidget);
    expect(
      find.text(t.social_section_load_error(section: t.social_status_watching)),
      findsOneWidget,
    );
    expect(find.text(t.social_profile_unavailable), findsNothing);
  });

  testWidgets('Profile page unavailable profile shows friendly message', (
    tester,
  ) async {
    await tester.pumpSocial(
      const SocialProfilePage(userId: 'missing'),
      _FakeSocialRepository(unavailableProfile: true),
    );
    await tester.pumpAndSettle();

    expect(find.text(t.social_profile_unavailable), findsOneWidget);
  });

  testWidgets('Profile Activity tab renders visible activity cards', (
    tester,
  ) async {
    await tester.pumpSocial(
      const SocialProfilePage(userId: 'me', isMe: true),
      _FakeSocialRepository(activityItems: [_event()]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Fulano'), findsWidgets);
    expect(find.text('Série Teste'), findsOneWidget);
    expect(find.text(t.social_empty_public_activity), findsNothing);
    expect(find.text(t.social_profile_unavailable), findsNothing);
  });

  testWidgets(
    'Profile Activity tab shows error instead of empty state on activity failure',
    (tester) async {
      await tester.pumpSocial(
        const SocialProfilePage(userId: 'me', isMe: true),
        _FakeSocialRepository(
          activityError: const ServerException(
            message: 'Activity failed',
            statusCode: 500,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(t.social_profile_activity_load_error), findsOneWidget);
      expect(find.text(t.social_empty_public_activity), findsNothing);
      expect(find.text(t.social_profile_unavailable), findsNothing);
    },
  );

  testWidgets('My profile renders header when activity and lists are empty', (
    tester,
  ) async {
    await tester.pumpSocial(
      const SocialProfilePage(userId: 'me', isMe: true),
      _FakeSocialRepository(),
    );
    await tester.pumpAndSettle();

    expect(find.text('Fulano'), findsOneWidget);
    expect(find.text(t.social_edit_profile), findsOneWidget);
    expect(find.text('0 seguidores'), findsOneWidget);
    expect(find.text('0 seguindo'), findsOneWidget);
    expect(find.text(t.social_empty_public_activity), findsOneWidget);
    expect(find.text(t.social_profile_unavailable), findsNothing);
  });

  testWidgets('Profile followers failure shows error instead of spinner', (
    tester,
  ) async {
    final repository = _FakeSocialRepository()
      ..followersError = const ServerException(
        message: 'Route not found',
        statusCode: 404,
      );
    await tester.pumpSocial(
      const SocialProfilePage(userId: 'me', isMe: true),
      repository,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(t.social_followers));
    await tester.pumpAndSettle();

    expect(find.text(t.social_list_load_error), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Profile followers tab shows real users and navigates', (
    tester,
  ) async {
    final repository = _FakeSocialRepository(
      followersItems: [
        _followUser(),
        _followUser(userId: 'user-blank', username: '   ', displayName: ''),
      ],
    );
    final router = _router(
      const SocialProfilePage(userId: 'me', isMe: true),
      repository,
    );
    await tester.pumpRouter(router);
    await tester.pumpAndSettle();

    await tester.tap(find.text(t.social_followers));
    await tester.pumpAndSettle();

    expect(find.text('Ciclano Silva'), findsOneWidget);
    expect(find.text('@ciclano'), findsOneWidget);
    expect(find.text('@   '), findsNothing);
    expect(find.byIcon(Icons.person), findsOneWidget);
    expect(find.text('Usuário'), findsNothing);

    await tester.tap(find.text('Ciclano Silva'));
    await tester.pumpAndSettle();

    expect(
      router.routeInformationProvider.value.uri.path,
      '/social/profile/user-3',
    );
  });

  testWidgets('Standalone following page shows real users and navigates', (
    tester,
  ) async {
    final repository = _FakeSocialRepository(
      followingItems: [
        _followUser(
          userId: 'user-4',
          username: ' beltrano ',
          displayName: 'Beltrano Lima',
          isFollowing: true,
        ),
        _followUser(
          userId: 'user-blank',
          username: '   ',
          displayName: '',
          isFollowing: true,
        ),
      ],
    );
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => ProviderScope(
            retry: (_, _) => null,
            overrides: [
              socialRepositoryProvider.overrideWithValue(repository),
              avatarImagePickerProvider.overrideWithValue(
                AvatarImagePicker(_FakeAvatarPickerClient()),
              ),
            ],
            child: const SocialFollowListPage(
              userId: 'me',
              kind: SocialFollowListKind.following,
            ),
          ),
        ),
        GoRoute(
          path: '/social/profile/:userId',
          builder: (context, state) =>
              Text('profile ${state.pathParameters['userId']}'),
        ),
      ],
    );
    await tester.pumpRouter(router);
    await tester.pumpAndSettle();

    expect(find.text('Beltrano Lima'), findsOneWidget);
    expect(find.text('@beltrano'), findsOneWidget);
    expect(find.text('@ beltrano '), findsNothing);
    expect(find.text('@   '), findsNothing);
    expect(find.byIcon(Icons.person), findsOneWidget);
    expect(find.text('Usuário'), findsNothing);

    await tester.tap(find.text('Beltrano Lima'));
    await tester.pumpAndSettle();

    expect(
      router.routeInformationProvider.value.uri.path,
      '/social/profile/user-4',
    );
  });

  testWidgets('Feed activity cards navigate to user and media', (tester) async {
    final router = _router(
      const SocialPage(),
      _FakeSocialRepository(feedItems: [_event()]),
    );
    await tester.pumpRouter(router);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Fulano').last);
    await tester.pumpAndSettle();
    expect(
      router.routeInformationProvider.value.uri.path,
      '/social/profile/user-1',
    );

    router.go('/');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Série Teste'));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/series/123');
  });

  testWidgets('Discover cards navigate to user', (tester) async {
    final router = _router(
      const SocialPage(),
      _FakeSocialRepository(discoverItems: [_discoverUser()]),
    );
    await tester.pumpRouter(router);
    await tester.pumpAndSettle();

    await tester.tap(find.text(t.social_discover));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ciclano'));
    await tester.pumpAndSettle();

    expect(
      router.routeInformationProvider.value.uri.path,
      '/social/profile/user-2',
    );
  });

  testWidgets(
    'Discover follow shows loading and updates to followed on success',
    (tester) async {
      final repository = _FakeSocialRepository(
        discoverItems: [_discoverUser()],
      );
      repository.pauseNextFollow();
      await tester.pumpSocial(const SocialPage(), repository);
      await tester.pumpAndSettle();

      await tester.tap(find.text(t.social_discover));
      await tester.pumpAndSettle();

      await tester.tap(find.text(t.social_follow));
      await tester.pump();

      expect(repository.followedUserIds, ['user-2']);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        find.bySemanticsLabel(t.social_following_user_semantics),
        findsOneWidget,
      );
      expect(find.text(t.social_follow), findsNothing);

      repository.resumeFollow();
      await tester.pumpAndSettle();

      expect(find.text(t.social_following_action), findsOneWidget);
      expect(find.text(t.social_follow_error), findsNothing);
    },
  );

  testWidgets('Discover follow failure shows feedback and restores button', (
    tester,
  ) async {
    final repository = _FakeSocialRepository(discoverItems: [_discoverUser()])
      ..followError = const ServerException(
        message: 'Follow failed',
        statusCode: 500,
      );
    await tester.pumpSocial(const SocialPage(), repository);
    await tester.pumpAndSettle();

    await tester.tap(find.text(t.social_discover));
    await tester.pumpAndSettle();

    await tester.tap(find.text(t.social_follow));
    await tester.pumpAndSettle();

    expect(repository.followedUserIds, ['user-2']);
    expect(find.text(t.social_follow), findsOneWidget);
    expect(find.text(t.social_following_action), findsNothing);
    expect(find.text(t.social_follow_error), findsOneWidget);
  });

  testWidgets('Discover timeout shows retry and recovers after tapping it', (
    tester,
  ) async {
    final repository = _FakeSocialRepository(
      discoverItems: [_discoverUser()],
      discoverErrors: const [
        ServerException(message: 'upstream request timed out', statusCode: 504),
      ],
    );
    await tester.pumpSocial(const SocialPage(), repository);
    await tester.pumpAndSettle();

    await tester.tap(find.text(t.social_discover));
    await tester.pumpAndSettle();

    expect(find.text(t.social_discover_timeout), findsOneWidget);
    expect(find.text(t.social_try_again), findsOneWidget);
    expect(repository.discoverCallCount, 1);

    await tester.tap(find.text(t.social_try_again));
    await tester.pumpAndSettle();

    expect(repository.discoverCallCount, 2);
    expect(find.text('Ciclano'), findsOneWidget);
    expect(find.text(t.social_discover_timeout), findsNothing);
  });

  testWidgets('Profile edit and activity cards navigate', (tester) async {
    final router = _router(
      const SocialProfilePage(userId: 'me', isMe: true),
      _FakeSocialRepository(activityItems: [_event(mediaType: 'MOVIE')]),
    );
    await tester.pumpRouter(router);
    await tester.pumpAndSettle();

    expect(find.text('Você'), findsOneWidget);
    expect(find.text('Fulano'), findsOneWidget);

    await tester.tap(find.text(t.social_edit_profile));
    await tester.pumpAndSettle();
    expect(find.text(t.social_edit_profile_title), findsOneWidget);

    router.go('/');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Você'));
    await tester.pumpAndSettle();
    expect(
      router.routeInformationProvider.value.uri.path,
      '/social/profile/user-1',
    );

    router.go('/');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Série Teste'));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/movies/123');
  });

  testWidgets('Other profile activity cards use profile display name', (
    tester,
  ) async {
    final router = _router(
      const SocialProfilePage(userId: 'other-user'),
      _FakeSocialRepository(
        profile: _profile(userId: 'other-user', displayName: 'Maria Social'),
        activityItems: [
          _event(mediaType: 'MOVIE', actorDisplayName: 'Raw Event Actor'),
        ],
      ),
    );

    await tester.pumpRouter(router);
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(Card),
        matching: find.text('Maria Social'),
      ),
      findsOneWidget,
    );
    expect(find.text('Raw Event Actor'), findsNothing);
    expect(find.text('Você'), findsNothing);
  });

  testWidgets('Onboarding save shows suggestions until finished', (
    tester,
  ) async {
    var created = false;
    var finished = false;
    final repository = _FakeSocialRepository(discoverItems: [_discoverUser()]);
    await tester.pumpSocial(
      SocialOnboardingPage(
        onProfileCreated: () => created = true,
        onFinish: () => finished = true,
      ),
      repository,
    );

    await tester.enterText(find.byType(TextFormField).first, 'Fulano');
    await tester.tap(find.text(t.social_public));
    await tester.pump();
    await tester.tap(find.text(t.social_save_profile));
    await tester.pumpAndSettle();

    expect(created, isTrue);
    expect(finished, isFalse);
    expect(find.text(t.social_follow_suggestions), findsOneWidget);
    expect(find.text('Ciclano'), findsOneWidget);

    await tester.tap(find.text(t.social_finish));
    expect(finished, isTrue);
  });
}

extension on WidgetTester {
  Future<void> pumpSocial(
    Widget child,
    SocialRepository repository, {
    AvatarPickerClient? avatarPickerClient,
  }) {
    return pumpWidget(
      TranslationProvider(
        child: ProviderScope(
          retry: (_, _) => null,
          overrides: [
            socialRepositoryProvider.overrideWithValue(repository),
            avatarImagePickerProvider.overrideWithValue(
              AvatarImagePicker(
                avatarPickerClient ?? _FakeAvatarPickerClient(),
              ),
            ),
          ],
          child: MaterialApp(home: Scaffold(body: child)),
        ),
      ),
    );
  }

  Future<void> pumpSocialHost(
    ValueNotifier<Widget> child,
    SocialRepository repository,
  ) {
    return pumpWidget(
      TranslationProvider(
        child: ProviderScope(
          retry: (_, _) => null,
          overrides: [
            socialRepositoryProvider.overrideWithValue(repository),
            avatarImagePickerProvider.overrideWithValue(
              AvatarImagePicker(_FakeAvatarPickerClient()),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ValueListenableBuilder<Widget>(
                valueListenable: child,
                builder: (context, value, _) => value,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> pumpRouter(GoRouter router) {
    return pumpWidget(
      TranslationProvider(child: MaterialApp.router(routerConfig: router)),
    );
  }
}

GoRouter _router(
  Widget child,
  SocialRepository repository, {
  List<NavigatorObserver> observers = const [],
}) {
  return GoRouter(
    initialLocation: '/',
    observers: observers,
    routes: [
      ShellRoute(
        builder: (context, state, child) => ProviderScope(
          retry: (_, _) => null,
          overrides: [
            socialRepositoryProvider.overrideWithValue(repository),
            avatarImagePickerProvider.overrideWithValue(
              AvatarImagePicker(_FakeAvatarPickerClient()),
            ),
          ],
          child: Scaffold(body: child),
        ),
        routes: [
          GoRoute(path: '/', builder: (context, state) => child),
          GoRoute(
            path: '/social/profile/edit',
            builder: (context, state) => const EditSocialProfilePage(),
          ),
          GoRoute(
            path: '/social/profile/:userId',
            builder: (context, state) =>
                Text('profile ${state.pathParameters['userId']}'),
          ),
          GoRoute(
            path: '/series/:tmdbId',
            builder: (context, state) =>
                Text('series ${state.pathParameters['tmdbId']}'),
          ),
          GoRoute(
            path: '/movies/:tmdbId',
            builder: (context, state) =>
                Text('movie ${state.pathParameters['tmdbId']}'),
          ),
        ],
      ),
    ],
  );
}

class _SequentialAvatarPickerClient implements AvatarPickerClient {
  _SequentialAvatarPickerClient(this._files);

  final List<XFile?> _files;

  @override
  Future<XFile?> pickImage({required ImageSource source}) async {
    return _files.removeAt(0);
  }
}

class _FakeAvatarPickerClient implements AvatarPickerClient {
  @override
  Future<XFile?> pickImage({required ImageSource source}) async {
    return XFile.fromData(
      Uint8List.fromList([1, 2, 3]),
      name: 'avatar.png',
      mimeType: 'image/png',
    );
  }
}

class _RecordingNavigatorObserver extends NavigatorObserver {
  int pushCount = 0;
  int popCount = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushCount += 1;
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    popCount += 1;
    super.didPop(route, previousRoute);
  }
}

class _FakeSocialRepository implements SocialRepository {
  _FakeSocialRepository({
    this.missingProfile = false,
    this.unavailableProfile = false,
    this.profile,
    this.feedItems = const [],
    this.feedError,
    this.discoverItems = const [],
    this.activityItems = const [],
    this.activityError,
    this.followersItems = const [],
    this.followingItems = const [],
    List<Object> discoverErrors = const [],
    this.publicListItemsByStatus = const {},
    this.publicListErrorsByStatus = const {},
  }) : _discoverErrors = List<Object>.from(discoverErrors);

  bool missingProfile;
  final bool unavailableProfile;
  final SocialProfileModel? profile;
  SocialProfileModel? updatedProfile;
  final List<ActivityEventModel> feedItems;
  final Object? feedError;
  final List<DiscoverUserModel> discoverItems;
  final List<ActivityEventModel> activityItems;
  final Object? activityError;
  final List<FollowRelationshipModel> followersItems;
  final List<FollowRelationshipModel> followingItems;
  final Map<String, List<PublicListItemModel>> publicListItemsByStatus;
  final Map<String, Object> publicListErrorsByStatus;
  final publicListCalls = <String>[];
  final List<Object> _discoverErrors;
  int discoverCallCount = 0;
  bool savedProfile = false;
  int getMyProfileCallCount = 0;
  final followedUserIds = <String>[];
  Object? followError;
  Object? updateProfileError;
  Object? followersError;
  Completer<void>? _profileLoadCompleter;
  Completer<void>? _followCompleter;
  String? savedDisplayName;
  String? savedAvatarUrl;
  bool? savedIsPublic;
  int avatarUploadCallCount = 0;
  String? lastAvatarFilename;

  void pauseNextProfileLoad() {
    _profileLoadCompleter = Completer<void>();
  }

  void resumeProfileLoad() {
    _profileLoadCompleter?.complete();
    _profileLoadCompleter = null;
  }

  void pauseNextFollow() {
    _followCompleter = Completer<void>();
  }

  void resumeFollow() {
    _followCompleter?.complete();
    _followCompleter = null;
  }

  @override
  Future<SocialProfileModel> updateMyAvatar({
    required AvatarUploadFile file,
  }) async {
    avatarUploadCallCount += 1;
    lastAvatarFilename = file.filename.isEmpty ? 'avatar.png' : file.filename;
    updatedProfile = (profile ?? _profile()).copyWith(avatarUrl: null);
    return updatedProfile!;
  }

  @override
  Future<SocialProfileModel> getMyProfile() async {
    getMyProfileCallCount += 1;
    final profileLoadCompleter = _profileLoadCompleter;
    if (profileLoadCompleter != null) {
      await profileLoadCompleter.future;
    }
    if (missingProfile) {
      throw const ServerException(message: 'Missing', statusCode: 404);
    }
    return updatedProfile ?? profile ?? _profile();
  }

  @override
  Future<SocialProfileModel> updateMyProfile({
    required String displayName,
    String? avatarUrl,
    required bool isPublic,
  }) async {
    savedProfile = true;
    missingProfile = false;
    savedDisplayName = displayName;
    savedAvatarUrl = avatarUrl;
    savedIsPublic = isPublic;
    final error = updateProfileError;
    if (error != null) {
      throw error;
    }
    updatedProfile = _profile(
      displayName: displayName,
      avatarUrl: avatarUrl,
      isPublic: isPublic,
    );
    return updatedProfile!;
  }

  @override
  Future<SocialProfileModel> getProfile(String userId) async {
    if (unavailableProfile) {
      throw const ServerException(message: 'Unavailable', statusCode: 404);
    }
    return profile ?? _profile(userId: userId);
  }

  @override
  Future<PaginatedSocialResponse<ActivityEventModel>> getFeed({
    int limit = 20,
    String? cursor,
  }) async {
    final error = feedError;
    if (error != null) {
      throw error;
    }
    return _page(feedItems);
  }

  @override
  Future<PaginatedSocialResponse<DiscoverUserModel>> discoverUsers({
    int limit = 20,
    String? cursor,
  }) async {
    discoverCallCount += 1;
    if (_discoverErrors.isNotEmpty) {
      final error = _discoverErrors.removeAt(0);
      throw error;
    }
    return _page(discoverItems);
  }

  @override
  Future<PaginatedSocialResponse<ActivityEventModel>> getUserActivity(
    String userId, {
    int limit = 20,
    String? cursor,
  }) async {
    final error = activityError;
    if (error != null) {
      throw error;
    }
    return _page(activityItems);
  }

  @override
  Future<PaginatedSocialResponse<FollowRelationshipModel>> getFollowers(
    String userId, {
    int limit = 20,
    String? cursor,
  }) async {
    final error = followersError;
    if (error != null) {
      throw error;
    }
    return _page(followersItems);
  }

  @override
  Future<PaginatedSocialResponse<FollowRelationshipModel>> getFollowing(
    String userId, {
    int limit = 20,
    String? cursor,
  }) async => _page(followingItems);

  @override
  Future<PaginatedSocialResponse<PublicListItemModel>> getPublicLists(
    String userId, {
    String? status,
    String? mediaType,
    int limit = 20,
    String? cursor,
  }) async {
    publicListCalls.add('$userId:$status');
    final error = publicListErrorsByStatus[status];
    if (error != null) {
      throw error;
    }
    return _page(publicListItemsByStatus[status] ?? const []);
  }

  @override
  Future<void> followUser(String userId) async {
    followedUserIds.add(userId);
    final followCompleter = _followCompleter;
    if (followCompleter != null) {
      await followCompleter.future;
    }
    final error = followError;
    if (error != null) {
      throw error;
    }
  }

  @override
  Future<void> unfollowUser(String userId) async {}
}

PaginatedSocialResponse<T> _page<T>(List<T> items) =>
    PaginatedSocialResponse<T>(items: items, nextCursor: null, hasMore: false);

SocialProfileModel _profile({
  String userId = 'user-1',
  String displayName = 'Fulano',
  String? avatarUrl,
  bool isPublic = true,
}) {
  final now = DateTime.utc(2026, 5, 20);
  return SocialProfileModel(
    userId: userId,
    displayName: displayName,
    avatarUrl: avatarUrl,
    isPublic: isPublic,
    followingCount: 0,
    followerCount: 0,
    isFollowedByMe: false,
    createdAt: now,
    updatedAt: now,
  );
}

ActivityEventModel _event({
  String mediaType = 'SERIES',
  String title = 'Série Teste',
  String actorDisplayName = 'Fulano',
}) {
  return ActivityEventModel(
    eventId: 'event-1',
    user: SocialUserModel(userId: 'user-1', displayName: actorDisplayName),
    activityType: 'RATED',
    media: SocialMediaModel(mediaId: '123', mediaType: mediaType, title: title),
    createdAt: DateTime.utc(2026, 5, 20),
  );
}

FollowRelationshipModel _followUser({
  String userId = 'user-3',
  String? username = 'ciclano',
  String displayName = 'Ciclano Silva',
  String? avatarUrl,
  bool isFollowing = false,
}) {
  return FollowRelationshipModel(
    userId: userId,
    username: username,
    displayName: displayName,
    avatarUrl: avatarUrl,
    isFollowing: isFollowing,
  );
}

DiscoverUserModel _discoverUser() {
  return const DiscoverUserModel(
    userId: 'user-2',
    displayName: 'Ciclano',
    affinityScore: 0.75,
    commonGenres: [],
    commonMedia: [],
    isFollowedByMe: false,
  );
}

PublicListItemModel _publicListItem({
  required String mediaId,
  required String status,
  required String title,
  String mediaType = 'MOVIE',
}) {
  return PublicListItemModel(
    mediaId: mediaId,
    mediaType: mediaType,
    status: status,
    media: SocialMediaModel(
      mediaId: mediaId,
      mediaType: mediaType,
      title: title,
    ),
  );
}
