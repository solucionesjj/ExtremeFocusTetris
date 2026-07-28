import 'package:flutter/scheduler.dart';

/// A thin, reusable wrapper around a raw [Ticker] that delivers per-frame
/// deltas to a callback — decouples the game loop's timing primitive from
/// any specific widget. The `vsync` (a [TickerProvider]) must still come
/// from whichever widget owns this service's lifecycle, since only a widget
/// can be tied into Flutter's frame scheduling.
class GameTickerService {
  Ticker? _ticker;
  Duration _previousElapsed = Duration.zero;

  bool get isRunning => _ticker?.isActive ?? false;

  void start(TickerProvider vsync, void Function(Duration delta) onTick) {
    stop();
    _previousElapsed = Duration.zero;
    _ticker = vsync.createTicker((elapsed) {
      final delta = elapsed - _previousElapsed;
      _previousElapsed = elapsed;
      onTick(delta);
    })..start();
  }

  void stop() {
    _ticker?.stop();
    _ticker?.dispose();
    _ticker = null;
  }
}
