// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'series_search_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SeriesSearchViewModel)
final seriesSearchViewModelProvider = SeriesSearchViewModelProvider._();

final class SeriesSearchViewModelProvider
    extends
        $NotifierProvider<
          SeriesSearchViewModel,
          AsyncValue<List<SeriesModel>>
        > {
  SeriesSearchViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'seriesSearchViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$seriesSearchViewModelHash();

  @$internal
  @override
  SeriesSearchViewModel create() => SeriesSearchViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<SeriesModel>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<SeriesModel>>>(
        value,
      ),
    );
  }
}

String _$seriesSearchViewModelHash() =>
    r'd994b8d5e03fda92d1d9c56c3b07d67b1afaff33';

abstract class _$SeriesSearchViewModel
    extends $Notifier<AsyncValue<List<SeriesModel>>> {
  AsyncValue<List<SeriesModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<SeriesModel>>,
              AsyncValue<List<SeriesModel>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<SeriesModel>>,
                AsyncValue<List<SeriesModel>>
              >,
              AsyncValue<List<SeriesModel>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
