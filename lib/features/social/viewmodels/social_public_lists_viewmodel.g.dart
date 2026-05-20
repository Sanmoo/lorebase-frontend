// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_public_lists_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SocialPublicListsViewModel)
final socialPublicListsViewModelProvider = SocialPublicListsViewModelFamily._();

final class SocialPublicListsViewModelProvider
    extends
        $AsyncNotifierProvider<
          SocialPublicListsViewModel,
          PaginatedSocialResponse<PublicListItemModel>
        > {
  SocialPublicListsViewModelProvider._({
    required SocialPublicListsViewModelFamily super.from,
    required (String, {String? status, String? mediaType}) super.argument,
  }) : super(
         retry: null,
         name: r'socialPublicListsViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$socialPublicListsViewModelHash();

  @override
  String toString() {
    return r'socialPublicListsViewModelProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  SocialPublicListsViewModel create() => SocialPublicListsViewModel();

  @override
  bool operator ==(Object other) {
    return other is SocialPublicListsViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$socialPublicListsViewModelHash() =>
    r'a87f7e4f1446a1dadcc97ca119836f9adff84f31';

final class SocialPublicListsViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          SocialPublicListsViewModel,
          AsyncValue<PaginatedSocialResponse<PublicListItemModel>>,
          PaginatedSocialResponse<PublicListItemModel>,
          FutureOr<PaginatedSocialResponse<PublicListItemModel>>,
          (String, {String? status, String? mediaType})
        > {
  SocialPublicListsViewModelFamily._()
    : super(
        retry: null,
        name: r'socialPublicListsViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SocialPublicListsViewModelProvider call(
    String userId, {
    String? status,
    String? mediaType,
  }) => SocialPublicListsViewModelProvider._(
    argument: (userId, status: status, mediaType: mediaType),
    from: this,
  );

  @override
  String toString() => r'socialPublicListsViewModelProvider';
}

abstract class _$SocialPublicListsViewModel
    extends $AsyncNotifier<PaginatedSocialResponse<PublicListItemModel>> {
  late final _$args = ref.$arg as (String, {String? status, String? mediaType});
  String get userId => _$args.$1;
  String? get status => _$args.status;
  String? get mediaType => _$args.mediaType;

  FutureOr<PaginatedSocialResponse<PublicListItemModel>> build(
    String userId, {
    String? status,
    String? mediaType,
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<PaginatedSocialResponse<PublicListItemModel>>,
              PaginatedSocialResponse<PublicListItemModel>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PaginatedSocialResponse<PublicListItemModel>>,
                PaginatedSocialResponse<PublicListItemModel>
              >,
              AsyncValue<PaginatedSocialResponse<PublicListItemModel>>,
              Object?,
              Object?
            >;
    element.handleCreate(
      ref,
      () =>
          build(_$args.$1, status: _$args.status, mediaType: _$args.mediaType),
    );
  }
}
