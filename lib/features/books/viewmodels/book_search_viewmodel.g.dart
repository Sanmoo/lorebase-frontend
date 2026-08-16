// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_search_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BookSearchViewModel)
final bookSearchViewModelProvider = BookSearchViewModelProvider._();

final class BookSearchViewModelProvider
    extends
        $NotifierProvider<BookSearchViewModel, AsyncValue<List<BookModel>>> {
  BookSearchViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookSearchViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookSearchViewModelHash();

  @$internal
  @override
  BookSearchViewModel create() => BookSearchViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<BookModel>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<BookModel>>>(value),
    );
  }
}

String _$bookSearchViewModelHash() =>
    r'3ef3e0f6b12ce738460189db40be8b69c7f5e10d';

abstract class _$BookSearchViewModel
    extends $Notifier<AsyncValue<List<BookModel>>> {
  AsyncValue<List<BookModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<BookModel>>, AsyncValue<List<BookModel>>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<BookModel>>,
                AsyncValue<List<BookModel>>
              >,
              AsyncValue<List<BookModel>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
