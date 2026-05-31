// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_list_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TrackingListViewModel)
final trackingListViewModelProvider = TrackingListViewModelProvider._();

final class TrackingListViewModelProvider
    extends
        $NotifierProvider<
          TrackingListViewModel,
          AsyncValue<List<TrackedMediaModel>>
        > {
  TrackingListViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trackingListViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trackingListViewModelHash();

  @$internal
  @override
  TrackingListViewModel create() => TrackingListViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<TrackedMediaModel>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<TrackedMediaModel>>>(
        value,
      ),
    );
  }
}

String _$trackingListViewModelHash() =>
    r'6b336fa6cca42837256a41656510cd3bc8a3fe63';

abstract class _$TrackingListViewModel
    extends $Notifier<AsyncValue<List<TrackedMediaModel>>> {
  AsyncValue<List<TrackedMediaModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<TrackedMediaModel>>,
              AsyncValue<List<TrackedMediaModel>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<TrackedMediaModel>>,
                AsyncValue<List<TrackedMediaModel>>
              >,
              AsyncValue<List<TrackedMediaModel>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
