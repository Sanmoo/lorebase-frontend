// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_detail_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MovieDetailViewModel)
final movieDetailViewModelProvider = MovieDetailViewModelFamily._();

final class MovieDetailViewModelProvider
    extends $AsyncNotifierProvider<MovieDetailViewModel, MovieDetailState> {
  MovieDetailViewModelProvider._({
    required MovieDetailViewModelFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'movieDetailViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$movieDetailViewModelHash();

  @override
  String toString() {
    return r'movieDetailViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MovieDetailViewModel create() => MovieDetailViewModel();

  @override
  bool operator ==(Object other) {
    return other is MovieDetailViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$movieDetailViewModelHash() =>
    r'81e171334142569f0c267eb11b49b4301d6c9480';

final class MovieDetailViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          MovieDetailViewModel,
          AsyncValue<MovieDetailState>,
          MovieDetailState,
          FutureOr<MovieDetailState>,
          int
        > {
  MovieDetailViewModelFamily._()
    : super(
        retry: null,
        name: r'movieDetailViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MovieDetailViewModelProvider call(int tmdbId) =>
      MovieDetailViewModelProvider._(argument: tmdbId, from: this);

  @override
  String toString() => r'movieDetailViewModelProvider';
}

abstract class _$MovieDetailViewModel extends $AsyncNotifier<MovieDetailState> {
  late final _$args = ref.$arg as int;
  int get tmdbId => _$args;

  FutureOr<MovieDetailState> build(int tmdbId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<MovieDetailState>, MovieDetailState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<MovieDetailState>, MovieDetailState>,
              AsyncValue<MovieDetailState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
