// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_detail_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GameDetailViewModel)
final gameDetailViewModelProvider = GameDetailViewModelFamily._();

final class GameDetailViewModelProvider
    extends $AsyncNotifierProvider<GameDetailViewModel, GameDetailState> {
  GameDetailViewModelProvider._({
    required GameDetailViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'gameDetailViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$gameDetailViewModelHash();

  @override
  String toString() {
    return r'gameDetailViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  GameDetailViewModel create() => GameDetailViewModel();

  @override
  bool operator ==(Object other) {
    return other is GameDetailViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$gameDetailViewModelHash() =>
    r'c3f90ea6402261bf4b0770ee9f71f569d2fb4bbc';

final class GameDetailViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          GameDetailViewModel,
          AsyncValue<GameDetailState>,
          GameDetailState,
          FutureOr<GameDetailState>,
          String
        > {
  GameDetailViewModelFamily._()
    : super(
        retry: null,
        name: r'gameDetailViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GameDetailViewModelProvider call(String gameId) =>
      GameDetailViewModelProvider._(argument: gameId, from: this);

  @override
  String toString() => r'gameDetailViewModelProvider';
}

abstract class _$GameDetailViewModel extends $AsyncNotifier<GameDetailState> {
  late final _$args = ref.$arg as String;
  String get gameId => _$args;

  FutureOr<GameDetailState> build(String gameId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<GameDetailState>, GameDetailState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<GameDetailState>, GameDetailState>,
              AsyncValue<GameDetailState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
