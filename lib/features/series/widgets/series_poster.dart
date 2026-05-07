import 'package:flutter/material.dart';
import '../data/models/series_model.dart';

class SeriesPoster extends StatelessWidget {
  final SeriesModel series;
  final double width;
  final VoidCallback? onTap;

  const SeriesPoster({
    super.key,
    required this.series,
    this.width = 120,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              series.posterPath ?? '',
              width: width,
              height: width * 1.5,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: width,
                  height: width * 1.5,
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stackTrace) => Container(
                width: width,
                height: width * 1.5,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image),
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: width,
            child: Text(
              series.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
