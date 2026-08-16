import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart';
import 'package:flutter/material.dart';
import '../data/models/book_model.dart';

class BookCard extends StatelessWidget {
  final BookModel book;
  final VoidCallback? onTap;

  const BookCard({super.key, required this.book, this.onTap});

  /// Widget shown when the CachedNetworkImage fails to load the book cover.
  static Widget errorIcon(BuildContext context, String url, Object error) {
    return const Icon(Icons.menu_book, size: 40);
  }

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
              child: book.coverUrl != null && book.coverUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: book.coverUrl!,
                      imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet,
                      width: 100,
                      height: 150,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                      placeholder: (context, url) => Container(
                        width: 100,
                        height: 150,
                        color: Colors.grey[300],
                      ),
                      errorWidget: errorIcon,
                    )
                  : const Center(child: Icon(Icons.menu_book, size: 40)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (book.authors.isNotEmpty)
                      Text(
                        book.authors.join(', '),
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    if (book.genre != null && book.genre!.isNotEmpty)
                      Text(
                        book.genre!,
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
