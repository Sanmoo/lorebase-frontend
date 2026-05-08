// coverage:ignore-file
import 'package:flutter/material.dart';
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
            Image.network(
              series.posterPath ?? '',
              width: 100,
              height: 150,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 100,
                  height: 150,
                  color: Colors.grey[300],
                );
              },
              errorBuilder: (context, error, stackTrace) => Container(
                width: 100,
                height: 150,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image),
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
