// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RegisterViewModel)
final registerViewModelProvider = RegisterViewModelProvider._();

final class RegisterViewModelProvider
    extends $NotifierProvider<RegisterViewModel, RegisterState> {
  RegisterViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'registerViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$registerViewModelHash();

  @$internal
  @override
  RegisterViewModel create() => RegisterViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RegisterState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RegisterState>(value),
    );
  }
}

String _$registerViewModelHash() => r'f3c802f1e33b98cadbf6aee74a5d644088d14860';

abstract class _$RegisterViewModel extends $Notifier<RegisterState> {
  RegisterState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<RegisterState, RegisterState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RegisterState, RegisterState>,
              RegisterState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
