// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistics_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$statisticsControllerHash() =>
    r'a32b39963e33c36f67c28279914b3b83ea4b1117';

/// Accumulated statistics — spec.md section 8.9, persisted in Hive's
/// `stats_box` (spec.md section 13).
///
/// Copied from [StatisticsController].
@ProviderFor(StatisticsController)
final statisticsControllerProvider =
    AutoDisposeNotifierProvider<StatisticsController, StatisticsState>.internal(
      StatisticsController.new,
      name: r'statisticsControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$statisticsControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$StatisticsController = AutoDisposeNotifier<StatisticsState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
