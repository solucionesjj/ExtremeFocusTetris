/// A single decorative particle — spec.md sections 16/18. Plain, mutable,
/// and reused in place by [ParticlePool] rather than recreated, so the
/// game loop never pressures the GC with ephemeral objects.
class Particle {
  double x = 0;
  double y = 0;
  double velocityX = 0;
  double velocityY = 0;

  /// Counts down from 1 (just emitted) to 0 (dead); also doubles as the
  /// render opacity, since these particles simply fade out.
  double life = 0;

  bool get isAlive => life > 0;

  void spawn({
    required double x,
    required double y,
    required double velocityX,
    required double velocityY,
  }) {
    this.x = x;
    this.y = y;
    this.velocityX = velocityX;
    this.velocityY = velocityY;
    life = 1;
  }

  /// Simple manual simulation (spec.md section 18): gravity + friction,
  /// no physics engine — see spec.md section 19 for why.
  void step(
    double dtSeconds, {
    required double gravity,
    required double friction,
    required double lifeDecayPerSecond,
  }) {
    if (!isAlive) return;
    velocityY += gravity * dtSeconds;
    velocityX *= friction;
    velocityY *= friction;
    x += velocityX * dtSeconds;
    y += velocityY * dtSeconds;
    life -= lifeDecayPerSecond * dtSeconds;
    if (life < 0) life = 0;
  }
}
