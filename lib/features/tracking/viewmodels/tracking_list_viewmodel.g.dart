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
          AsyncValue<TrackingListState>
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
  Override overrideWithValue(AsyncValue<TrackingListState> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<TrackingListState>>(
        value,
      ),
    );
  }
}

String _$trackingListViewModelHash() =>
    r'8671441fb678e275767fc2e76c3af57b8d69f430';

abstract class _$TrackingListViewModel
    extends $Notifier<AsyncValue<TrackingListState>> {
  AsyncValue<TrackingListState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<TrackingListState>,
              AsyncValue<TrackingListState>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<TrackingListState>,
                AsyncValue<TrackingListState>
              >,
              AsyncValue<TrackingListState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
