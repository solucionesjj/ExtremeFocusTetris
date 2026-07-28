import 'dart:math';

import 'package:extreme_focus_tetris/features/game/presentation/effects/particle.dart';
import 'package:extreme_focus_tetris/features/game/presentation/effects/particle_pool.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Particle', () {
    test('is dead until spawned', () {
      final particle = Particle();
      expect(particle.isAlive, isFalse);
    });

    test('spawn() sets position/velocity and brings it to life', () {
      final particle = Particle()..spawn(x: 10, y: 20, velocityX: 1, velocityY: -2);
      expect(particle.isAlive, isTrue);
      expect(particle.x, 10);
      expect(particle.y, 20);
      expect(particle.life, 1);
    });

    test('step() moves the particle and decays its life', () {
      final particle = Particle()..spawn(x: 0, y: 0, velocityX: 100, velocityY: 0);
      particle.step(0.1, gravity: 0, friction: 1, lifeDecayPerSecond: 1);
      expect(particle.x, closeTo(10, 0.001));
      expect(particle.life, closeTo(0.9, 0.001));
    });

    test('step() eventually kills the particle once life hits zero', () {
      final particle = Particle()..spawn(x: 0, y: 0, velocityX: 0, velocityY: 0);
      particle.step(2, gravity: 0, friction: 1, lifeDecayPerSecond: 1);
      expect(particle.life, 0);
      expect(particle.isAlive, isFalse);
    });

    test('step() on a dead particle is a no-op', () {
      final particle = Particle();
      particle.step(1, gravity: 100, friction: 0.5, lifeDecayPerSecond: 1);
      expect(particle.x, 0);
      expect(particle.y, 0);
      expect(particle.isAlive, isFalse);
    });

    test('gravity pulls the particle downward over time', () {
      final particle = Particle()..spawn(x: 0, y: 0, velocityX: 0, velocityY: 0);
      particle.step(0.5, gravity: 100, friction: 1, lifeDecayPerSecond: 0);
      expect(particle.velocityY, greaterThan(0));
      expect(particle.y, greaterThan(0));
    });
  });

  group('ParticleCounts', () {
    test('matches the spec.md 18 endpoints (Single=8/cell, Tetris=16/cell)', () {
      expect(ParticleCounts.perCellFor(1), 8);
      expect(ParticleCounts.perCellFor(4), 16);
    });

    test('scales monotonically between Single and Tetris', () {
      final counts = [1, 2, 3, 4].map(ParticleCounts.perCellFor).toList();
      for (var i = 1; i < counts.length; i++) {
        expect(counts[i], greaterThanOrEqualTo(counts[i - 1]));
      }
    });
  });

  group('ParticlePool', () {
    test('starts with no active particles', () {
      final pool = ParticlePool(random: Random(1));
      expect(pool.hasActiveParticles, isFalse);
      expect(pool.activeParticles, isEmpty);
    });

    test('emitAt activates exactly one particle', () {
      final pool = ParticlePool(random: Random(1));
      pool.emitAt(5, 5);
      expect(pool.activeParticles.length, 1);
    });

    test('never holds more active particles than the pool size, even when over-emitted', () {
      final pool = ParticlePool(random: Random(1));
      for (var i = 0; i < ParticlePool.poolSize + 50; i++) {
        pool.emitAt(0, 0);
      }
      expect(pool.activeParticles.length, lessThanOrEqualTo(ParticlePool.poolSize));
    });

    test('emitForLineClear emits perCellFor(linesCleared) particles per cell', () {
      final pool = ParticlePool(random: Random(1));
      pool.emitForLineClear(
        cellCentersX: [10, 20, 30],
        rowCentersY: [100],
        linesCleared: 1,
      );
      expect(pool.activeParticles.length, 3 * ParticleCounts.perCellFor(1));
    });

    test('update() advances every active particle and eventually clears them all', () {
      final pool = ParticlePool(random: Random(1));
      pool.emitAt(0, 0);
      pool.emitAt(0, 0);

      for (var i = 0; i < 200; i++) {
        pool.update(0.05); // 10 seconds total — comfortably past any lifespan
      }

      expect(pool.hasActiveParticles, isFalse);
    });
  });
}
