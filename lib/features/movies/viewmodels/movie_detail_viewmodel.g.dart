// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_detail_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$movieDetailViewModelHash() =>
    r'ce1e1da37d9b112a95718469918f75eb5b046a6a';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$MovieDetailViewModel
    extends BuildlessAutoDisposeAsyncNotifier<MovieDetailState> {
  late final int tmdbId;

  FutureOr<MovieDetailState> build(
    int tmdbId,
  );
}

/// See also [MovieDetailViewModel].
@ProviderFor(MovieDetailViewModel)
const movieDetailViewModelProvider = MovieDetailViewModelFamily();

/// See also [MovieDetailViewModel].
class MovieDetailViewModelFamily extends Family<AsyncValue<MovieDetailState>> {
  /// See also [MovieDetailViewModel].
  const MovieDetailViewModelFamily();

  /// See also [MovieDetailViewModel].
  MovieDetailViewModelProvider call(
    int tmdbId,
  ) {
    return MovieDetailViewModelProvider(
      tmdbId,
    );
  }

  @override
  MovieDetailViewModelProvider getProviderOverride(
    covariant MovieDetailViewModelProvider provider,
  ) {
    return call(
      provider.tmdbId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'movieDetailViewModelProvider';
}

/// See also [MovieDetailViewModel].
class MovieDetailViewModelProvider extends AutoDisposeAsyncNotifierProviderImpl<
    MovieDetailViewModel, MovieDetailState> {
  /// See also [MovieDetailViewModel].
  MovieDetailViewModelProvider(
    int tmdbId,
  ) : this._internal(
          () => MovieDetailViewModel()..tmdbId = tmdbId,
          from: movieDetailViewModelProvider,
          name: r'movieDetailViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$movieDetailViewModelHash,
          dependencies: MovieDetailViewModelFamily._dependencies,
          allTransitiveDependencies:
              MovieDetailViewModelFamily._allTransitiveDependencies,
          tmdbId: tmdbId,
        );

  MovieDetailViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.tmdbId,
  }) : super.internal();

  final int tmdbId;

  @override
  FutureOr<MovieDetailState> runNotifierBuild(
    covariant MovieDetailViewModel notifier,
  ) {
    return notifier.build(
      tmdbId,
    );
  }

  @override
  Override overrideWith(MovieDetailViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: MovieDetailViewModelProvider._internal(
        () => create()..tmdbId = tmdbId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        tmdbId: tmdbId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<MovieDetailViewModel,
      MovieDetailState> createElement() {
    return _MovieDetailViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MovieDetailViewModelProvider && other.tmdbId == tmdbId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tmdbId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MovieDetailViewModelRef
    on AutoDisposeAsyncNotifierProviderRef<MovieDetailState> {
  /// The parameter `tmdbId` of this provider.
  int get tmdbId;
}

class _MovieDetailViewModelProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<MovieDetailViewModel,
        MovieDetailState> with MovieDetailViewModelRef {
  _MovieDetailViewModelProviderElement(super.provider);

  @override
  int get tmdbId => (origin as MovieDetailViewModelProvider).tmdbId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
