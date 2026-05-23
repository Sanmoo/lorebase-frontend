// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_discover_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SocialDiscoverViewModel)
final socialDiscoverViewModelProvider = SocialDiscoverViewModelProvider._();

final class SocialDiscoverViewModelProvider
    extends
        $AsyncNotifierProvider<
          SocialDiscoverViewModel,
          PaginatedSocialResponse<DiscoverUserModel>
        > {
  SocialDiscoverViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: _noSocialDiscoverRetry,
        name: r'socialDiscoverViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$socialDiscoverViewModelHash();

  @$internal
  @override
  SocialDiscoverViewModel create() => SocialDiscoverViewModel();
}

String _$socialDiscoverViewModelHash() =>
    r'42997681c92e16738a51071d5538bcee50d4ea6a';

abstract class _$SocialDiscoverViewModel
    extends $AsyncNotifier<PaginatedSocialResponse<DiscoverUserModel>> {
  FutureOr<PaginatedSocialResponse<DiscoverUserModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<PaginatedSocialResponse<DiscoverUserModel>>,
              PaginatedSocialResponse<DiscoverUserModel>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PaginatedSocialResponse<DiscoverUserModel>>,
                PaginatedSocialResponse<DiscoverUserModel>
              >,
              AsyncValue<PaginatedSocialResponse<DiscoverUserModel>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
