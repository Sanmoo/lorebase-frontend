import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lorebase/core/widgets/scaffold_with_nav_bar.dart';
import 'package:lorebase/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:lorebase/features/auth/viewmodels/auth_state.dart';
import 'package:lorebase/l10n/strings.g.dart';

class FakeAuthViewModel extends AuthViewModel {
  bool signOutCalled = false;

  @override
  AuthState build() => const AuthState.authenticated('user-1');

  @override
  Future<void> signOut() async {
    signOutCalled = true;
    state = const AuthState.unauthenticated();
  }

  @override
  void setAuthenticated(String userId) {}

  @override
  void setUnauthenticated() {}
}

Widget _wrapWithRouter(Widget child, {String location = '/dashboard'}) {
  return ProviderScope(
    overrides: [authViewModelProvider.overrideWith(() => FakeAuthViewModel())],
    child: TranslationProvider(
      child: MaterialApp.router(
        routerConfig: GoRouter(
          initialLocation: location,
          routes: [
            ShellRoute(
              builder: (context, state, child) =>
                  ScaffoldWithNavBar(child: child),
              routes: [
                GoRoute(path: '/dashboard', builder: (context, state) => child),
                GoRoute(path: '/search', builder: (context, state) => child),
                GoRoute(path: '/tracking', builder: (context, state) => child),
                GoRoute(path: '/social', builder: (context, state) => child),
                GoRoute(
                  path: '/social/profile/:userId',
                  builder: (context, state) => child,
                ),
                GoRoute(path: '/recommend', builder: (context, state) => child),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _wrapWithRouteLabels(String location) {
  return ProviderScope(
    overrides: [authViewModelProvider.overrideWith(() => FakeAuthViewModel())],
    child: TranslationProvider(
      child: MaterialApp.router(
        routerConfig: GoRouter(
          initialLocation: location,
          routes: [
            ShellRoute(
              builder: (context, state, child) =>
                  ScaffoldWithNavBar(child: child),
              routes: [
                GoRoute(
                  path: '/dashboard',
                  builder: (context, state) => const Text('Dashboard Page'),
                ),
                GoRoute(
                  path: '/search',
                  builder: (context, state) => const Text('Search Page'),
                ),
                GoRoute(
                  path: '/tracking',
                  builder: (context, state) => const Text('Tracking Page'),
                ),
                GoRoute(
                  path: '/social',
                  builder: (context, state) => const Text('Social Page'),
                ),
                GoRoute(
                  path: '/social/profile/:userId',
                  builder: (context, state) =>
                      const Text('Social Profile Page'),
                ),
                GoRoute(
                  path: '/recommend',
                  builder: (context, state) => const Text('Recommend Page'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> main() async {
  await LocaleSettings.setLocale(AppLocale.enUs);

  group('ScaffoldWithNavBar', () {
    testWidgets('renders 4 bottom navigation items', (tester) async {
      await tester.pumpWidget(_wrapWithRouter(const Text('Content')));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('My Lists'), findsOneWidget);
      expect(find.text('Social'), findsOneWidget);
      expect(find.text('Recommend'), findsNothing);
    });

    testWidgets('renders header buttons with accessible labels', (
      tester,
    ) async {
      await tester.pumpWidget(_wrapWithRouter(const Text('Content')));
      await tester.pumpAndSettle();

      expect(find.byTooltip('Change language'), findsOneWidget);
      expect(find.byTooltip('Sign out'), findsOneWidget);
    });

    testWidgets('logout button calls signOut', (tester) async {
      final container = ProviderContainer(
        overrides: [
          authViewModelProvider.overrideWith(() => FakeAuthViewModel()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TranslationProvider(
            child: MaterialApp.router(
              routerConfig: GoRouter(
                initialLocation: '/dashboard',
                routes: [
                  ShellRoute(
                    builder: (context, state, child) =>
                        ScaffoldWithNavBar(child: child),
                    routes: [
                      GoRoute(
                        path: '/dashboard',
                        builder: (context, state) => const Text('Content'),
                      ),
                      GoRoute(
                        path: '/search',
                        builder: (context, state) => const Text('Content'),
                      ),
                      GoRoute(
                        path: '/tracking',
                        builder: (context, state) => const Text('Content'),
                      ),
                      GoRoute(
                        path: '/social',
                        builder: (context, state) => const Text('Content'),
                      ),
                      GoRoute(
                        path: '/recommend',
                        builder: (context, state) => const Text('Content'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.logout));
      final fakeVM =
          container.read(authViewModelProvider.notifier) as FakeAuthViewModel;
      expect(fakeVM.signOutCalled, true);
    });

    testWidgets('renders child content', (tester) async {
      await tester.pumpWidget(_wrapWithRouter(const Text('Page Content')));
      await tester.pumpAndSettle();

      expect(find.text('Page Content'), findsOneWidget);
    });

    testWidgets('dashboard tab is selected by default', (tester) async {
      await tester.pumpWidget(_wrapWithRouter(const Text('Content')));
      await tester.pumpAndSettle();

      final navBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(navBar.currentIndex, 0);
    });

    testWidgets('search tab has correct index', (tester) async {
      await tester.pumpWidget(
        _wrapWithRouter(const Text('Content'), location: '/search'),
      );
      await tester.pumpAndSettle();

      final navBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(navBar.currentIndex, 1);
    });

    testWidgets('tracking tab has correct index', (tester) async {
      await tester.pumpWidget(
        _wrapWithRouter(const Text('Content'), location: '/tracking'),
      );
      await tester.pumpAndSettle();

      final navBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(navBar.currentIndex, 2);
    });

    testWidgets('social tab has correct index', (tester) async {
      await tester.pumpWidget(
        _wrapWithRouter(const Text('Content'), location: '/social'),
      );
      await tester.pumpAndSettle();

      final navBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(navBar.currentIndex, 3);
    });

    testWidgets('social nested route has correct index', (tester) async {
      await tester.pumpWidget(
        _wrapWithRouter(
          const Text('Content'),
          location: '/social/profile/user-1',
        ),
      );
      await tester.pumpAndSettle();

      final navBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(navBar.currentIndex, 3);
    });

    testWidgets('tapping search tab navigates to search page', (tester) async {
      await tester.pumpWidget(_wrapWithRouteLabels('/dashboard'));
      await tester.pumpAndSettle();

      expect(find.text('Dashboard Page'), findsOneWidget);

      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      expect(find.text('Search Page'), findsOneWidget);
      final navBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(navBar.currentIndex, 1);
    });

    testWidgets('tapping tracking tab navigates to tracking page', (
      tester,
    ) async {
      await tester.pumpWidget(_wrapWithRouteLabels('/dashboard'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('My Lists'));
      await tester.pumpAndSettle();

      expect(find.text('Tracking Page'), findsOneWidget);
      final navBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(navBar.currentIndex, 2);
    });

    testWidgets('tapping social tab navigates to social page', (tester) async {
      await tester.pumpWidget(_wrapWithRouteLabels('/dashboard'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Social'));
      await tester.pumpAndSettle();

      expect(find.text('Social Page'), findsOneWidget);
      final navBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(navBar.currentIndex, 3);
    });

    testWidgets('tapping home tab navigates back to dashboard', (tester) async {
      await tester.pumpWidget(_wrapWithRouteLabels('/search'));
      await tester.pumpAndSettle();

      expect(find.text('Search Page'), findsOneWidget);

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      expect(find.text('Dashboard Page'), findsOneWidget);
      final navBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(navBar.currentIndex, 0);
    });
  });
}
