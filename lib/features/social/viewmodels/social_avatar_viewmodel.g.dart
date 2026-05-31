// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_avatar_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SocialAvatarViewModel)
final socialAvatarViewModelProvider = SocialAvatarViewModelProvider._();

final class SocialAvatarViewModelProvider
    extends $NotifierProvider<SocialAvatarViewModel, SocialAvatarState> {
  SocialAvatarViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'socialAvatarViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$socialAvatarViewModelHash();

  @$internal
  @override
  SocialAvatarViewModel create() => SocialAvatarViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SocialAvatarState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SocialAvatarState>(value),
    );
  }
}

String _$socialAvatarViewModelHash() =>
    r'0f9e6208a5e6c5f9209bc556b64e505223abc117';

abstract class _$SocialAvatarViewModel extends $Notifier<SocialAvatarState> {
  SocialAvatarState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SocialAvatarState, SocialAvatarState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SocialAvatarState, SocialAvatarState>,
              SocialAvatarState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
