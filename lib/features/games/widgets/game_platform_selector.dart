import 'package:flutter/material.dart';
import '../../../l10n/strings.g.dart';
import '../../tracking/data/models/game_platform.dart';

class GamePlatformSelector extends StatelessWidget {
  final List<String> platforms;
  final String? selectedPlatform;
  final ValueChanged<String?> onChanged;
  final String? labelText;

  const GamePlatformSelector({
    super.key,
    required this.platforms,
    this.selectedPlatform,
    required this.onChanged,
    this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    final items = platforms.map((apiValue) {
      final platform = GamePlatform.fromApiValue(apiValue);
      return DropdownMenuItem<String>(
        value: apiValue,
        child: Text(platform.label(context.t)),
      );
    }).toList();

    return DropdownButtonFormField<String>(
      initialValue: selectedPlatform,
      items: items.isEmpty ? null : items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
