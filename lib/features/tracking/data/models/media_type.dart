import '../../../../l10n/strings.g.dart';

enum MediaType {
  series('series'),
  movie('movie');

  const MediaType(this.apiValue);

  final String apiValue;

  String label(Translations t) {
    switch (this) {
      case MediaType.series:
        return t.media_type_series;
      case MediaType.movie:
        return t.media_type_movies;
    }
  }
}

extension MediaTypeX on MediaType {
  static MediaType fromApiValue(String value) {
    return MediaType.values.firstWhere(
      (type) => type.apiValue == value,
      orElse: () => throw ArgumentError.value(
        value,
        'value',
        'Unsupported media type',
      ),
    );
  }
}

MediaType mediaTypeFromJson(String value) => MediaTypeX.fromApiValue(value);
String mediaTypeToJson(MediaType value) => value.apiValue;
