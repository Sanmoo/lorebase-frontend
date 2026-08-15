// coverage:ignore-file
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../l10n/strings.g.dart';
import '../data/models/media_type.dart';
import '../data/tracking_status.dart';

class TrackingStatusChip extends StatelessWidget {
  final String status;
  final MediaType? mediaType;

  const TrackingStatusChip({super.key, required this.status, this.mediaType});

  MediaType get _mediaType => mediaType ?? MediaType.series;

  String get _statusValue =>
      trackingStatusForMediaType(_mediaType, status).value;

  Color get _color {
    return switch (_statusValue) {
      'WATCHING' || 'PLAYING' || 'READING' => AppColors.watching,
      'WANT_TO_WATCH' ||
      'WANT_TO_PLAY' ||
      'WANT_TO_READ' => AppColors.wantToWatch,
      'COMPLETED' => AppColors.completed,
      'DROPPED' => AppColors.dropped,
      _ => AppColors.wantToWatch,
    };
  }

  @override
  Widget build(BuildContext context) {
    final label = trackingStatusForMediaType(
      _mediaType,
      status,
    ).label(context.t);
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
