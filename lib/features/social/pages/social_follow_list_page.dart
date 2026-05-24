// coverage:ignore-file

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../viewmodels/social_follow_list_viewmodel.dart';

class SocialFollowListPage extends ConsumerWidget {
  const SocialFollowListPage({
    super.key,
    required this.userId,
    required this.kind,
  });

  final String userId;
  final SocialFollowListKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(socialFollowListViewModelProvider(userId, kind));
    final title = kind == SocialFollowListKind.followers
        ? 'Followers'
        : 'Following';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: list.when(
        data: (data) {
          if (data.items.isEmpty) {
            return const Center(child: Text('Nenhuma pessoa para mostrar.'));
          }
          return ListView(
            children: [
              for (final relationship in data.items)
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: relationship.avatarUrl != null
                        ? NetworkImage(relationship.avatarUrl!)
                        : null,
                    child: relationship.avatarUrl == null
                        ? Text(relationship.displayName.characters.first)
                        : null,
                  ),
                  title: Text(relationship.displayName),
                  subtitle:
                      relationship.username != null &&
                          relationship.username!.trim().isNotEmpty
                      ? Text('@${relationship.username}')
                      : null,
                  onTap: () =>
                      context.go('/social/profile/${relationship.userId}'),
                ),
            ],
          );
        },
        error: (_, _) => const Center(child: Text('Erro ao carregar lista.')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
