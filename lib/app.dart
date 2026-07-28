import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/di/providers.dart';
import 'core/l10n/generated/app_localizations.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme_dark.dart';
import 'core/theme/app_theme_light.dart';

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
    final themeMode = ref.watch(themeModeControllerProvider);
    final locale = ref.watch(localeControllerProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppThemeLight.theme,
      darkTheme: AppThemeDark.theme,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: _router,
    );
  }
}
