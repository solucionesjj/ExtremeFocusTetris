// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$gameControllerHash() => r'4d198ce95d2f72a8dbf0d2f2603a67f900bf7f5f';

/// Owns the in-progress [GameState] and the gravity / lock-delay bookkeeping
/// that a real-time ticker (see `GameTickerService`) drives via [onTick].
/// Every mutation is delegated to a pure domain use case; this class only
/// decides *when* to call them, and which sound/haptic (spec.md section 6)
/// each outcome deserves.
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
