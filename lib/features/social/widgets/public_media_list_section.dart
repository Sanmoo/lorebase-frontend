import 'package:flutter/material.dart';

import '../data/models/public_list_item_model.dart';

class PublicMediaListSection extends StatelessWidget {
  const PublicMediaListSection({
    super.key,
    required this.title,
    required this.items,
    this.emptyMessage = 'Nenhum item público ainda.',
    this.onItemTap,
  });

  final String title;
  final List<PublicListItemModel> items;
  final String emptyMessage;
  final ValueChanged<PublicListItemModel>? onItemTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (items.isEmpty)
          Text(emptyMessage)
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              final media = item.media;
              final title = media?.title ?? item.mediaId;

              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(title),
                subtitle: Text(item.status),
                trailing: item.rating == null
                    ? null
                    : Text('⭐ ${item.rating}/10'),
                onTap: onItemTap == null ? null : () => onItemTap!(item),
              );
            },
          ),
      ],
    );
  }
}
