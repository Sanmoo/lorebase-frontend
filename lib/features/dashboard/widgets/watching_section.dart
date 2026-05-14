// coverage:ignore-file
import 'package:flutter/material.dart';
import '../../tracking/data/models/tracked_media_summary_model.dart';
import 'tracked_media_horizontal_list.dart';

class DashboardSection extends StatelessWidget {
  final String title;
  final List<TrackedMediaSummaryModel> items;
  final ValueChanged<TrackedMediaSummaryModel>? onTap;

  const DashboardSection({
    super.key,
    required this.title,
    required this.items,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 8),
        TrackedMediaHorizontalList(items: items, onTap: onTap),
      ],
    );
  }
}
