// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meta/meta.dart';
import 'core/widgets/scaffold_with_nav_bar.dart';
import 'features/auth/pages/forgot_password_page.dart';
import 'features/auth/pages/login_page.dart';
import 'features/auth/pages/register_page.dart';
import 'features/auth/viewmodels/auth_state.dart';
import 'features/auth/viewmodels/auth_viewmodel.dart';
import 'features/dashboard/pages/dashboard_page.dart';
import 'features/recommendation/pages/recommendation_page.dart';
import 'features/series/pages/series_search_page.dart';
import 'features/tracking/pages/tracking_list_page.dart';
import 'features/series/pages/series_detail_page.dart';
import 'features/movies/pages/movie_detail_page.dart';
import 'features/social/pages/edit_social_profile_page.dart';
import 'features/social/pages/social_follow_list_page.dart';
import 'features/social/pages/social_page.dart';
import 'features/social/pages/social_profile_page.dart';
import 'features/social/viewmodels/social_follow_list_viewmodel.dart';

@visibleForTesting
String? authRedirect(AuthState authState, String location) {
  final isAuthRoute = [
    '/login',
    '/register',
    '/forgot-password',
  ].contains(location);
  final isAuthenticated = authState.isAuthenticated;

  if (!isAuthenticated && !isAuthRoute) return '/login';
  if (isAuthenticated && isAuthRoute) return '/dashboard';
  return null;
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authViewModelProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) =>
        authRedirect(authState, state.matchedLocation),
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => ScaffoldWithNavBar(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const DashboardPage(),
            ),
          ),
          GoRoute(
            path: '/search',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const SeriesSearchPage(),
            ),
          ),
          GoRoute(
            path: '/series/:tmdbId',
            builder: (context, state) {
              final tmdbId = int.parse(state.pathParameters['tmdbId']!);
              return SeriesDetailPage(tmdbId: tmdbId);
            },
          ),
          GoRoute(
            path: '/movies/:tmdbId',
            builder: (context, state) {
              final tmdbId = int.parse(state.pathParameters['tmdbId']!);
              return MovieDetailPage(tmdbId: tmdbId);
            },
          ),
          GoRoute(
            path: '/tracking',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const TrackingListPage(),
            ),
          ),
          GoRoute(
            path: '/social',
            pageBuilder: (context, state) =>
                NoTransitionPage(key: state.pageKey, child: const SocialPage()),
          ),
          GoRoute(
            path: '/social/profile/me',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const SocialProfilePage(userId: 'me', isMe: true),
            ),
          ),
          GoRoute(
            path: '/social/profile/edit',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const EditSocialProfilePage(),
            ),
          ),
          GoRoute(
            path: '/social/profile/:userId/followers',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: SocialFollowListPage(
                userId: state.pathParameters['userId']!,
                kind: SocialFollowListKind.followers,
              ),
            ),
          ),
          GoRoute(
            path: '/social/profile/:userId/following',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: SocialFollowListPage(
                userId: state.pathParameters['userId']!,
                kind: SocialFollowListKind.following,
              ),
            ),
          ),
          GoRoute(
            path: '/social/profile/:userId',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: SocialProfilePage(userId: state.pathParameters['userId']!),
            ),
          ),
          GoRoute(
            path: '/recommend',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const RecommendationPage(),
            ),
          ),
        ],
      ),
    ],
  );
});
