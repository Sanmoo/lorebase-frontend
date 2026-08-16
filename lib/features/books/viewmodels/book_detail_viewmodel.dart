import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/book_repository.dart';
import 'book_detail_state.dart';

part 'book_detail_viewmodel.g.dart';

@riverpod
class BookDetailViewModel extends _$BookDetailViewModel {
  @override
  Future<BookDetailState> build(String bookId) async {
    final book = await ref.read(bookRepositoryProvider).getBookById(bookId);
    return BookDetailState(book: book);
  }
}
