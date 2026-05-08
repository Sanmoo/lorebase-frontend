// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/viewmodels/auth_viewmodel.dart';
import 'router.dart';

class LorebaseApp extends ConsumerWidget {
  const LorebaseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);

    return MaterialApp.router(
      title: 'Lorebase',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) {
        if (authState.isLoading) {
          return Material(
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
        return child!;
      },
    );
  }
}
