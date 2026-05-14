// coverage:ignore-file
import 'package:flutter/material.dart';
import '../../tracking/data/models/tracked_media_summary_model.dart';
import '../../tracking/widgets/tracked_media_poster.dart';

class TrackedMediaHorizontalList extends StatelessWidget {
  final List<TrackedMediaSummaryModel> items;
  final ValueChanged<TrackedMediaSummaryModel>? onTap;

  const TrackedMediaHorizontalList({
    super.key,
    required this.items,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SizedBox(
              width: 120,
              child: TrackedMediaPoster(
                media: item,
                onTap: onTap != null ? () => onTap!(item) : null,
              ),
            ),
          );
        },
      ),
    );
  }
}
