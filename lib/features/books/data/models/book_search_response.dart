import 'package:freezed_annotation/freezed_annotation.dart';

import 'book_model.dart';

part 'book_search_response.freezed.dart';
part 'book_search_response.g.dart';

/// Paginated search response from `GET /books`. Items is the list of hits,
/// Query echoes the original query, and Count/Page/Limit capture the
/// pagination state used by the catalog provider.
@freezed
abstract class BookSearchResponse with _$BookSearchResponse {
  const factory BookSearchResponse({
    @Default([]) List<BookModel> items,
    @Default('') String query,
    @Default(0) int count,
    @Default(1) int page,
    @Default(20) int limit,
  }) = _BookSearchResponse;

  factory BookSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$BookSearchResponseFromJson(json);
}
