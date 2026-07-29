import 'package:extreme_focus_tetris/core/l10n/generated/app_localizations.dart';
import 'package:extreme_focus_tetris/core/theme/app_theme_dark.dart';
import 'package:extreme_focus_tetris/core/theme/app_theme_light.dart';
import 'package:extreme_focus_tetris/features/home/presentation/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers/hive_test_setup.dart';

// spec.md section 21's "tema claro y oscuro" golden scope. HomeScreen has
// no internal randomness (unlike GameScreen's 7-bag), so it's a safe,
// reproducible surface for a light/dark visual regression snapshot.
Future<void> _pumpHome(WidgetTester tester, ThemeData theme) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: theme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const HomeScreen(),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  setUpHiveForTesting();

  testWidgets('Home screen — light theme (Day Focus)', (tester) async {
    await _pumpHome(tester, AppThemeLight.theme);
    await expectLater(find.byType(HomeScreen), matchesGoldenFile('goldens/home_theme_light.png'));
  });

  testWidgets('Home screen — dark theme (Night Focus)', (tester) async {
    await _pumpHome(tester, AppThemeDark.theme);
    await expectLater(find.byType(HomeScreen), matchesGoldenFile('goldens/home_theme_dark.png'));
  });
}
