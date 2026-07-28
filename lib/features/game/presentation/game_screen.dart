import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/di/providers.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/routing/routes.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/game_ticker_service.dart';
import '../../settings/presentation/viewmodels/settings_controller.dart';
import '../domain/entities/game_status.dart';
import 'viewmodels/game_controller.dart';
import 'widgets/board_painter.dart';
import 'widgets/hold_widget.dart';
import 'widgets/next_queue_widget.dart';
import 'widgets/touch_controls.dart';

/// The Game screen — board, HUD, controls, and the Pause/Game Over
/// overlays (spec.md section 10.2). Reached by pushing [Routes.game] with
/// a `({bool focusMode, bool resume})` record as `extra`.
class GameScreen extends ConsumerStatefulWidget {
  final bool focusMode;
  final bool resume;

  const GameScreen({super.key, this.focusMode = false, this.resume = false});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final GameTickerService _ticker = GameTickerService();
  bool _isPaused = false;
  // Captured once so dispose() never touches `ref` — Riverpod forbids
  // reading providers after the element is disposed, and during a full
  // widget-tree teardown dispose() can run after that point.
  late final AudioService _audioService;

  @override
  void initState() {
    super.initState();
    _audioService = ref.read(audioServiceProvider);
    WidgetsBinding.instance.addObserver(this);
    // Starting/resuming a game mutates gameControllerProvider's state,
    // which Riverpod forbids while the widget tree is still building;
    // deferring to the next microtask runs it right after this frame
    // instead.
    Future.microtask(() {
      final controller = ref.read(gameControllerProvider.notifier);
      if (widget.resume) {
        controller.resumeSession();
      } else {
        controller.startNewGame(focusMode: widget.focusMode);
      }
    });
    _startTicker();
  }

  void _startTicker() {
    _ticker.start(this, (delta) {
      ref.read(gameControllerProvider.notifier).onTick(delta);
    });
  }

  void _togglePause() {
    setState(() => _isPaused = !_isPaused);
    if (_isPaused) {
      _ticker.stop();
      // Save on pause — spec.md section 13.
      ref.read(gameControllerProvider.notifier).saveSessionNow();
    } else {
      _startTicker();
    }
  }

  void _restart() {
    setState(() => _isPaused = false);
    ref.read(gameControllerProvider.notifier).startNewGame(focusMode: widget.focusMode);
    if (!_ticker.isRunning) _startTicker();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The ambient loop pauses/resumes with the app itself — spec.md 6.2.
    if (state == AppLifecycleState.resumed) {
      _audioService.startAmbient();
    } else {
      _audioService.pauseAmbient();
      // Save on backgrounding (AppLifecycleState.paused) — spec.md 13.
      ref.read(gameControllerProvider.notifier).saveSessionNow();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.stop();
    _audioService.pauseAmbient();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameControllerProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final showGhost = ref.watch(settingsControllerProvider).ghostPieceEnabled;

    if (gameState == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    final gridLineColor = theme.brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.06);
    final isGameOver = gameState.status == GameStatus.gameOver;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.spacingLg,
                    vertical: AppDimens.spacingMd,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.pause),
                        onPressed: isGameOver ? null : _togglePause,
                      ),
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
                            showGhost: showGhost,
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
                const Padding(
                  padding: EdgeInsets.all(AppDimens.spacingLg),
                  child: TouchControls(),
                ),
              ],
            ),
            if (_isPaused)
              _OverlayScrim(
                title: l10n.gamePauseTitle,
                theme: theme,
                buttons: [
                  _OverlayButton(label: l10n.gameResume, onPressed: _togglePause),
                  _OverlayButton(label: l10n.gameRestart, onPressed: _restart),
                  _OverlayButton(
                    label: l10n.gameExitToMenu,
                    onPressed: () => context.go(Routes.home),
                  ),
                ],
              ),
            if (isGameOver)
              _OverlayScrim(
                title: l10n.gameOverTitle,
                subtitle: l10n.gameScoreLabel(gameState.score),
                theme: theme,
                buttons: [
                  _OverlayButton(label: l10n.gamePlayAgain, onPressed: _restart),
                  _OverlayButton(
                    label: l10n.gameMainMenu,
                    onPressed: () => context.go(Routes.home),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _OverlayScrim extends StatelessWidget {
  final String title;
  final String? subtitle;
  final ThemeData theme;
  final List<Widget> buttons;

  const _OverlayScrim({
    required this.title,
    this.subtitle,
    required this.theme,
    required this.buttons,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedOpacity(
        opacity: 1,
        duration: const Duration(milliseconds: 300),
        child: Container(
          color: theme.colorScheme.surface.withValues(alpha: 0.92),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: theme.textTheme.headlineMedium),
                if (subtitle != null) ...[
                  const SizedBox(height: AppDimens.spacingSm),
                  Text(subtitle!, style: theme.textTheme.bodyLarge),
                ],
                const SizedBox(height: AppDimens.spacingXl),
                ...buttons,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OverlayButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _OverlayButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.spacingSm),
      child: SizedBox(
        width: 220,
        child: ElevatedButton(onPressed: onPressed, child: Text(label)),
      ),
    );
  }
}
