// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$settingsControllerHash() =>
    r'8aef3ed786420d95d4880e3d98306f88c91a5f63';

/// Owns user preferences (spec.md section 12), persists them to Hive's
/// `settings_box` (spec.md section 13) on every change, and immediately
/// applies the audio/haptic ones to [AudioService]/[HapticService].
///
/// Copied from [SettingsController].
@ProviderFor(SettingsController)
final settingsControllerProvider =
    AutoDisposeNotifierProvider<SettingsController, SettingsState>.internal(
      SettingsController.new,
      name: r'settingsControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$settingsControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SettingsController = AutoDisposeNotifier<SettingsState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
