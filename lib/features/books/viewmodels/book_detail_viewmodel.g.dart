// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_detail_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BookDetailViewModel)
final bookDetailViewModelProvider = BookDetailViewModelFamily._();

final class BookDetailViewModelProvider
    extends $AsyncNotifierProvider<BookDetailViewModel, BookDetailState> {
  BookDetailViewModelProvider._({
    required BookDetailViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'bookDetailViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bookDetailViewModelHash();

  @override
  String toString() {
    return r'bookDetailViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  BookDetailViewModel create() => BookDetailViewModel();

  @override
  bool operator ==(Object other) {
    return other is BookDetailViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bookDetailViewModelHash() =>
    r'3e4103236809e549bf884dc53df6e6a2a09d9bbc';

final class BookDetailViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          BookDetailViewModel,
          AsyncValue<BookDetailState>,
          BookDetailState,
          FutureOr<BookDetailState>,
          String
        > {
  BookDetailViewModelFamily._()
    : super(
        retry: null,
        name: r'bookDetailViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BookDetailViewModelProvider call(String bookId) =>
      BookDetailViewModelProvider._(argument: bookId, from: this);

  @override
  String toString() => r'bookDetailViewModelProvider';
}

abstract class _$BookDetailViewModel extends $AsyncNotifier<BookDetailState> {
  late final _$args = ref.$arg as String;
  String get bookId => _$args;

  FutureOr<BookDetailState> build(String bookId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<BookDetailState>, BookDetailState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<BookDetailState>, BookDetailState>,
              AsyncValue<BookDetailState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
