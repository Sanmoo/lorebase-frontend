// coverage:ignore-file
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../l10n/strings.g.dart';
import '../data/models/game_tracking_status.dart';
import '../data/models/media_type.dart';
import '../data/tracking_status.dart';

class TrackingStatusChip extends StatelessWidget {
  final String status;
  final MediaType? mediaType;

  const TrackingStatusChip({super.key, required this.status, this.mediaType});

  bool get _isGame => mediaType == MediaType.game;

  Color get _color {
    if (_isGame) {
      final gameStatus = GameTrackingStatus.fromString(status);
      switch (gameStatus) {
        case GameTrackingStatus.playing:
          return AppColors.watching;
        case GameTrackingStatus.wantToPlay:
          return AppColors.wantToWatch;
        case GameTrackingStatus.completed:
          return AppColors.completed;
        case GameTrackingStatus.dropped:
          return AppColors.dropped;
      }
    }

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
    final label = _isGame
        ? GameTrackingStatus.fromString(status).label(context.t)
        : TrackingStatus.fromString(status).label(context.t);
    return Chip(
      label: Text(
        label,
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
