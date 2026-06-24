// coverage:ignore-file
import 'package:flutter/material.dart';
import '../../../l10n/strings.g.dart';
import '../../games/widgets/game_hours_field.dart';
import '../../games/widgets/game_platform_selector.dart';
import '../data/models/game_platform.dart';
import '../data/models/game_tracking_status.dart';
import '../data/tracking_status.dart';
import 'rating_stars.dart';

class TrackingEditorSheet extends StatefulWidget {
  final String title;
  final String initialStatus;
  final int? initialRating;
  final String initialReview;
  final String? initialSelectedPlatform;
  final double? initialHoursPlayed;
  final bool isGame;
  final Future<void> Function({
    required String status,
    int? rating,
    String? review,
    String? selectedPlatform,
    double? hoursPlayed,
  })
  onSave;
  final Future<void> Function()? onRemove;
  final String? removeLabel;
  final String? removeConfirmTitle;
  final String? removeConfirmMessage;

  const TrackingEditorSheet({
    super.key,
    required this.title,
    required this.initialStatus,
    required this.initialRating,
    required this.initialReview,
    this.initialSelectedPlatform,
    this.initialHoursPlayed,
    this.isGame = false,
    required this.onSave,
    this.onRemove,
    this.removeLabel,
    this.removeConfirmTitle,
    this.removeConfirmMessage,
  });

  @override
  State<TrackingEditorSheet> createState() => _TrackingEditorSheetState();
}

class _TrackingEditorSheetState extends State<TrackingEditorSheet> {
  late String _status = widget.initialStatus;
  late int? _rating = widget.initialRating;
  late String? _selectedPlatform = widget.initialSelectedPlatform;
  late double? _hoursPlayed = widget.initialHoursPlayed;
  late final TextEditingController _reviewController = TextEditingController(
    text: widget.initialReview,
  );
  bool _saving = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              ..._statusOptions.map(
                (status) => ListTile(
                  leading: Icon(
                    status.value == _status
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                  ),
                  title: Text(status.label(context.t)),
                  onTap: () => setState(() => _status = status.value),
                ),
              ),
              if (widget.isGame) ...[
                const SizedBox(height: 24),
                GamePlatformSelector(
                  platforms: GamePlatform.values
                      .map((p) => p.apiValue)
                      .toList(),
                  selectedPlatform: _selectedPlatform,
                  onChanged: (value) =>
                      setState(() => _selectedPlatform = value),
                ),
                const SizedBox(height: 16),
                GameHoursField(
                  hours: _hoursPlayed,
                  onChanged: (value) => setState(() => _hoursPlayed = value),
                ),
              ],
              const SizedBox(height: 24),
              Text(context.t.series_detail_rating),
              const SizedBox(height: 8),
              RatingStars(
                rating: _rating,
                maxRating: 10,
                onRatingChanged: (value) => setState(() => _rating = value),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _reviewController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: context.t.series_detail_review,
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving
                    ? null
                    : () async {
                        setState(() => _saving = true);
                        try {
                          await widget.onSave(
                            status: _status,
                            rating: _rating,
                            review: _reviewController.text.isEmpty
                                ? null
                                : _reviewController.text,
                            selectedPlatform: _selectedPlatform,
                            hoursPlayed: _hoursPlayed,
                          );
                        } finally {
                          if (mounted) {
                            setState(() => _saving = false);
                          }
                        }
                      },
                child: Text(context.t.series_detail_save_changes),
              ),
              if (widget.onRemove != null) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: Text(widget.removeConfirmTitle!),
                        content: Text(widget.removeConfirmMessage!),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(dialogContext, false),
                            child: Text(context.t.series_detail_cancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext, true),
                            child: Text(context.t.series_detail_remove),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await widget.onRemove!();
                    }
                  },
                  child: Text(widget.removeLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<_StatusOption> get _statusOptions {
    if (widget.isGame) {
      return GameTrackingStatus.values
          .map((s) => _StatusOption(value: s.value, label: s.label))
          .toList();
    }
    return TrackingStatus.values
        .map((s) => _StatusOption(value: s.value, label: s.label))
        .toList();
  }
}

typedef _StatusLabel = String Function(Translations t);

class _StatusOption {
  final String value;
  final _StatusLabel label;

  const _StatusOption({required this.value, required this.label});
}
