import 'dart:math';

import 'particle.dart';

/// Particles per cleared cell, scaled by how many lines cleared at once —
/// spec.md section 18 ("8 por celda en Single, hasta 16 por celda en
/// Tetris"). Values between the two given endpoints are a reasonable
/// linear interpolation; spec.md only pins down 1 and 4 lines.
abstract final class ParticleCounts {
  static int perCellFor(int linesCleared) => switch (linesCleared) {
    1 => 8,
    2 => 11,
    3 => 13,
    _ => 16,
  };
}

/// A fixed-size, circularly-reused particle pool — spec.md sections 16/18.
/// `emit*` never allocates a new [Particle]; it just overwrites whichever
/// pool slot is next in line, alive or not, which is the explicit
/// trade-off spec.md accepts in exchange for a bounded memory footprint
/// even under back-to-back Tetrises.
class ParticlePool {
  static const int poolSize = 300;
  static const double _gravity = 480; // px/s^2
  static const double _friction = 0.96; // per step, see step()
  static const double _lifeDecayPerSecond = 1.4; // ~700ms lifespan

  final List<Particle> _particles = List.generate(poolSize, (_) => Particle());
  final Random _random;
  int _nextIndex = 0;

  ParticlePool({Random? random}) : _random = random ?? Random();

  /// Read-only snapshot for rendering; cheap, but still an allocation, so
  /// callers should only take it once per frame (see `BoardPainter`).
  List<Particle> get activeParticles =>
      _particles.where((p) => p.isAlive).toList(growable: false);

  bool get hasActiveParticles => _particles.any((p) => p.isAlive);

  void emitAt(double x, double y) {
    final particle = _particles[_nextIndex];
    _nextIndex = (_nextIndex + 1) % _particles.length;

    // Mostly-upward burst (±45° around straight up) with a bit of speed
    // variety, matching "gravedad leve y fricción" from spec.md 18.
    final angle = -pi / 2 + (_random.nextDouble() - 0.5) * (pi / 2);
    final speed = 80 + _random.nextDouble() * 160;
    particle.spawn(
      x: x,
      y: y,
      velocityX: cos(angle) * speed,
      velocityY: sin(angle) * speed,
    );
  }

  /// Emits particles across every (row, column) center for a line clear —
  /// count per cell follows [ParticleCounts.perCellFor].
  void emitForLineClear({
    required List<double> cellCentersX,
    required List<double> rowCentersY,
    required int linesCleared,
  }) {
    final perCell = ParticleCounts.perCellFor(linesCleared);
    for (final y in rowCentersY) {
      for (final x in cellCentersX) {
        for (var i = 0; i < perCell; i++) {
          emitAt(x, y);
        }
      }
    }
  }

  void update(double dtSeconds) {
    for (final particle in _particles) {
      particle.step(
        dtSeconds,
        gravity: _gravity,
        friction: _friction,
        lifeDecayPerSecond: _lifeDecayPerSecond,
      );
    }
  }
}
