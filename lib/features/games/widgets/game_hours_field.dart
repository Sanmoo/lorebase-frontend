import 'package:flutter/material.dart';
import '../../../l10n/strings.g.dart';

class GameHoursField extends StatefulWidget {
  final double? hours;
  final ValueChanged<double?> onChanged;

  const GameHoursField({super.key, this.hours, required this.onChanged});

  @override
  State<GameHoursField> createState() => _GameHoursFieldState();
}

class _GameHoursFieldState extends State<GameHoursField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.hours?.toString() ?? '');
    _controller.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(GameHoursField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hours != oldWidget.hours) {
      final newText = widget.hours?.toString() ?? '';
      if (_controller.text != newText) {
        _controller.text = newText;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged() {
    final value = _controller.text;
    final parsed = double.tryParse(value);
    widget.onChanged(parsed);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: context.t.game_hours_played_label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
