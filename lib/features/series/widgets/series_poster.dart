// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
    final posterUrl = series.posterPath ?? '';
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: width,
              height: width * 1.5,
              color: Colors.grey[300],
              child: OverflowBox(
                minWidth: width,
                maxWidth: width,
                minHeight: width * 1.5 + 12,
                maxHeight: width * 1.5 + 12,
                alignment: Alignment.bottomCenter,
                child: CachedNetworkImage(
                  imageUrl: posterUrl,
                  width: width,
                  height: width * 1.5 + 12,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.broken_image,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: width,
            child: Text(
              series.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
