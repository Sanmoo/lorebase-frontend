// coverage:ignore-file
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../l10n/strings.g.dart';
import '../data/tracking_status.dart';

class TrackingStatusChip extends StatelessWidget {
  final String status;

  const TrackingStatusChip({super.key, required this.status});

  Color get _color {
    final trackingStatus = TrackingStatus.fromString(status);
    switch (trackingStatus) {
      case TrackingStatus.watching:
        return AppColors.watching;
      case TrackingStatus.wantToWatch:
        return AppColors.wantToWatch;
      case TrackingStatus.completed:
        return AppColors.completed;
      case TrackingStatus.dropped:
        return AppColors.dropped;
    }
  }

  @override
  Widget build(BuildContext context) {
    final trackingStatus = TrackingStatus.fromString(status);
    return Chip(
      label: Text(
        trackingStatus.label(context.t),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: _color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
