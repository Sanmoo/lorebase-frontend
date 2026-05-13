import 'package:flutter/material.dart';
import '../../../l10n/strings.g.dart';
import '../data/tracking_status.dart';
import 'rating_stars.dart';

class TrackingEditorSheet extends StatefulWidget {
  final String title;
  final String initialStatus;
  final int? initialRating;
  final String initialReview;
  final Future<void> Function({
    required String status,
    int? rating,
    String? review,
  }) onSave;
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
  late final TextEditingController _reviewController =
      TextEditingController(text: widget.initialReview);
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
              ...TrackingStatus.values.map(
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
                            onPressed: () =>
                                Navigator.pop(dialogContext, true),
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
}
