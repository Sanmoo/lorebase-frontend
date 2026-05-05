import 'package:flutter/material.dart';
import '../../series/data/models/series_model.dart';
import 'series_horizontal_list.dart';

class WatchingSection extends StatelessWidget {
  final List<SeriesModel> series;
  final ValueChanged<SeriesModel>? onTap;

  const WatchingSection({super.key, required this.series, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Watching',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 8),
        SeriesHorizontalList(series: series, onTap: onTap),
      ],
    );
  }
}
