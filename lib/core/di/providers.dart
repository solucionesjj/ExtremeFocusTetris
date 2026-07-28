import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
