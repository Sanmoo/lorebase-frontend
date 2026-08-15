import '../../../../l10n/strings.g.dart';

enum MediaType {
  series('SERIES'),
  movie('MOVIE'),
  game('GAME'),
  book('BOOK');

  const MediaType(this.apiValue);

  final String apiValue;

  String label(Translations t) {
    switch (this) {
      case MediaType.series:
        return t.media_type_series;
      case MediaType.movie:
        return t.media_type_movies;
      case MediaType.game:
        return t.media_type_games;
      case MediaType.book:
        return t.media_type_books;
    }
  }
}

extension MediaTypeX on MediaType {
  static MediaType fromApiValue(String value) {
    return MediaType.values.firstWhere(
      (type) => type.apiValue.toLowerCase() == value.toLowerCase(),
      orElse: () =>
          throw ArgumentError.value(value, 'value', 'Unsupported media type'),
    );
  }
}

MediaType mediaTypeFromJson(String value) => MediaTypeX.fromApiValue(value);
String mediaTypeToJson(MediaType value) => value.apiValue;
