import 'dart:math';
import 'dart:ui';

import 'package:extreme_focus_tetris/features/game/domain/usecases/start_new_game.dart';
import 'package:extreme_focus_tetris/features/game/presentation/effects/particle.dart';
import 'package:extreme_focus_tetris/features/game/presentation/widgets/board_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('paints without throwing when flash rows and particles are active', () {
    final gameState = StartNewGame.call(Random(1));
    final particle = Particle()..spawn(x: 10, y: 10, velocityX: 5, velocityY: -5);
    final painter = BoardPainter(
      gameState: gameState,
      gridLineColor: Colors.black12,
      emptyCellColor: Colors.white,
      flashRows: const [0, 1],
      flashOpacity: 0.5,
      particles: [particle],
    );

    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);

    expect(() => painter.paint(canvas, const Size(300, 600)), returnsNormally);

    recorder.endRecording().dispose();
  });

  test('shouldRepaint is true while particles are alive or flash is changing', () {
    final gameState = StartNewGame.call(Random(1));
    final idle = BoardPainter(gameState: gameState, gridLineColor: Colors.black12, emptyCellColor: Colors.white);
    final withParticles = BoardPainter(
      gameState: gameState,
      gridLineColor: Colors.black12,
      emptyCellColor: Colors.white,
      particles: [Particle()..spawn(x: 0, y: 0, velocityX: 0, velocityY: 0)],
    );

    expect(withParticles.shouldRepaint(idle), isTrue);
    expect(idle.shouldRepaint(idle), isFalse);
  });
}
