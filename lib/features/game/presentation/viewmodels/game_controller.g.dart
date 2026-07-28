// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$gameControllerHash() => r'03c670f3f92b0ceda8ee366575f29894315fb908';

/// Owns the in-progress [GameState] and the gravity / lock-delay bookkeeping
/// that a real-time ticker (see `GameTickerService`) drives via [onTick].
/// Every mutation is delegated to a pure domain use case; this class only
/// decides *when* to call them.
///
/// Copied from [GameController].
@ProviderFor(GameController)
final gameControllerProvider =
    AutoDisposeNotifierProvider<GameController, GameState?>.internal(
      GameController.new,
      name: r'gameControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$gameControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GameController = AutoDisposeNotifier<GameState?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
