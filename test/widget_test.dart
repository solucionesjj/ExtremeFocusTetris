import 'package:extreme_focus_tetris/app.dart';
import 'package:extreme_focus_tetris/core/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the localized home placeholder without crashing', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: ExtremeFocusTetrisApp()),
    );
    await tester.pumpAndSettle();

    final scaffoldContext = tester.element(find.byType(Scaffold));
    final l10n = AppLocalizations.of(scaffoldContext)!;

    expect(find.text(l10n.homeScaffoldPlaceholder), findsOneWidget);
  });
}
