// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_profile_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SocialProfileViewModel)
final socialProfileViewModelProvider = SocialProfileViewModelFamily._();

final class SocialProfileViewModelProvider
    extends
        $AsyncNotifierProvider<
          SocialProfileViewModel,
          SocialProfileDetailState
        > {
  SocialProfileViewModelProvider._({
    required SocialProfileViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'socialProfileViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$socialProfileViewModelHash();

  @override
  String toString() {
    return r'socialProfileViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SocialProfileViewModel create() => SocialProfileViewModel();

  @override
  bool operator ==(Object other) {
    return other is SocialProfileViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$socialProfileViewModelHash() =>
    r'2e5780f9725451f3e0da84d4033b68035f036be5';

final class SocialProfileViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          SocialProfileViewModel,
          AsyncValue<SocialProfileDetailState>,
          SocialProfileDetailState,
          FutureOr<SocialProfileDetailState>,
          String
        > {
  SocialProfileViewModelFamily._()
    : super(
        retry: null,
        name: r'socialProfileViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SocialProfileViewModelProvider call(String userId) =>
      SocialProfileViewModelProvider._(argument: userId, from: this);

  @override
  String toString() => r'socialProfileViewModelProvider';
}

abstract class _$SocialProfileViewModel
    extends $AsyncNotifier<SocialProfileDetailState> {
  late final _$args = ref.$arg as String;
  String get userId => _$args;

  FutureOr<SocialProfileDetailState> build(String userId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<SocialProfileDetailState>,
              SocialProfileDetailState
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<SocialProfileDetailState>,
                SocialProfileDetailState
              >,
              AsyncValue<SocialProfileDetailState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
