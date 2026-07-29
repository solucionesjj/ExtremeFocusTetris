import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/l10n/generated/app_localizations.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme_dark.dart';
import 'core/theme/app_theme_high_contrast_dark.dart';
import 'core/theme/app_theme_high_contrast_light.dart';
import 'core/theme/app_theme_light.dart';
import 'features/settings/presentation/viewmodels/settings_controller.dart';

class ExtremeFocusTetrisApp extends ConsumerStatefulWidget {
  const ExtremeFocusTetrisApp({super.key});

  @override
  ConsumerState<ExtremeFocusTetrisApp> createState() => _ExtremeFocusTetrisAppState();
}

class _ExtremeFocusTetrisAppState extends ConsumerState<ExtremeFocusTetrisApp> {
  // Created once per app run (not per build), so navigation state survives
  // theme/locale changes — see the doc comment on createAppRouter().
  late final GoRouter _router = createAppRouter();

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      themeMode: settings.themeMode,
      theme: settings.highContrast ? AppThemeHighContrastLight.theme : AppThemeLight.theme,
      darkTheme: settings.highContrast ? AppThemeHighContrastDark.theme : AppThemeDark.theme,
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: _router,
      // Accessibility text scaling (spec.md section 14: 0.85x-1.3x), applied
      // app-wide instead of layering on top of the system's own scale — the
      // slider in Settings is the single control the player has for this.
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(settings.textScale)),
        child: child!,
      ),
    );
  }
}
