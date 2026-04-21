import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/widgets/scaffold_with_nav_bar.dart';
import 'features/dashboard/pages/dashboard_page.dart';
import 'features/recommendation/pages/recommendation_page.dart';
import 'features/series/pages/series_search_page.dart';
import 'features/tracking/pages/tracking_list_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/dashboard',
    routes: [
      ShellRoute(
        builder: (context, state, child) => ScaffoldWithNavBar(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/search',
            builder: (context, state) => const SeriesSearchPage(),
          ),
          GoRoute(
            path: '/tracking',
            builder: (context, state) => const TrackingListPage(),
          ),
          GoRoute(
            path: '/recommend',
            builder: (context, state) => const RecommendationPage(),
          ),
        ],
      ),
    ],
  );
});
