import 'package:extreme_focus_tetris/app.dart';
import 'package:extreme_focus_tetris/core/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers/hive_test_setup.dart';

void main() {
  setUpHiveForTesting();

  testWidgets('navigates from Splash to Home and renders localized content', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: ExtremeFocusTetrisApp()),
    );

    // Splash navigates away after ~800ms (spec.md section 10.2).
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(Scaffold).first);
    final l10n = AppLocalizations.of(context)!;

    expect(find.text(l10n.homePlayButton), findsOneWidget);
  });
}
