// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_search_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MovieSearchViewModel)
final movieSearchViewModelProvider = MovieSearchViewModelProvider._();

final class MovieSearchViewModelProvider
    extends
        $NotifierProvider<MovieSearchViewModel, AsyncValue<List<MovieModel>>> {
  MovieSearchViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'movieSearchViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$movieSearchViewModelHash();

  @$internal
  @override
  MovieSearchViewModel create() => MovieSearchViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<MovieModel>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<MovieModel>>>(value),
    );
  }
}

String _$movieSearchViewModelHash() =>
    r'3188640473b636d7a76621022541f56cd14c4772';

abstract class _$MovieSearchViewModel
    extends $Notifier<AsyncValue<List<MovieModel>>> {
  AsyncValue<List<MovieModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<MovieModel>>, AsyncValue<List<MovieModel>>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<MovieModel>>,
                AsyncValue<List<MovieModel>>
              >,
              AsyncValue<List<MovieModel>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
