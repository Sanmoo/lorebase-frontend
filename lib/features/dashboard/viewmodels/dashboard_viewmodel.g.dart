// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DashboardViewModel)
final dashboardViewModelProvider = DashboardViewModelProvider._();

final class DashboardViewModelProvider
    extends $NotifierProvider<DashboardViewModel, AsyncValue<DashboardModel>> {
  DashboardViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardViewModelHash();

  @$internal
  @override
  DashboardViewModel create() => DashboardViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<DashboardModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<DashboardModel>>(value),
    );
  }
}

String _$dashboardViewModelHash() =>
    r'c26938677d682fe185659a1ec46238aeaf055796';

abstract class _$DashboardViewModel
    extends $Notifier<AsyncValue<DashboardModel>> {
  AsyncValue<DashboardModel> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<DashboardModel>, AsyncValue<DashboardModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<DashboardModel>,
                AsyncValue<DashboardModel>
              >,
              AsyncValue<DashboardModel>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
