import 'package:extreme_focus_tetris/core/l10n/generated/app_localizations.dart';
import 'package:extreme_focus_tetris/features/settings/presentation/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers/hive_test_setup.dart';

// Pumps SettingsScreen directly rather than through the full app + go_router
// (see navigation_test.dart for that flow) — this keeps the harness minimal
// for exercising the screen's own controls.
Future<AppLocalizations> _pumpSettingsScreen(WidgetTester tester) async {
  await tester.pumpWidget(
    const ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SettingsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return AppLocalizations.of(tester.element(find.byType(Scaffold).first))!;
}

// Every SettingsController setter calls `_persist()`, a fire-and-forget
// Hive `box.put()` — real (non-fake) async disk I/O. If a tap+pump runs
// under the test's normal FakeAsync zone and the test ends before that
// write's real I/O completion lands, `setUpHiveForTesting()`'s `tearDown()`
// deadlocks for real inside `box.clear()` (confirmed by bisecting with
// print markers — `start clear` prints, `settings cleared` never does).
// Wrapping the tap+pump+a short real delay in a single `tester.runAsync()`
// call fixes it: `runAsync` pauses FakeAsync and drives the real event
// loop until its callback's Future resolves, so the write actually
// finishes before this helper — and therefore the test body — returns.
Future<void> _tapAndLetHiveWriteSettle(WidgetTester tester, Finder finder) async {
  await tester.runAsync(() async {
    await tester.tap(finder);
    await tester.pump();
    await Future<void>.delayed(const Duration(milliseconds: 100));
  });
}

void main() {
  setUpHiveForTesting();

  testWidgets('accessibility toggles flip and reflect the new value', (tester) async {
    final l10n = await _pumpSettingsScreen(tester);

    // The accessibility controls sit below the fold.
    await tester.drag(find.byType(Scrollable), const Offset(0, -1000));
    await tester.pump();

    expect(find.text(l10n.settingsColorblindMode), findsOneWidget);
    expect(find.text(l10n.settingsHighContrast), findsOneWidget);
    expect(find.text(l10n.settingsReduceMotion), findsOneWidget);

    await _tapAndLetHiveWriteSettle(tester, find.text(l10n.settingsColorblindMode));
    await _tapAndLetHiveWriteSettle(tester, find.text(l10n.settingsHighContrast));
    await _tapAndLetHiveWriteSettle(tester, find.text(l10n.settingsReduceMotion));

    final colorblindSwitch = tester.widget<SwitchListTile>(
      find.ancestor(of: find.text(l10n.settingsColorblindMode), matching: find.byType(SwitchListTile)),
    );
    final highContrastSwitch = tester.widget<SwitchListTile>(
      find.ancestor(of: find.text(l10n.settingsHighContrast), matching: find.byType(SwitchListTile)),
    );
    final reduceMotionSwitch = tester.widget<SwitchListTile>(
      find.ancestor(of: find.text(l10n.settingsReduceMotion), matching: find.byType(SwitchListTile)),
    );

    expect(colorblindSwitch.value, isTrue);
    expect(highContrastSwitch.value, isTrue);
    expect(reduceMotionSwitch.value, isTrue);
  });

  testWidgets('toggles persist across a fresh SettingsScreen pump (simulated app restart)', (tester) async {
    final l10n = await _pumpSettingsScreen(tester);
    await tester.drag(find.byType(Scrollable), const Offset(0, -1000));
    await tester.pump();

    await _tapAndLetHiveWriteSettle(tester, find.text(l10n.settingsHighContrast));

    // Simulate reopening the app: pump a brand new SettingsScreen instance
    // against the same (still-open) Hive boxes.
    await _pumpSettingsScreen(tester);
    await tester.drag(find.byType(Scrollable), const Offset(0, -1000));
    await tester.pump();

    final highContrastSwitch = tester.widget<SwitchListTile>(
      find.ancestor(of: find.text(l10n.settingsHighContrast), matching: find.byType(SwitchListTile)),
    );
    expect(highContrastSwitch.value, isTrue);
  });

  testWidgets('text scale slider is bounded to 0.85-1.3', (tester) async {
    final l10n = await _pumpSettingsScreen(tester);

    await tester.drag(find.byType(Scrollable), const Offset(0, -1000));
    await tester.pump();

    final slider = tester.widget<Slider>(
      find.descendant(
        of: find.ancestor(of: find.text(l10n.settingsTextScale), matching: find.byType(ListTile)),
        matching: find.byType(Slider),
      ),
    );
    expect(slider.min, 0.85);
    expect(slider.max, 1.3);
  });

  testWidgets('the Theme SegmentedButton sits in a subtitle, not a too-narrow trailing', (tester) async {
    final l10n = await _pumpSettingsScreen(tester);

    // Regression guard for the Phase 8 bug where a 3-segment SegmentedButton
    // in ListTile.trailing squeezed the title down until "Theme"/"Tema"
    // wrapped one letter per line. Asserting it now lives under the title
    // (in subtitle) ensures nobody moves it back to trailing un-tested.
    final themeTile = tester.widget<ListTile>(
      find.ancestor(of: find.text(l10n.settingsTheme), matching: find.byType(ListTile)),
    );
    expect(themeTile.trailing, isNull);
    expect(
      find.descendant(of: find.byWidget(themeTile.subtitle!), matching: find.byType(SegmentedButton<ThemeMode>)),
      findsOneWidget,
    );
  });
}
