import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lorebase/app.dart';
import 'package:lorebase/core/widgets/scaffold_with_nav_bar.dart';
import 'package:lorebase/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:lorebase/features/auth/viewmodels/auth_state.dart';
import 'package:lorebase/router.dart';

class _LoadingAuthViewModel extends AuthViewModel {
  @override
  AuthState build() => const AuthState.unknown();

  @override
  void setAuthenticated(String userId) {}

  @override
  void setUnauthenticated() {}
}

class _AuthenticatedAuthViewModel extends AuthViewModel {
  @override
  AuthState build() => const AuthState.authenticated('user-1');

  @override
  void setAuthenticated(String userId) {}

  @override
  void setUnauthenticated() {}
}

Widget _buildAppWithAuth(AuthViewModel Function() createVM) {
  return ProviderScope(
    overrides: [
      authViewModelProvider.overrideWith(createVM),
    ],
    child: const LorebaseApp(),
  );
}

void main() {
  test('LorebaseApp is a Widget', () {
    expect(const LorebaseApp(), isA<Widget>());
  });

  group('LorebaseApp auth states', () {
    testWidgets('shows loading indicator when auth is unknown', (tester) async {
      await tester.pumpWidget(_buildAppWithAuth(() => _LoadingAuthViewModel()));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders app when authenticated', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authViewModelProvider
                .overrideWith(() => _AuthenticatedAuthViewModel()),
            routerProvider.overrideWith((ref) => GoRouter(
                  initialLocation: '/dashboard',
                  routes: [
                    GoRoute(
                      path: '/dashboard',
                      builder: (context, state) => const ScaffoldWithNavBar(
                        child: Text('Dashboard'),
                      ),
                    ),
                  ],
                )),
          ],
          child: const LorebaseApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ScaffoldWithNavBar), findsOneWidget);
    });
  });
}
