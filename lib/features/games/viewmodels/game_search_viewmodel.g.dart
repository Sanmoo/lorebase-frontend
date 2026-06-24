// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_search_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GameSearchViewModel)
final gameSearchViewModelProvider = GameSearchViewModelProvider._();

final class GameSearchViewModelProvider
    extends
        $NotifierProvider<GameSearchViewModel, AsyncValue<List<GameModel>>> {
  GameSearchViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gameSearchViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gameSearchViewModelHash();

  @$internal
  @override
  GameSearchViewModel create() => GameSearchViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<GameModel>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<GameModel>>>(value),
    );
  }
}

String _$gameSearchViewModelHash() =>
    r'864050441fefb9c2a2a8aa06be7a9afb09d3ebdb';

abstract class _$GameSearchViewModel
    extends $Notifier<AsyncValue<List<GameModel>>> {
  AsyncValue<List<GameModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<GameModel>>, AsyncValue<List<GameModel>>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<GameModel>>,
                AsyncValue<List<GameModel>>
              >,
              AsyncValue<List<GameModel>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
