import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_durations.dart';
import '../../../core/di/providers.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/routing/routes.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/game_ticker_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../settings/presentation/viewmodels/settings_controller.dart';
import '../domain/entities/board.dart';
import '../domain/entities/game_status.dart';
import 'effects/particle_pool.dart';
import 'viewmodels/game_controller.dart';
import 'viewmodels/line_clear_event.dart';
import 'viewmodels/line_clear_event_controller.dart';
import 'widgets/board_geometry.dart';
import 'widgets/board_painter.dart';
import 'widgets/hold_widget.dart';
import 'widgets/next_queue_widget.dart';
import 'widgets/touch_controls.dart';

/// The Game screen — board, HUD, controls, and the Pause/Game Over
/// overlays (spec.md section 10.2). Reached by pushing [Routes.game] with
/// a `({bool focusMode, bool resume})` record as `extra`. In Focus Mode
/// (spec.md section 9.2) the HUD shrinks to board + 1 next piece + a
/// discrete timer, the block palette desaturates, UI SFX are quieter, and
/// a level-up is a border tint instead of a banner.
class GameScreen extends ConsumerStatefulWidget {
  final bool focusMode;
  final bool resume;

  const GameScreen({super.key, this.focusMode = false, this.resume = false});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final GameTickerService _ticker = GameTickerService();
  final ParticlePool _particlePool = ParticlePool();
  bool _isPaused = false;
  bool _showLevelUpBanner = false;
  bool _showFocusLevelUpFlash = false;
  bool _showComboPopup = false;
  bool _showFocusComboGlow = false;
  bool _scorePulse = false;
  bool _comboPulse = false;
  int _comboPopupValue = 0;
  List<int> _flashRows = const [];

  // Captured from the board's LayoutBuilder each frame — used to translate
  // cleared row indices into pixel positions for particle emission, since
  // that math otherwise only exists inside BoardPainter's paint().
  Size? _boardSize;

  // Drives both the line-clear flash fade (spec.md 18: color flash fading
  // over the same 120ms window) and the ±3px/2-cycle shake — starts at 1
  // so the idle flashOpacity (`1 - value`) is 0 before any clear ever fires.
  late final AnimationController _lineClearEffectController = AnimationController(
    vsync: this,
    duration: AppDurations.lineClearFlash,
    value: 1,
  );

  // A separate, longer shake for Game Over (spec.md 7: "300 ms shake sutil
  // del tablero"), reusing the same shake tween shape.
  late final AnimationController _gameOverShakeController = AnimationController(
    vsync: this,
    duration: AppDurations.gameOverShake,
  );

  static final TweenSequence<double> _shakeTween = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0.0, end: 3.0), weight: 1),
    TweenSequenceItem(tween: Tween(begin: 3.0, end: -3.0), weight: 2),
    TweenSequenceItem(tween: Tween(begin: -3.0, end: 3.0), weight: 2),
    TweenSequenceItem(tween: Tween(begin: 3.0, end: 0.0), weight: 1),
  ]);

  // The HUD's own live display, separate from GameController's internal
  // play-time accumulator (which persists correctly across resume for
  // stats purposes) — this one simply restarts at 0:00 each time the
  // screen mounts, whether that's a new game or a resumed one. Spec.md
  // marks the Focus Mode timer itself as optional, so this simplification
  // is intentional rather than an oversight — see AGENT.md.
  Duration _displayedElapsed = Duration.zero;

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
      final next = _displayedElapsed + delta;
      if (next.inSeconds != _displayedElapsed.inSeconds) {
        setState(() => _displayedElapsed = next);
      } else {
        _displayedElapsed = next;
      }
      if (_particlePool.hasActiveParticles) {
        _particlePool.update(delta.inMicroseconds / 1e6);
        setState(() {});
      }
    });
  }

  /// Reduced motion (spec.md section 14) dampens "non-essential" animation
  /// — spec.md names particles and shake specifically — while leaving the
  /// color flash (a state cue, not decorative movement) untouched. Respects
  /// both the in-app Settings toggle and the OS-level `disableAnimations`.
  bool get _reduceMotion =>
      ref.read(settingsControllerProvider).reduceMotion ||
      (MediaQuery.maybeOf(context)?.disableAnimations ?? false);

  void _onLineClear(LineClearEvent event) {
    final boardSize = _boardSize;
    final visibleRows = event.clearedRowIndices
        .map((row) => row - Board.hiddenRows)
        .where((row) => row >= 0 && row < Board.visibleRows)
        .toList();
    if (boardSize != null && visibleRows.isNotEmpty && !_reduceMotion) {
      final geometry = BoardGeometry.of(boardSize);
      _particlePool.emitForLineClear(
        cellCentersX: List.generate(Board.columns, geometry.columnCenterX),
        rowCentersY: visibleRows.map(geometry.rowCenterY).toList(),
        linesCleared: event.linesCleared,
      );
    }
    setState(() => _flashRows = visibleRows);
    _lineClearEffectController.forward(from: 0);
  }

  void _pulseScore() {
    setState(() => _scorePulse = true);
    Future.delayed(AppDurations.scalePulseUp, () {
      if (mounted) setState(() => _scorePulse = false);
    });
  }

  void _onComboIncrease(int combo) {
    if (widget.focusMode) {
      setState(() => _showFocusComboGlow = true);
      Future.delayed(AppDurations.focusLevelUpBorderFade, () {
        if (mounted) setState(() => _showFocusComboGlow = false);
      });
      return;
    }
    setState(() {
      _comboPopupValue = combo;
      _showComboPopup = true;
      _comboPulse = true;
    });
    Future.delayed(AppDurations.scalePulseUp, () {
      if (mounted) setState(() => _comboPulse = false);
    });
    Future.delayed(
      AppDurations.levelUpEnter + AppDurations.levelUpHold + AppDurations.levelUpExit,
      () {
        if (mounted) setState(() => _showComboPopup = false);
      },
    );
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
    setState(() {
      _isPaused = false;
      _displayedElapsed = Duration.zero;
    });
    ref.read(gameControllerProvider.notifier).startNewGame(focusMode: widget.focusMode);
    if (!_ticker.isRunning) _startTicker();
  }

  void _onLevelUp() {
    if (widget.focusMode) {
      setState(() => _showFocusLevelUpFlash = true);
      Future.delayed(AppDurations.focusLevelUpBorderFade, () {
        if (mounted) setState(() => _showFocusLevelUpFlash = false);
      });
    } else {
      setState(() => _showLevelUpBanner = true);
      Future.delayed(
        AppDurations.levelUpEnter + AppDurations.levelUpHold + AppDurations.levelUpExit,
        () {
          if (mounted) setState(() => _showLevelUpBanner = false);
        },
      );
    }
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
    _lineClearEffectController.dispose();
    _gameOverShakeController.dispose();
    _audioService.pauseAmbient();
    super.dispose();
  }

  String _formatElapsed(Duration d) {
    final minutes = d.inMinutes.remainder(100).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(gameControllerProvider, (previous, next) {
      if (previous == null || next == null) return;
      if (next.level > previous.level) _onLevelUp();
      if (next.score > previous.score) _pulseScore();
      if (next.combo > previous.combo && next.combo >= 1) _onComboIncrease(next.combo);
      if (next.status == GameStatus.gameOver && previous.status != GameStatus.gameOver) {
        _gameOverShakeController.forward(from: 0);
      }
    });
    ref.listen(lineClearEventControllerProvider, (previous, next) {
      if (next != null && next.sequence != previous?.sequence) {
        _onLineClear(next);
      }
    });

    final gameState = ref.watch(gameControllerProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsControllerProvider);
    final focusMode = widget.focusMode;

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
                      if (!focusMode) Text('Nivel ${gameState.level}', style: theme.textTheme.titleMedium),
                      AnimatedScale(
                        scale: _scorePulse ? 1.15 : 1.0,
                        duration: AppDurations.scalePulseUp,
                        curve: Curves.easeOut,
                        child: Text(
                          '${gameState.score}',
                          style: focusMode ? theme.textTheme.labelSmall : theme.textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!focusMode)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimens.spacingLg),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Líneas: ${gameState.totalLinesCleared}', style: theme.textTheme.bodyMedium),
                        if (gameState.combo >= 1)
                          AnimatedScale(
                            scale: _comboPulse ? 1.15 : 1.0,
                            duration: AppDurations.scalePulseUp,
                            curve: Curves.easeOut,
                            child: Text('Combo x${gameState.combo}', style: theme.textTheme.bodyMedium),
                          ),
                        Text(_formatElapsed(_displayedElapsed), style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimens.spacingLg),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(_formatElapsed(_displayedElapsed), style: theme.textTheme.labelSmall),
                    ),
                  ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (!focusMode)
                        Padding(
                          padding: const EdgeInsets.all(AppDimens.spacingMd),
                          child: HoldWidget(
                            holdPiece: gameState.holdPiece,
                            isUsed: gameState.holdUsed,
                            colorblindMode: settings.colorblindModeEnabled,
                          ),
                        ),
                      Expanded(
                        child: AnimatedContainer(
                          duration: AppDurations.focusLevelUpBorderFade,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _showFocusLevelUpFlash
                                  ? AppColors.secondary
                                  : _showFocusComboGlow
                                      ? AppColors.primary
                                      : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              _boardSize = constraints.biggest;
                              return AnimatedBuilder(
                                animation: Listenable.merge([
                                  _lineClearEffectController,
                                  _gameOverShakeController,
                                ]),
                                builder: (context, child) {
                                  final shakeDx = _reduceMotion
                                      ? 0.0
                                      : _shakeTween.evaluate(_lineClearEffectController) +
                                            _shakeTween.evaluate(_gameOverShakeController);
                                  return Transform.translate(
                                    offset: Offset(shakeDx, 0),
                                    child: CustomPaint(
                                      painter: BoardPainter(
                                        gameState: gameState,
                                        gridLineColor: gridLineColor,
                                        emptyCellColor: theme.colorScheme.surface,
                                        showGhost: settings.ghostPieceEnabled,
                                        focusMode: focusMode,
                                        colorblindMode: settings.colorblindModeEnabled,
                                        highContrast: settings.highContrast,
                                        flashRows: _flashRows,
                                        flashOpacity: 1 - _lineClearEffectController.value,
                                        particles: _particlePool.activeParticles,
                                      ),
                                      child: const SizedBox.expand(),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(AppDimens.spacingMd),
                        child: NextQueueWidget(
                          upcoming: gameState.nextQueue,
                          visibleCount: focusMode ? 1 : 3,
                          focusMode: focusMode,
                          colorblindMode: settings.colorblindModeEnabled,
                        ),
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
            if (!focusMode && _showLevelUpBanner)
              Positioned(
                top: AppDimens.spacingXxxl,
                left: 0,
                right: 0,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _showLevelUpBanner ? 1 : 0,
                    duration: AppDurations.levelUpEnter,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.spacingXl,
                        vertical: AppDimens.spacingMd,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
                      ),
                      child: Text(
                        'Nivel ${gameState.level}',
                        style: theme.textTheme.titleMedium?.copyWith(color: AppColors.textOnLight),
                      ),
                    ),
                  ),
                ),
              ),
            if (!focusMode && _showComboPopup)
              Positioned(
                top: AppDimens.spacingXxxl + AppDimens.spacingXxxl,
                left: 0,
                right: 0,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _showComboPopup ? 1 : 0,
                    duration: AppDurations.levelUpEnter,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.spacingLg,
                        vertical: AppDimens.spacingSm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
                      ),
                      child: Text(
                        'Combo x$_comboPopupValue',
                        style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.textOnLight),
                      ),
                    ),
                  ),
                ),
              ),
            if (_isPaused)
              _OverlayScrim(
                title: l10n.gamePauseTitle,
                theme: theme,
                highContrast: settings.highContrast,
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
                highContrast: settings.highContrast,
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
  final bool highContrast;

  const _OverlayScrim({
    required this.title,
    this.subtitle,
    required this.theme,
    required this.buttons,
    this.highContrast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedOpacity(
        opacity: 1,
        duration: const Duration(milliseconds: 300),
        child: Container(
          // High contrast (spec.md 14) drops the HUD transparency entirely.
          color: theme.colorScheme.surface.withValues(alpha: highContrast ? 1 : 0.92),
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
