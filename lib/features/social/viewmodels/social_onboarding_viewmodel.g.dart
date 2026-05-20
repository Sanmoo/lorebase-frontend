// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_onboarding_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SocialOnboardingViewModel)
final socialOnboardingViewModelProvider = SocialOnboardingViewModelProvider._();

final class SocialOnboardingViewModelProvider
    extends
        $NotifierProvider<SocialOnboardingViewModel, SocialOnboardingState> {
  SocialOnboardingViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'socialOnboardingViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$socialOnboardingViewModelHash();

  @$internal
  @override
  SocialOnboardingViewModel create() => SocialOnboardingViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SocialOnboardingState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SocialOnboardingState>(value),
    );
  }
}

String _$socialOnboardingViewModelHash() =>
    r'335f89ebaa834c8c7fcddb2e0dbfaec46229062d';

abstract class _$SocialOnboardingViewModel
    extends $Notifier<SocialOnboardingState> {
  SocialOnboardingState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SocialOnboardingState, SocialOnboardingState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SocialOnboardingState, SocialOnboardingState>,
              SocialOnboardingState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
