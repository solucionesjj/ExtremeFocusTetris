import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/services/game_ticker_service.dart';
import '../domain/entities/game_status.dart';
import 'viewmodels/game_controller.dart';
import 'widgets/board_painter.dart';
import 'widgets/hold_widget.dart';
import 'widgets/next_queue_widget.dart';
import 'widgets/touch_controls.dart';

/// The Game screen's core content — board, HUD, and controls (spec.md
/// roadmap Phase 2). Navigation to/from this screen via go_router and the
/// full Home/Settings/Statistics/About surroundings are Phase 4's scope;
/// for now this is reached from a temporary debug entry point.
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with SingleTickerProviderStateMixin {
  final GameTickerService _ticker = GameTickerService();

  @override
  void initState() {
    super.initState();
    // Starting a new game mutates gameControllerProvider's state, which
    // Riverpod forbids while the widget tree is still building; deferring
    // to the next microtask runs it right after this frame instead.
    Future.microtask(() => ref.read(gameControllerProvider.notifier).startNewGame());
    _ticker.start(this, (delta) {
      ref.read(gameControllerProvider.notifier).onTick(delta);
    });
  }

  @override
  void dispose() {
    _ticker.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameControllerProvider);
    final theme = Theme.of(context);

    if (gameState == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    final gridLineColor = theme.brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.06);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.spacingLg,
                vertical: AppDimens.spacingMd,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Nivel ${gameState.level}', style: theme.textTheme.titleMedium),
                  Text('${gameState.score}', style: theme.textTheme.titleMedium),
                ],
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppDimens.spacingMd),
                    child: HoldWidget(
                      holdPiece: gameState.holdPiece,
                      isUsed: gameState.holdUsed,
                    ),
                  ),
                  Expanded(
                    child: CustomPaint(
                      painter: BoardPainter(
                        gameState: gameState,
                        gridLineColor: gridLineColor,
                        emptyCellColor: theme.colorScheme.surface,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppDimens.spacingMd),
                    child: NextQueueWidget(upcoming: gameState.nextQueue),
                  ),
                ],
              ),
            ),
            if (gameState.status == GameStatus.gameOver)
              Padding(
                padding: const EdgeInsets.all(AppDimens.spacingLg),
                child: Text('GAME OVER', style: theme.textTheme.headlineMedium),
              ),
            const Padding(
              padding: EdgeInsets.all(AppDimens.spacingLg),
              child: TouchControls(),
            ),
          ],
        ),
      ),
    );
  }
}
