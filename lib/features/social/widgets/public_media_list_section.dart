import 'package:cached_network_image/cached_network_image.dart';
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

  static const double _posterWidth = 124;
  static const double _posterHeight = 186;
  static const double _textAreaHeight = 64;
  static const double _cardPadding = 8;
  static const double _cardBorderWidth = 1;
  static const double _cardWidth =
      _posterWidth + (_cardPadding * 2) + (_cardBorderWidth * 2);

  final String title;
  final List<PublicListItemModel> items;
  final String emptyMessage;
  final ValueChanged<PublicListItemModel>? onItemTap;

  @override
  Widget build(BuildContext context) {
    final groupedItems = _groupItemsByStatus(items);
    final textScaler = MediaQuery.textScalerOf(context);
    final carouselHeight =
        _posterHeight + textScaler.scale(_textAreaHeight) + (_cardPadding * 2);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      cacheExtent: 1000,
      shrinkWrap: true,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        if (items.isEmpty)
          Text(emptyMessage)
        else
          for (final entry in groupedItems.entries)
            if (entry.value.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 10),
                child: Text(
                  _statusLabel(entry.key),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(
                height: carouselHeight,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: entry.value.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) => SizedBox(
                    width: _cardWidth,
                    child: _PublicMediaCard(
                      item: entry.value[index],
                      onItemTap: onItemTap,
                    ),
                  ),
                ),
              ),
            ],
      ],
    );
  }
}

class _PublicMediaCard extends StatelessWidget {
  const _PublicMediaCard({required this.item, required this.onItemTap});

  final PublicListItemModel item;
  final ValueChanged<PublicListItemModel>? onItemTap;

  @override
  Widget build(BuildContext context) {
    final media = item.media;
    final mediaType = media?.mediaType ?? item.mediaType;
    final title = media?.title ?? _mediaTypeLabel(mediaType);
    final mediaTypeLabel = _mediaTypeLabel(mediaType);
    final ratingLabel = item.rating == null ? null : '⭐ ${item.rating}/10';
    final showMediaTypeMetadata = title != mediaTypeLabel;
    final textScaler = MediaQuery.textScalerOf(context);

    return Semantics(
      button: onItemTap != null,
      label: onItemTap == null ? null : 'Abrir $title',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onItemTap == null ? null : () => onItemTap!(item),
          child: Ink(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(
                PublicMediaListSection._cardPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: PublicMediaListSection._posterWidth,
                    height: PublicMediaListSection._posterHeight,
                    child: _Poster(item: item),
                  ),
                  SizedBox(
                    height:
                        textScaler.scale(
                          PublicMediaListSection._textAreaHeight,
                        ) -
                        (PublicMediaListSection._cardBorderWidth * 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _Metadata(
                          mediaTypeLabel: showMediaTypeMetadata
                              ? mediaTypeLabel
                              : null,
                          ratingLabel: ratingLabel,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Metadata extends StatelessWidget {
  const _Metadata({required this.mediaTypeLabel, required this.ratingLabel});

  final String? mediaTypeLabel;
  final String? ratingLabel;

  @override
  Widget build(BuildContext context) {
    final parts = [?mediaTypeLabel, ?ratingLabel];
    final textStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );

    return Text(
      parts.join(' • '),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: textStyle,
    );
  }
}

class _Poster extends StatelessWidget {
  const _Poster({required this.item});

  final PublicListItemModel item;

  @override
  Widget build(BuildContext context) {
    final posterUrl = item.media?.posterUrl;
    final borderRadius = BorderRadius.circular(12);

    return ClipRRect(
      borderRadius: borderRadius,
      child: AspectRatio(
        aspectRatio: 2 / 3,
        child: posterUrl == null || posterUrl.isEmpty
            ? _PosterFallback(
                mediaType: item.media?.mediaType ?? item.mediaType,
              )
            : CachedNetworkImage(
                imageUrl: posterUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => const ColoredBox(
                  color: Color(0xFFE0E0E0),
                  child: Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => _PosterFallback(
                  mediaType: item.media?.mediaType ?? item.mediaType,
                ),
              ),
      ),
    );
  }
}

class _PosterFallback extends StatelessWidget {
  const _PosterFallback({required this.mediaType});

  final String mediaType;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          _mediaTypeIcon(mediaType),
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          size: 40,
        ),
      ),
    );
  }
}

const _knownStatusOrder = ['PLAN_TO_WATCH', 'WATCHING', 'COMPLETED', 'DROPPED'];

Map<String, List<PublicListItemModel>> _groupItemsByStatus(
  List<PublicListItemModel> items,
) {
  final grouped = <String, List<PublicListItemModel>>{};
  for (final item in items) {
    final normalizedStatus = item.status.toUpperCase();
    grouped.putIfAbsent(normalizedStatus, () => []).add(item);
  }

  final orderedGrouped = <String, List<PublicListItemModel>>{};
  for (final status in _knownStatusOrder) {
    final statusItems = grouped.remove(status);
    if (statusItems != null) {
      orderedGrouped[status] = statusItems;
    }
  }
  orderedGrouped.addAll(grouped);
  return orderedGrouped;
}

String _statusLabel(String status) {
  switch (status.toUpperCase()) {
    case 'PLAN_TO_WATCH':
      return 'Quero ver';
    case 'WATCHING':
      return 'Assistindo';
    case 'COMPLETED':
      return 'Concluído';
    case 'DROPPED':
      return 'Abandonado';
    default:
      return status
          .toLowerCase()
          .split('_')
          .where((part) => part.isNotEmpty)
          .map((part) => part[0].toUpperCase() + part.substring(1))
          .join(' ');
  }
}

String _mediaTypeLabel(String mediaType) {
  switch (mediaType.toUpperCase()) {
    case 'MOVIE':
    case 'FILME':
      return 'Filme';
    case 'SERIES':
    case 'TV':
      return 'Série';
    default:
      return mediaType;
  }
}

IconData _mediaTypeIcon(String mediaType) {
  switch (mediaType.toUpperCase()) {
    case 'MOVIE':
    case 'FILME':
      return Icons.movie;
    case 'SERIES':
    case 'TV':
      return Icons.tv;
    default:
      return Icons.image;
  }
}
