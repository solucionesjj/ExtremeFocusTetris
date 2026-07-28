import 'package:audioplayers/audioplayers.dart';

/// One-shot sound effects — spec.md section 6.3. The enum value maps 1:1 to
/// an asset under `assets/audio/sfx/`.
enum SfxEvent {
  move,
  rotate,
  softDrop,
  hardDrop,
  hold,
  lineClear1,
  lineClear2,
  lineClear3,
  lineClearTetris,
  tSpin,
  levelUp,
  gameOver,
  pause,
  buttonTap;

  String get _assetPath => switch (this) {
    SfxEvent.move => 'audio/sfx/move.ogg',
    SfxEvent.rotate => 'audio/sfx/rotate.ogg',
    SfxEvent.softDrop => 'audio/sfx/soft_drop.ogg',
    SfxEvent.hardDrop => 'audio/sfx/hard_drop.ogg',
    SfxEvent.hold => 'audio/sfx/hold.ogg',
    SfxEvent.lineClear1 => 'audio/sfx/line_clear_1.ogg',
    SfxEvent.lineClear2 => 'audio/sfx/line_clear_2.ogg',
    SfxEvent.lineClear3 => 'audio/sfx/line_clear_3.ogg',
    SfxEvent.lineClearTetris => 'audio/sfx/line_clear_tetris.ogg',
    SfxEvent.tSpin => 'audio/sfx/tspin.ogg',
    SfxEvent.levelUp => 'audio/sfx/level_up.ogg',
    SfxEvent.gameOver => 'audio/sfx/game_over.ogg',
    SfxEvent.pause => 'audio/sfx/pause.ogg',
    SfxEvent.buttonTap => 'audio/sfx/button_tap.ogg',
  };
}

/// Ambient "tic-toc" loop + SFX playback — spec.md section 6. One
/// [AudioPlayer] is dedicated to the ambient loop; a small round-robin pool
/// handles SFX so overlapping events (e.g. rotate immediately followed by a
/// lock) don't cut each other off — spec.md section 16.
///
/// NOTE: the bundled `.ogg` assets are functional placeholders (simple
/// synthesized tones), not final sound design — see AGENT.md.
class AudioService {
  static const _ambientAsset = 'audio/ambient/tic_toc_loop.ogg';
  static const _sfxPoolSize = 4;

  final AudioPlayer _ambientPlayer = AudioPlayer();
  final List<AudioPlayer> _sfxPool = List.generate(_sfxPoolSize, (_) => AudioPlayer());
  int _nextSfxSlot = 0;

  bool soundEnabled = true;
  double ambientVolume = 0.6;
  double sfxVolume = 0.8;

  bool _ambientReady = false;

  Future<void> _ensureAmbientReady() async {
    if (_ambientReady) return;
    await _ambientPlayer.setReleaseMode(ReleaseMode.loop);
    await _ambientPlayer.setVolume(ambientVolume);
    await _ambientPlayer.setSource(AssetSource(_ambientAsset));
    _ambientReady = true;
  }

  Future<void> startAmbient() async {
    await _ensureAmbientReady();
    if (!soundEnabled) return;
    await _ambientPlayer.resume();
  }

  Future<void> pauseAmbient() => _ambientPlayer.pause();

  Future<void> setAmbientVolume(double volume) async {
    ambientVolume = volume.clamp(0, 1);
    await _ambientPlayer.setVolume(ambientVolume);
  }

  void setSfxVolume(double volume) => sfxVolume = volume.clamp(0, 1);

  Future<void> setSoundEnabled(bool enabled) async {
    soundEnabled = enabled;
    if (enabled) {
      await startAmbient();
    } else {
      await pauseAmbient();
    }
  }

  Future<void> playSfx(SfxEvent event) async {
    if (!soundEnabled) return;
    final player = _sfxPool[_nextSfxSlot];
    _nextSfxSlot = (_nextSfxSlot + 1) % _sfxPool.length;
    await player.stop();
    await player.setVolume(sfxVolume);
    await player.play(AssetSource(event._assetPath));
  }

  Future<void> dispose() async {
    await _ambientPlayer.dispose();
    for (final player in _sfxPool) {
      await player.dispose();
    }
  }
}
