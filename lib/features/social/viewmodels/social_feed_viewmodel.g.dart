// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_feed_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SocialFeedViewModel)
final socialFeedViewModelProvider = SocialFeedViewModelProvider._();

final class SocialFeedViewModelProvider
    extends
        $AsyncNotifierProvider<
          SocialFeedViewModel,
          PaginatedSocialResponse<ActivityEventModel>
        > {
  SocialFeedViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'socialFeedViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$socialFeedViewModelHash();

  @$internal
  @override
  SocialFeedViewModel create() => SocialFeedViewModel();
}

String _$socialFeedViewModelHash() =>
    r'5f79fff25090f29746a345a1412b86e0e07aba30';

abstract class _$SocialFeedViewModel
    extends $AsyncNotifier<PaginatedSocialResponse<ActivityEventModel>> {
  FutureOr<PaginatedSocialResponse<ActivityEventModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<PaginatedSocialResponse<ActivityEventModel>>,
              PaginatedSocialResponse<ActivityEventModel>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PaginatedSocialResponse<ActivityEventModel>>,
                PaginatedSocialResponse<ActivityEventModel>
              >,
              AsyncValue<PaginatedSocialResponse<ActivityEventModel>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
