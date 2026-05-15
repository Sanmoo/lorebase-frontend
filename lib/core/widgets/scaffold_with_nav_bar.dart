// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/viewmodels/auth_viewmodel.dart';
import '../../l10n/strings.g.dart';
import '../i18n/locale_provider.dart';

class ScaffoldWithNavBar extends ConsumerWidget {
  final Widget child;

  const ScaffoldWithNavBar({
    super.key,
    required this.child,
  });

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    switch (location) {
      case '/dashboard':
        return 0;
      case '/search':
        return 1;
      case '/tracking':
        return 2;
      case '/recommend':
        return 3;
      default:
        return 0;
    }
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/search');
        break;
      case 2:
        context.go('/tracking');
        break;
      case 3:
        context.go('/recommend');
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.app_title),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => _showLanguageSheet(context, ref, t),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authViewModelProvider.notifier).signOut(),
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _getCurrentIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard_outlined),
            activeIcon: const Icon(Icons.dashboard),
            label: t.nav_home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.search_outlined),
            activeIcon: const Icon(Icons.search),
            label: t.nav_search,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.format_list_bulleted),
            activeIcon: const Icon(Icons.format_list_bulleted),
            label: t.nav_my_lists,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.recommend_outlined),
            activeIcon: const Icon(Icons.recommend),
            label: t.nav_recommend,
          ),
        ],
      ),
    );
  }

  void _showLanguageSheet(BuildContext context, WidgetRef ref, Translations t) {
    final currentLocale = ref.read(localeProvider);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(t.locale_pt_BR),
              trailing: currentLocale == const Locale('pt', 'BR')
                  ? const Icon(Icons.check)
                  : null,
              onTap: () {
                ref.read(localeProvider.notifier).setLocale(const Locale('pt', 'BR'));
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: Text(t.locale_en_US),
              trailing: currentLocale == const Locale('en', 'US')
                  ? const Icon(Icons.check)
                  : null,
              onTap: () {
                ref.read(localeProvider.notifier).setLocale(const Locale('en', 'US'));
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: Text(t.locale_es),
              trailing: currentLocale == const Locale('es')
                  ? const Icon(Icons.check)
                  : null,
              onTap: () {
                ref.read(localeProvider.notifier).setLocale(const Locale('es'));
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}
