import '../../../../l10n/strings.g.dart';

/// A status that can be used to track a specific media context.
abstract interface class MediaTrackingStatus {
  String get value;

  String label(Translations t);
}
