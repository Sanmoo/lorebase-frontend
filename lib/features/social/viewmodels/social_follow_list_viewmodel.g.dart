// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_follow_list_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SocialFollowListViewModel)
final socialFollowListViewModelProvider = SocialFollowListViewModelFamily._();

final class SocialFollowListViewModelProvider
    extends
        $AsyncNotifierProvider<
          SocialFollowListViewModel,
          PaginatedSocialResponse<FollowRelationshipModel>
        > {
  SocialFollowListViewModelProvider._({
    required SocialFollowListViewModelFamily super.from,
    required (String, SocialFollowListKind) super.argument,
  }) : super(
         retry: null,
         name: r'socialFollowListViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$socialFollowListViewModelHash();

  @override
  String toString() {
    return r'socialFollowListViewModelProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  SocialFollowListViewModel create() => SocialFollowListViewModel();

  @override
  bool operator ==(Object other) {
    return other is SocialFollowListViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$socialFollowListViewModelHash() =>
    r'449b6d0800f49bc0bd07608332ef5526b7dea3c1';

final class SocialFollowListViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          SocialFollowListViewModel,
          AsyncValue<PaginatedSocialResponse<FollowRelationshipModel>>,
          PaginatedSocialResponse<FollowRelationshipModel>,
          FutureOr<PaginatedSocialResponse<FollowRelationshipModel>>,
          (String, SocialFollowListKind)
        > {
  SocialFollowListViewModelFamily._()
    : super(
        retry: null,
        name: r'socialFollowListViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SocialFollowListViewModelProvider call(
    String userId,
    SocialFollowListKind kind,
  ) =>
      SocialFollowListViewModelProvider._(argument: (userId, kind), from: this);

  @override
  String toString() => r'socialFollowListViewModelProvider';
}

abstract class _$SocialFollowListViewModel
    extends $AsyncNotifier<PaginatedSocialResponse<FollowRelationshipModel>> {
  late final _$args = ref.$arg as (String, SocialFollowListKind);
  String get userId => _$args.$1;
  SocialFollowListKind get kind => _$args.$2;

  FutureOr<PaginatedSocialResponse<FollowRelationshipModel>> build(
    String userId,
    SocialFollowListKind kind,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<PaginatedSocialResponse<FollowRelationshipModel>>,
              PaginatedSocialResponse<FollowRelationshipModel>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PaginatedSocialResponse<FollowRelationshipModel>>,
                PaginatedSocialResponse<FollowRelationshipModel>
              >,
              AsyncValue<PaginatedSocialResponse<FollowRelationshipModel>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}
