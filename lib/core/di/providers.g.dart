// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$audioServiceHash() => r'010adb07618eeb58ad083f9a779873d496d836ee';

/// A single, app-lifetime [AudioService] instance — spec.md section 6.
/// `keepAlive` because it owns real player resources that must survive
/// even when nothing is currently watching it.
///
/// Copied from [audioService].
@ProviderFor(audioService)
final audioServiceProvider = Provider<AudioService>.internal(
  audioService,
  name: r'audioServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$audioServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AudioServiceRef = ProviderRef<AudioService>;
String _$hapticServiceHash() => r'537e7497e0ed36555af69b5b37e9056e25dbbbfd';

/// A single, app-lifetime [HapticService] instance — spec.md section 6.4.
///
/// Copied from [hapticService].
@ProviderFor(hapticService)
final hapticServiceProvider = Provider<HapticService>.internal(
  hapticService,
  name: r'hapticServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hapticServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HapticServiceRef = ProviderRef<HapticService>;
String _$settingsRepositoryHash() =>
    r'2ba63172eec044dcaaafdfdbdacd939422a8ca82';

/// spec.md section 13 (`settings_box`). The Hive box must already be open
/// (see `main.dart`) by the time anything reads this provider.
///
/// Copied from [settingsRepository].
@ProviderFor(settingsRepository)
final settingsRepositoryProvider = Provider<SettingsRepository>.internal(
  settingsRepository,
  name: r'settingsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$settingsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SettingsRepositoryRef = ProviderRef<SettingsRepository>;
String _$statisticsRepositoryHash() =>
    r'56576cbd64dc454f8920cfb31ed94f304cf58bbe';

/// spec.md section 13 (`stats_box`).
///
/// Copied from [statisticsRepository].
@ProviderFor(statisticsRepository)
final statisticsRepositoryProvider = Provider<StatisticsRepository>.internal(
  statisticsRepository,
  name: r'statisticsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$statisticsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StatisticsRepositoryRef = ProviderRef<StatisticsRepository>;
String _$gameRepositoryHash() => r'51fb89472ba54150e781dd6f9bee468eec8f7ada';

/// spec.md section 13 (`session_box`).
///
/// Copied from [gameRepository].
@ProviderFor(gameRepository)
final gameRepositoryProvider = Provider<GameRepository>.internal(
  gameRepository,
  name: r'gameRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$gameRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GameRepositoryRef = ProviderRef<GameRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
