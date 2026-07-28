// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'line_clear_event_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$lineClearEventControllerHash() =>
    r'78b4fa6e58bc876758509b757b5d81a03b9bce6d';

/// A one-shot event stream (spec.md section 18): [GameController] emits
/// here whenever a lock clears at least one line, and `GameScreen` listens
/// via `ref.listen` to trigger particles/flash/shake without any of that
/// visual bookkeeping leaking into [GameState] itself.
///
/// Copied from [LineClearEventController].
@ProviderFor(LineClearEventController)
final lineClearEventControllerProvider =
    AutoDisposeNotifierProvider<
      LineClearEventController,
      LineClearEvent?
    >.internal(
      LineClearEventController.new,
      name: r'lineClearEventControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$lineClearEventControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$LineClearEventController = AutoDisposeNotifier<LineClearEvent?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
