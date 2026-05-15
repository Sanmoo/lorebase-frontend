// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'series_detail_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$seriesDetailViewModelHash() =>
    r'c50e5acfc310b5d7a510a4378b0bab24bc2e964a';

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

abstract class _$SeriesDetailViewModel
    extends BuildlessAutoDisposeAsyncNotifier<SeriesDetailState> {
  late final int tmdbId;

  FutureOr<SeriesDetailState> build(
    int tmdbId,
  );
}

/// See also [SeriesDetailViewModel].
@ProviderFor(SeriesDetailViewModel)
const seriesDetailViewModelProvider = SeriesDetailViewModelFamily();

/// See also [SeriesDetailViewModel].
class SeriesDetailViewModelFamily
    extends Family<AsyncValue<SeriesDetailState>> {
  /// See also [SeriesDetailViewModel].
  const SeriesDetailViewModelFamily();

  /// See also [SeriesDetailViewModel].
  SeriesDetailViewModelProvider call(
    int tmdbId,
  ) {
    return SeriesDetailViewModelProvider(
      tmdbId,
    );
  }

  @override
  SeriesDetailViewModelProvider getProviderOverride(
    covariant SeriesDetailViewModelProvider provider,
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
  String? get name => r'seriesDetailViewModelProvider';
}

/// See also [SeriesDetailViewModel].
class SeriesDetailViewModelProvider
    extends AutoDisposeAsyncNotifierProviderImpl<SeriesDetailViewModel,
        SeriesDetailState> {
  /// See also [SeriesDetailViewModel].
  SeriesDetailViewModelProvider(
    int tmdbId,
  ) : this._internal(
          () => SeriesDetailViewModel()..tmdbId = tmdbId,
          from: seriesDetailViewModelProvider,
          name: r'seriesDetailViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$seriesDetailViewModelHash,
          dependencies: SeriesDetailViewModelFamily._dependencies,
          allTransitiveDependencies:
              SeriesDetailViewModelFamily._allTransitiveDependencies,
          tmdbId: tmdbId,
        );

  SeriesDetailViewModelProvider._internal(
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
  FutureOr<SeriesDetailState> runNotifierBuild(
    covariant SeriesDetailViewModel notifier,
  ) {
    return notifier.build(
      tmdbId,
    );
  }

  @override
  Override overrideWith(SeriesDetailViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: SeriesDetailViewModelProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<SeriesDetailViewModel,
      SeriesDetailState> createElement() {
    return _SeriesDetailViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SeriesDetailViewModelProvider && other.tmdbId == tmdbId;
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
mixin SeriesDetailViewModelRef
    on AutoDisposeAsyncNotifierProviderRef<SeriesDetailState> {
  /// The parameter `tmdbId` of this provider.
  int get tmdbId;
}

class _SeriesDetailViewModelProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<SeriesDetailViewModel,
        SeriesDetailState> with SeriesDetailViewModelRef {
  _SeriesDetailViewModelProviderElement(super.provider);

  @override
  int get tmdbId => (origin as SeriesDetailViewModelProvider).tmdbId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
