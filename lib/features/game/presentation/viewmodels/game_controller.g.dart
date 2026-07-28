// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$gameControllerHash() => r'89a06205ad88ced9c4829a8883849bb779ca8f40';

/// Owns the in-progress [GameState] and the gravity / lock-delay bookkeeping
/// that a real-time ticker (see `GameTickerService`) drives via [onTick].
/// Every mutation is delegated to a pure domain use case; this class only
/// decides *when* to call them, which sound/haptic (spec.md section 6) each
/// outcome deserves, and when to persist a session snapshot or the final
/// tally for a finished game (spec.md section 13).
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
