import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lorebase/core/widgets/scaffold_with_nav_bar.dart';
import 'package:lorebase/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:lorebase/features/auth/viewmodels/auth_state.dart';

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
    overrides: [
      authViewModelProvider.overrideWith(() => FakeAuthViewModel()),
    ],
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
                builder: (context, state) => child,
              ),
              GoRoute(
                path: '/search',
                builder: (context, state) => child,
              ),
              GoRoute(
                path: '/tracking',
                builder: (context, state) => child,
              ),
              GoRoute(
                path: '/recommend',
                builder: (context, state) => child,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

void main() {
  group('ScaffoldWithNavBar', () {
    testWidgets('renders 4 bottom navigation items', (tester) async {
      await tester.pumpWidget(_wrapWithRouter(const Text('Content')));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('My Lists'), findsOneWidget);
      expect(find.text('Recommend'), findsOneWidget);
    });

    testWidgets('renders logout icon button', (tester) async {
      await tester.pumpWidget(_wrapWithRouter(const Text('Content')));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets('logout button calls signOut', (tester) async {
      final container = ProviderContainer(overrides: [
        authViewModelProvider.overrideWith(() => FakeAuthViewModel()),
      ]);
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
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
                      path: '/recommend',
                      builder: (context, state) => const Text('Content'),
                    ),
                  ],
                ),
              ],
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
      await tester.pumpWidget(
          _wrapWithRouter(const Text('Page Content')));
      await tester.pumpAndSettle();

      expect(find.text('Page Content'), findsOneWidget);
    });
  });
}
