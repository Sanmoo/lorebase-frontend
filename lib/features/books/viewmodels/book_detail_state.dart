import 'package:freezed_annotation/freezed_annotation.dart';
import '../../tracking/data/models/tracked_media_model.dart';
import '../data/models/book_model.dart';

part 'book_detail_state.freezed.dart';

@freezed
abstract class BookDetailState with _$BookDetailState {
  const factory BookDetailState({
    required BookModel book,
    TrackedMediaModel? tracking,
  }) = _BookDetailState;
}
