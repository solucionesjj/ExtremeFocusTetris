import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/audio_service.dart';
import '../services/haptic_service.dart';

part 'providers.g.dart';

/// In-memory theme selection. Becomes Hive-backed in roadmap Phase 5
/// (Persistencia) without changing this provider's public surface.
@riverpod
class ThemeModeController extends _$ThemeModeController {
  @override
  ThemeMode build() => ThemeMode.system;

  void set(ThemeMode mode) => state = mode;
}

/// `null` means "follow the system locale", resolved against
/// [AppLocalizations.supportedLocales] by MaterialApp itself.
@riverpod
class LocaleController extends _$LocaleController {
  @override
  Locale? build() => null;

  void set(Locale? locale) => state = locale;
}

/// A single, app-lifetime [AudioService] instance — spec.md section 6.
/// `keepAlive` because it owns real player resources that must survive
/// even when nothing is currently watching it.
@Riverpod(keepAlive: true)
AudioService audioService(Ref ref) {
  final service = AudioService();
  ref.onDispose(() => service.dispose());
  return service;
}

/// A single, app-lifetime [HapticService] instance — spec.md section 6.4.
@Riverpod(keepAlive: true)
HapticService hapticService(Ref ref) => HapticService();
