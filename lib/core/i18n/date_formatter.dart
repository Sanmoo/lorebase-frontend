import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

String formatLocalizedDate(BuildContext context, String? value) {
  if (value == null || value.isEmpty) {
    return '—';
  }

  final date = DateTime.tryParse(value);
  if (date == null) {
    return value;
  }

  final localeName = Localizations.localeOf(context).toString();
  return DateFormat.yMMMd(localeName).format(date);
}
