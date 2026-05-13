import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart';
import '../data/models/movie_model.dart';

class MovieCard extends StatelessWidget {
  final MovieModel movie;
  final VoidCallback? onTap;

  const MovieCard({super.key, required this.movie, this.onTap});

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
                  imageUrl: movie.posterPath ?? '',
                  imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet,
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
                      movie.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (movie.genres.isNotEmpty)
                      Text(
                        movie.genres.join(', '),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    const SizedBox(height: 4),
                    if (movie.releaseDate != null)
                      Text(
                        movie.releaseDate!,
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
