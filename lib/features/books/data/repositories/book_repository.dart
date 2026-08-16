import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/providers/core_providers.dart';
import '../models/book_model.dart';
import '../models/book_search_response.dart';

abstract class BookRepository {
  Future<BookSearchResponse> searchBooks(
    String query, {
    int page = 1,
    int limit = 20,
    CancelToken? cancelToken,
  });
  Future<BookModel> getBookById(String bookId);
}

class BookRepositoryImpl implements BookRepository {
  final Dio _dio;

  BookRepositoryImpl(this._dio);

  @override
  Future<BookSearchResponse> searchBooks(
    String query, {
    int page = 1,
    int limit = 20,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        '/books',
        queryParameters: {'q': query, 'page': page, 'limit': limit},
        cancelToken: cancelToken,
      );
      return BookSearchResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to search books',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<BookModel> getBookById(String bookId) async {
    try {
      final response = await _dio.get('/books/$bookId');
      return BookModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to load book',
        statusCode: e.response?.statusCode,
      );
    }
  }
}

final bookRepositoryProvider = Provider<BookRepository>((ref) {
  return BookRepositoryImpl(ref.watch(dioProvider));
});
