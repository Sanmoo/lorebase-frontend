import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/core/errors/exceptions.dart';
import 'package:lorebase/features/social/data/models/activity_event_model.dart';
import 'package:lorebase/features/social/data/models/discover_user_model.dart';
import 'package:lorebase/features/social/data/models/follow_relationship_model.dart';
import 'package:lorebase/features/social/data/models/paginated_social_response.dart';
import 'package:lorebase/features/social/data/models/public_list_item_model.dart';
import 'package:lorebase/features/social/data/models/social_profile_model.dart';
import 'package:lorebase/features/social/data/repositories/social_repository.dart';
import 'package:lorebase/features/social/pages/social_onboarding_page.dart';
import 'package:lorebase/features/social/pages/social_page.dart';
import 'package:lorebase/features/social/pages/social_profile_page.dart';

void main() {
  testWidgets('Social page missing profile state renders onboarding', (
    tester,
  ) async {
    await tester.pumpSocial(
      const SocialPage(),
      _FakeSocialRepository(missingProfile: true),
    );
    await tester.pumpAndSettle();

    expect(find.text('Crie seu perfil social'), findsOneWidget);
  });

  testWidgets('Social page existing profile renders Feed and Discover tabs', (
    tester,
  ) async {
    await tester.pumpSocial(const SocialPage(), _FakeSocialRepository());
    await tester.pumpAndSettle();

    expect(find.text('Feed'), findsOneWidget);
    expect(find.text('Discover'), findsOneWidget);
  });

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
}

extension on WidgetTester {
  Future<void> pumpSocial(Widget child, SocialRepository repository) {
    return pumpWidget(
      ProviderScope(
        overrides: [socialRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(home: Scaffold(body: child)),
      ),
    );
  }
}

class _FakeSocialRepository implements SocialRepository {
  _FakeSocialRepository({
    this.missingProfile = false,
    this.unavailableProfile = false,
  });

  final bool missingProfile;
  final bool unavailableProfile;
  bool savedProfile = false;

  @override
  Future<SocialProfileModel> getMyProfile() async {
    if (missingProfile) {
      throw const ServerException(message: 'Missing', statusCode: 404);
    }
    return _profile();
  }

  @override
  Future<SocialProfileModel> updateMyProfile({
    required String displayName,
    String? avatarUrl,
    required bool isPublic,
  }) async {
    savedProfile = true;
    return _profile(displayName: displayName, isPublic: isPublic);
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
  }) async => _empty();

  @override
  Future<PaginatedSocialResponse<DiscoverUserModel>> discoverUsers({
    int limit = 20,
    String? cursor,
  }) async => _empty();

  @override
  Future<PaginatedSocialResponse<ActivityEventModel>> getUserActivity(
    String userId, {
    int limit = 20,
    String? cursor,
  }) async => _empty();

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
  Future<void> followUser(String userId) async {}

  @override
  Future<void> unfollowUser(String userId) async {}
}

PaginatedSocialResponse<T> _empty<T>() => PaginatedSocialResponse<T>(
  items: const [],
  nextCursor: null,
  hasMore: false,
);

SocialProfileModel _profile({
  String userId = 'user-1',
  String displayName = 'Fulano',
  bool isPublic = true,
}) {
  final now = DateTime.utc(2026, 5, 20);
  return SocialProfileModel(
    userId: userId,
    displayName: displayName,
    avatarUrl: null,
    isPublic: isPublic,
    followingCount: 0,
    followerCount: 0,
    isFollowedByMe: false,
    createdAt: now,
    updatedAt: now,
  );
}
