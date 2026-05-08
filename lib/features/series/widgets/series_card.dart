// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../data/models/series_model.dart';

class SeriesCard extends StatelessWidget {
  final SeriesModel series;
  final VoidCallback? onTap;

  const SeriesCard({
    super.key,
    required this.series,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 100,
              height: 150,
              color: Colors.grey[300],
              child: OverflowBox(
                minWidth: 100,
                maxWidth: 100,
                minHeight: 162,
                maxHeight: 162,
                alignment: Alignment.bottomCenter,
                child: CachedNetworkImage(
                  imageUrl: series.posterPath ?? '',
                  width: 100,
                  height: 162,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 100,
                    height: 150,
                    color: Colors.grey[300],
                  ),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.broken_image,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      series.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (series.genres.isNotEmpty)
                      Text(
                        series.genres.join(', '),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    const SizedBox(height: 4),
                    if (series.seasonCount > 0)
                      Text(
                        '${series.seasonCount} season${series.seasonCount != 1 ? 's' : ''}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
