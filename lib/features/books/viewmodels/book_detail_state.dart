import 'package:freezed_annotation/freezed_annotation.dart';
import '../data/models/book_model.dart';

part 'book_detail_state.freezed.dart';

@freezed
abstract class BookDetailState with _$BookDetailState {
  const factory BookDetailState({
    required BookModel book,
  }) = _BookDetailState;
}
