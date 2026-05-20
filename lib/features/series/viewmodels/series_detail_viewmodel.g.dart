// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'series_detail_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SeriesDetailViewModel)
final seriesDetailViewModelProvider = SeriesDetailViewModelFamily._();

final class SeriesDetailViewModelProvider
    extends $AsyncNotifierProvider<SeriesDetailViewModel, SeriesDetailState> {
  SeriesDetailViewModelProvider._({
    required SeriesDetailViewModelFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'seriesDetailViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$seriesDetailViewModelHash();

  @override
  String toString() {
    return r'seriesDetailViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SeriesDetailViewModel create() => SeriesDetailViewModel();

  @override
  bool operator ==(Object other) {
    return other is SeriesDetailViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$seriesDetailViewModelHash() =>
    r'9de261bd690931889463ebafc31bcb2812b909ed';

final class SeriesDetailViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          SeriesDetailViewModel,
          AsyncValue<SeriesDetailState>,
          SeriesDetailState,
          FutureOr<SeriesDetailState>,
          int
        > {
  SeriesDetailViewModelFamily._()
    : super(
        retry: null,
        name: r'seriesDetailViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SeriesDetailViewModelProvider call(int tmdbId) =>
      SeriesDetailViewModelProvider._(argument: tmdbId, from: this);

  @override
  String toString() => r'seriesDetailViewModelProvider';
}

abstract class _$SeriesDetailViewModel
    extends $AsyncNotifier<SeriesDetailState> {
  late final _$args = ref.$arg as int;
  int get tmdbId => _$args;

  FutureOr<SeriesDetailState> build(int tmdbId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<SeriesDetailState>, SeriesDetailState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SeriesDetailState>, SeriesDetailState>,
              AsyncValue<SeriesDetailState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
