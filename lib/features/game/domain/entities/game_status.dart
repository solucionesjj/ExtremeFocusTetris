/// High-level game lifecycle. The finer-grained animation states from
/// spec.md section 8.10 (Falling/Locking/Resolving/LineClear) are a
/// presentation-layer concern (roadmap Phase 2) built on top of the pure
/// operations exposed here — the domain only needs to know whether play
/// can continue.
enum GameStatus { playing, gameOver }
