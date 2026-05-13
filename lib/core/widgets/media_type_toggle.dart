import 'package:flutter/material.dart';
import '../../features/tracking/data/models/media_type.dart';
import '../../l10n/strings.g.dart';

class MediaTypeToggle extends StatelessWidget {
  final MediaType selectedType;
  final ValueChanged<MediaType> onChanged;

  const MediaTypeToggle({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<MediaType>(
      showSelectedIcon: false,
      segments: MediaType.values
          .map(
            (type) => ButtonSegment<MediaType>(
              value: type,
              label: Text(type.label(context.t)),
            ),
          )
          .toList(),
      selected: {selectedType},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}
