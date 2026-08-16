// coverage:ignore-file
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/i18n/date_formatter.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../l10n/strings.g.dart';
import '../data/models/book_model.dart';
import '../viewmodels/book_detail_viewmodel.dart';

class BookDetailPage extends ConsumerWidget {
  final String bookId;

  const BookDetailPage({super.key, required this.bookId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final detailAsync = ref.watch(bookDetailViewModelProvider(bookId));

    return detailAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: LoadingWidget(message: t.book_detail_loading),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(bookDetailViewModelProvider(bookId)),
        ),
      ),
      data: (detail) => _BookDetailLoaded(book: detail.book),
    );
  }
}

class _BookDetailLoaded extends StatelessWidget {
  final BookModel book;

  const _BookDetailLoaded({required this.book});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final hasCover = book.coverUrl != null && book.coverUrl!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(book.title)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 280,
              color: theme.colorScheme.surfaceContainerHighest,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: hasCover
                      ? CachedNetworkImage(
                          imageUrl: book.coverUrl!,
                          imageRenderMethodForWeb:
                              ImageRenderMethodForWeb.HttpGet,
                          height: 260,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                          placeholder: (context, url) => Container(
                            width: 170,
                            height: 260,
                            color: theme.colorScheme.surfaceContainerHighest,
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 170,
                            height: 260,
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: const Icon(
                              Icons.menu_book,
                              size: 56,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : Container(
                          width: 170,
                          height: 260,
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: const Icon(
                            Icons.menu_book,
                            size: 56,
                            color: Colors.grey,
                          ),
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (book.authors.isNotEmpty)
                    Text(
                      book.authors.join(', '),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  const SizedBox(height: 12),
                  if (book.genre != null && book.genre!.isNotEmpty)
                    Chip(
                      label: Text(book.genre!),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _SynopsisSection(description: book.description),
            ),
            if (book.pageCount != null || book.isbn != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(
                  children: [
                    if (book.pageCount != null) ...[
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.auto_stories,
                          label: t.book_detail_pages_label,
                          value: t.book_detail_pages(count: book.pageCount!),
                        ),
                      ),
                      if (book.isbn != null) const SizedBox(width: 12),
                    ],
                    if (book.isbn != null)
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.qr_code,
                          label: t.book_detail_isbn,
                          value: book.isbn!,
                        ),
                      ),
                  ],
                ),
              ),
            if (book.publisher != null || book.publishedDate != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: Row(
                  children: [
                    if (book.publisher != null) ...[
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.business,
                          label: t.book_detail_publisher,
                          value: book.publisher!,
                        ),
                      ),
                      if (book.publishedDate != null) const SizedBox(width: 12),
                    ],
                    if (book.publishedDate != null)
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.calendar_today,
                          label: t.book_detail_published_date,
                          value: formatLocalizedDate(context, book.publishedDate),
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SynopsisSection extends StatefulWidget {
  final String? description;

  const _SynopsisSection({required this.description});

  @override
  State<_SynopsisSection> createState() => _SynopsisSectionState();
}

class _SynopsisSectionState extends State<_SynopsisSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final description = widget.description;
    if (description == null || description.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.book_detail_synopsis,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            t.book_detail_no_synopsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.book_detail_synopsis,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          maxLines: _expanded ? null : 5,
          overflow: _expanded ? null : TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Text(
            _expanded ? t.book_detail_show_less : t.book_detail_show_more,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
