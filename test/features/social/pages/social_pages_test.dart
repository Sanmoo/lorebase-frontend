import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lorebase/core/errors/exceptions.dart';
import 'package:lorebase/features/social/data/models/activity_event_model.dart';
import 'package:lorebase/features/social/data/models/discover_user_model.dart';
import 'package:lorebase/features/social/data/models/follow_relationship_model.dart';
import 'package:lorebase/features/social/data/models/paginated_social_response.dart';
import 'package:lorebase/features/social/data/models/public_list_item_model.dart';
import 'package:lorebase/features/social/data/models/social_media_model.dart';
import 'package:lorebase/features/social/data/models/social_profile_model.dart';
import 'package:lorebase/features/social/data/models/social_user_model.dart';
import 'package:lorebase/features/social/data/repositories/social_repository.dart';
import 'package:lorebase/features/social/pages/edit_social_profile_page.dart';
import 'package:lorebase/features/social/pages/social_onboarding_page.dart';
import 'package:lorebase/features/social/pages/social_page.dart';
import 'package:lorebase/features/social/pages/social_profile_page.dart';
import 'package:lorebase/features/social/viewmodels/social_discover_viewmodel.dart';

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

    expect(find.text('Crie seu perfil social'), findsOneWidget);
    expect(repository.getMyProfileCallCount, 1);
  });

  testWidgets('Social page checks profile again after leaving missing state', (
    tester,
  ) async {
    final repository = _FakeSocialRepository(missingProfile: true);
    final child = ValueNotifier<Widget>(const SocialPage());
    await tester.pumpSocialHost(child, repository);
    await tester.pumpAndSettle();

    expect(find.text('Crie seu perfil social'), findsOneWidget);
    expect(repository.getMyProfileCallCount, 1);

    child.value = const Text('Home');
    await tester.pumpAndSettle();

    repository.missingProfile = false;
    child.value = const SocialPage();
    await tester.pumpAndSettle();

    expect(repository.getMyProfileCallCount, 2);
    expect(find.text('Crie seu perfil social'), findsNothing);
    expect(find.text('Feed'), findsOneWidget);
    expect(find.text('Discover'), findsOneWidget);
  });

  testWidgets(
    'Social page existing profile renders compact profile link and tabs',
    (tester) async {
      await tester.pumpSocial(const SocialPage(), _FakeSocialRepository());
      await tester.pumpAndSettle();

      expect(find.text('Meu perfil →'), findsOneWidget);
      expect(find.text('Meu perfil social'), findsNothing);
      expect(find.text('Feed'), findsOneWidget);
      expect(find.text('Discover'), findsOneWidget);
    },
  );

  testWidgets('Social page empty feed renders CTA', (tester) async {
    await tester.pumpSocial(const SocialPage(), _FakeSocialRepository());
    await tester.pumpAndSettle();

    expect(find.text('Descobrir pessoas'), findsOneWidget);
  });

  testWidgets('Onboarding page privacy choice is required', (tester) async {
    await tester.pumpSocial(
      const SocialOnboardingPage(),
      _FakeSocialRepository(),
    );
    await tester.enterText(find.byType(TextFormField).first, 'Fulano');
    await tester.tap(find.text('Salvar perfil'));
    await tester.pump();

    expect(find.text('Escolha a privacidade do perfil'), findsOneWidget);
  });

  testWidgets('Onboarding page submit calls saveProfile', (tester) async {
    final repository = _FakeSocialRepository();
    await tester.pumpSocial(const SocialOnboardingPage(), repository);
    await tester.enterText(find.byType(TextFormField).first, 'Fulano');
    await tester.tap(find.text('Público'));
    await tester.pump();
    await tester.tap(find.text('Salvar perfil'));
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
    await tester.tap(find.text('Público'));
    await tester.pump();
    await tester.tap(find.text('Salvar perfil'));
    await tester.pumpAndSettle();

    expect(repository.savedProfile, isTrue);
    expect(find.text('Sugestões para seguir'), findsOneWidget);

    await tester.tap(find.text('Finalizar'));
    await tester.pumpAndSettle();

    expect(find.text('Feed'), findsOneWidget);
    expect(find.text('Discover'), findsOneWidget);
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
      await tester.tap(find.text('Público'));
      await tester.pump();
      await tester.tap(find.text('Salvar perfil'));
      await tester.pump();
      await tester.pump();

      expect(repository.savedProfile, isTrue);
      expect(find.text('Sugestões para seguir'), findsOneWidget);
      expect(find.text('Ciclano'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Crie seu perfil social'), findsNothing);

      repository.resumeProfileLoad();
      await tester.pumpAndSettle();

      expect(find.text('Sugestões para seguir'), findsOneWidget);
      expect(find.text('Ciclano'), findsOneWidget);
      expect(find.text('Crie seu perfil social'), findsNothing);
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
      await tester.tap(find.text('Público'));
      await tester.pump();
      await tester.tap(find.text('Salvar perfil'));
      await tester.pumpAndSettle();

      expect(repository.savedProfile, isTrue);
      expect(find.text('Sugestões para seguir'), findsOneWidget);
      expect(find.text('Crie seu perfil social'), findsNothing);

      child.value = const Text('Home');
      await tester.pumpAndSettle();

      child.value = const SocialPage();
      await tester.pumpAndSettle();

      expect(find.text('Crie seu perfil social'), findsNothing);
      expect(find.text('Feed'), findsOneWidget);
      expect(find.text('Discover'), findsOneWidget);
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
    expect(
      find.widgetWithText(TextFormField, 'https://example.com/avatar.png'),
      findsOneWidget,
    );
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isFalse,
    );

    await tester.tap(find.text('Salvar alterações'));
    await tester.pumpAndSettle();

    expect(repository.savedDisplayName, 'Beltrano');
    expect(repository.savedAvatarUrl, 'https://example.com/avatar.png');
    expect(repository.savedIsPublic, isFalse);
    expect(repository.getMyProfileCallCount, 2);
  });

  testWidgets(
    'Profile page renders Activity, Lists, Followers, Following tabs',
    (tester) async {
      await tester.pumpSocial(
        const SocialProfilePage(userId: 'user-1'),
        _FakeSocialRepository(),
      );
      await tester.pumpAndSettle();

      expect(find.text('Activity'), findsOneWidget);
      expect(find.text('Lists'), findsOneWidget);
      expect(find.text('Followers'), findsOneWidget);
      expect(find.text('Following'), findsOneWidget);
    },
  );

  testWidgets('Profile page unavailable profile shows friendly message', (
    tester,
  ) async {
    await tester.pumpSocial(
      const SocialProfilePage(userId: 'missing'),
      _FakeSocialRepository(unavailableProfile: true),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Este perfil não está disponível no momento.'),
      findsOneWidget,
    );
  });

  testWidgets('My profile renders header when activity and lists are empty', (
    tester,
  ) async {
    await tester.pumpSocial(
      const SocialProfilePage(userId: 'me', isMe: true),
      _FakeSocialRepository(),
    );
    await tester.pumpAndSettle();

    expect(find.text('Fulano'), findsOneWidget);
    expect(find.text('Editar perfil'), findsOneWidget);
    expect(find.text('0 seguidores'), findsOneWidget);
    expect(find.text('0 seguindo'), findsOneWidget);
    expect(find.text('Nenhuma atividade pública ainda.'), findsOneWidget);
    expect(
      find.text('Este perfil não está disponível no momento.'),
      findsNothing,
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

    await tester.tap(find.text('Discover'));
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

      await tester.tap(find.text('Discover'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Seguir'));
      await tester.pump();

      expect(repository.followedUserIds, ['user-2']);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.bySemanticsLabel('Seguindo usuário'), findsOneWidget);
      expect(find.text('Seguir'), findsNothing);

      repository.resumeFollow();
      await tester.pumpAndSettle();

      expect(find.text('Seguindo'), findsOneWidget);
      expect(find.text('Não foi possível seguir este usuário.'), findsNothing);
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

    await tester.tap(find.text('Discover'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Seguir'));
    await tester.pumpAndSettle();

    expect(repository.followedUserIds, ['user-2']);
    expect(find.text('Seguir'), findsOneWidget);
    expect(find.text('Seguindo'), findsNothing);
    expect(find.text('Não foi possível seguir este usuário.'), findsOneWidget);
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

    await tester.tap(find.text('Discover'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'O Discover demorou para responder. Tente novamente em instantes.',
      ),
      findsOneWidget,
    );
    expect(find.text('Tentar novamente'), findsOneWidget);
    expect(repository.discoverCallCount, 1);

    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();

    expect(repository.discoverCallCount, 2);
    expect(find.text('Ciclano'), findsOneWidget);
    expect(
      find.text(
        'O Discover demorou para responder. Tente novamente em instantes.',
      ),
      findsNothing,
    );
  });

  testWidgets('Profile edit and activity cards navigate', (tester) async {
    final router = _router(
      const SocialProfilePage(userId: 'me', isMe: true),
      _FakeSocialRepository(activityItems: [_event(mediaType: 'MOVIE')]),
    );
    await tester.pumpRouter(router);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Editar perfil'));
    await tester.pumpAndSettle();
    expect(
      router.routeInformationProvider.value.uri.path,
      '/social/profile/edit',
    );

    router.go('/');
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
    expect(router.routeInformationProvider.value.uri.path, '/movies/123');
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
    await tester.tap(find.text('Público'));
    await tester.pump();
    await tester.tap(find.text('Salvar perfil'));
    await tester.pumpAndSettle();

    expect(created, isTrue);
    expect(finished, isFalse);
    expect(find.text('Sugestões para seguir'), findsOneWidget);
    expect(find.text('Ciclano'), findsOneWidget);

    await tester.tap(find.text('Finalizar'));
    expect(finished, isTrue);
  });
}

extension on WidgetTester {
  Future<void> pumpSocial(Widget child, SocialRepository repository) {
    return pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [socialRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(home: Scaffold(body: child)),
      ),
    );
  }

  Future<void> pumpSocialHost(
    ValueNotifier<Widget> child,
    SocialRepository repository,
  ) {
    return pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [socialRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          home: Scaffold(
            body: ValueListenableBuilder<Widget>(
              valueListenable: child,
              builder: (context, value, _) => value,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> pumpRouter(GoRouter router) {
    return pumpWidget(MaterialApp.router(routerConfig: router));
  }
}

GoRouter _router(Widget child, SocialRepository repository) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => ProviderScope(
          retry: (_, _) => null,
          overrides: [socialRepositoryProvider.overrideWithValue(repository)],
          child: Scaffold(body: child),
        ),
      ),
      GoRoute(
        path: '/social/profile/edit',
        builder: (context, state) => const Text('edit destination'),
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
  );
}

class _FakeSocialRepository implements SocialRepository {
  _FakeSocialRepository({
    this.missingProfile = false,
    this.unavailableProfile = false,
    this.profile,
    this.feedItems = const [],
    this.discoverItems = const [],
    this.activityItems = const [],
    List<Object> discoverErrors = const [],
  }) : _discoverErrors = List<Object>.from(discoverErrors);

  bool missingProfile;
  final bool unavailableProfile;
  final SocialProfileModel? profile;
  final List<ActivityEventModel> feedItems;
  final List<DiscoverUserModel> discoverItems;
  final List<ActivityEventModel> activityItems;
  final List<Object> _discoverErrors;
  int discoverCallCount = 0;
  bool savedProfile = false;
  int getMyProfileCallCount = 0;
  final followedUserIds = <String>[];
  Object? followError;
  Completer<void>? _profileLoadCompleter;
  Completer<void>? _followCompleter;
  String? savedDisplayName;
  String? savedAvatarUrl;
  bool? savedIsPublic;

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
  Future<SocialProfileModel> getMyProfile() async {
    getMyProfileCallCount += 1;
    final profileLoadCompleter = _profileLoadCompleter;
    if (profileLoadCompleter != null) {
      await profileLoadCompleter.future;
    }
    if (missingProfile) {
      throw const ServerException(message: 'Missing', statusCode: 404);
    }
    return profile ?? _profile();
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
    return _profile(
      displayName: displayName,
      avatarUrl: avatarUrl,
      isPublic: isPublic,
    );
  }

  @override
  Future<SocialProfileModel> getProfile(String userId) async {
    if (unavailableProfile) {
      throw const ServerException(message: 'Unavailable', statusCode: 404);
    }
    return _profile(userId: userId);
  }

  @override
  Future<PaginatedSocialResponse<ActivityEventModel>> getFeed({
    int limit = 20,
    String? cursor,
  }) async => _page(feedItems);

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
  }) async => _page(activityItems);

  @override
  Future<PaginatedSocialResponse<FollowRelationshipModel>> getFollowers(
    String userId, {
    int limit = 20,
    String? cursor,
  }) async => _empty();

  @override
  Future<PaginatedSocialResponse<FollowRelationshipModel>> getFollowing(
    String userId, {
    int limit = 20,
    String? cursor,
  }) async => _empty();

  @override
  Future<PaginatedSocialResponse<PublicListItemModel>> getPublicLists(
    String userId, {
    String? status,
    String? mediaType,
    int limit = 20,
    String? cursor,
  }) async => _empty();

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

PaginatedSocialResponse<T> _empty<T>() => _page(const []);

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

ActivityEventModel _event({String mediaType = 'SERIES'}) {
  return ActivityEventModel(
    eventId: 'event-1',
    user: const SocialUserModel(userId: 'user-1', displayName: 'Fulano'),
    activityType: 'RATED',
    media: SocialMediaModel(
      mediaId: '123',
      mediaType: mediaType,
      title: 'Série Teste',
    ),
    createdAt: DateTime.utc(2026, 5, 20),
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
