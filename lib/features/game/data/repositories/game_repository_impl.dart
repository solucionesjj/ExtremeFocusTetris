import 'package:hive/hive.dart';

import '../../../../core/constants/hive_box_names.dart';
import '../../domain/entities/board.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/game_status.dart';
import '../../domain/entities/grid_position.dart';
import '../../domain/entities/rotation_state.dart';
import '../../domain/entities/tetromino.dart';
import '../../domain/entities/tetromino_type.dart';
import '../../domain/repositories/game_repository.dart';
import '../models/game_session_model.dart';

/// Hive-backed [GameRepository] — spec.md section 13 (`session_box`).
class GameRepositoryImpl implements GameRepository {
  static const _key = 'current';

  Box<GameSessionModel> get _box => Hive.box<GameSessionModel>(HiveBoxNames.session);

  @override
  bool hasSavedSession() {
    try {
      return _box.get(_key) != null;
    } catch (_) {
      return false;
    }
  }

  @override
  SavedSession? loadSession() {
    try {
      final model = _box.get(_key);
      if (model == null) return null;

      final activePiece = Tetromino(
        type: TetrominoType.values[model.activePieceTypeIndex],
        rotation: RotationState.values[model.activePieceRotationIndex],
        origin: GridPosition(model.activePieceOriginRow, model.activePieceOriginCol),
      );
      final state = GameState(
        board: Board.fromCellList(model.boardCells),
        activePiece: activePiece,
        nextQueue: model.nextQueueTypeIndices.map((i) => TetrominoType.values[i]).toList(),
        holdPiece: model.holdPieceTypeIndex == null
            ? null
            : TetrominoType.values[model.holdPieceTypeIndex!],
        holdUsed: model.holdUsed,
        score: model.score,
        level: model.level,
        totalLinesCleared: model.totalLinesCleared,
        combo: model.combo,
        backToBack: model.backToBack,
        status: GameStatus.playing,
        lastActionWasRotation: false,
        lockResetCount: 0,
      );
      return (state: state, elapsed: Duration(seconds: model.elapsedSeconds));
    } catch (_) {
      // Corrupt or unreadable session — treat as if there were none rather
      // than crashing Home/Game startup (spec.md section 22).
      return null;
    }
  }

  @override
  Future<void> saveSession(GameState state, {required Duration elapsed}) => _box.put(
    _key,
    GameSessionModel(
      boardCells: state.board.toCellList(),
      activePieceTypeIndex: state.activePiece.type.index,
      activePieceRotationIndex: state.activePiece.rotation.index,
      activePieceOriginRow: state.activePiece.origin.row,
      activePieceOriginCol: state.activePiece.origin.col,
      nextQueueTypeIndices: state.nextQueue.map((type) => type.index).toList(),
      holdPieceTypeIndex: state.holdPiece?.index,
      holdUsed: state.holdUsed,
      score: state.score,
      level: state.level,
      totalLinesCleared: state.totalLinesCleared,
      combo: state.combo,
      backToBack: state.backToBack,
      elapsedSeconds: elapsed.inSeconds,
    ),
  );

  @override
  Future<void> clearSession() => _box.delete(_key);
}
