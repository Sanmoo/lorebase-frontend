import 'package:flutter/material.dart';
import '../../series/data/models/series_model.dart';
import '../../series/widgets/series_poster.dart';

class SeriesHorizontalList extends StatelessWidget {
  final List<SeriesModel> series;
  final ValueChanged<SeriesModel>? onTap;

  const SeriesHorizontalList({super.key, required this.series, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: series.length,
        itemBuilder: (context, index) {
          final item = series[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: SeriesPoster(
              series: item,
              width: 120,
              onTap: onTap != null ? () => onTap!(item) : null,
            ),
          );
        },
      ),
    );
  }
}
