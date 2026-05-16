// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart';
import '../data/models/tracked_media_summary_model.dart';

class TrackedMediaPoster extends StatelessWidget {
  final TrackedMediaSummaryModel media;
  final double width;
  final VoidCallback? onTap;

  const TrackedMediaPoster({
    super.key,
    required this.media,
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
            child: Container(
              width: width,
              height: width * 1.5,
              color: Colors.grey[300],
              child: media.posterPath != null && media.posterPath!.isNotEmpty
                  ? OverflowBox(
                      minWidth: width,
                      maxWidth: width,
                      minHeight: width * 1.5 + 12,
                      maxHeight: width * 1.5 + 12,
                      alignment: Alignment.bottomCenter,
                      child: CachedNetworkImage(
                        imageUrl: media.posterPath!,
                        imageRenderMethodForWeb:
                            ImageRenderMethodForWeb.HttpGet,
                        width: width,
                        height: width * 1.5 + 12,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.broken_image),
                      ),
                    )
                  : const Icon(Icons.broken_image),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: width,
            child: Text(
              media.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
