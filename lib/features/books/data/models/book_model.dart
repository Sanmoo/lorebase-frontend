import 'package:freezed_annotation/freezed_annotation.dart';

part 'book_model.freezed.dart';
part 'book_model.g.dart';

/// A catalog record for a book, identified by the Google Books volume id
/// returned by the backend. ISBN is a display attribute, never the identity.
@freezed
abstract class BookModel with _$BookModel {
  const factory BookModel({
    required String bookId,
    required String title,
    @Default([]) List<String> authors,
    String? isbn,
    int? pageCount,
    String? coverUrl,
    String? publisher,
    String? publishedDate,
    String? description,
    String? genre,
  }) = _BookModel;

  factory BookModel.fromJson(Map<String, dynamic> json) =>
      _$BookModelFromJson(json);
}
