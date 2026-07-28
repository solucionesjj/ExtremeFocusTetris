import 'package:hive/hive.dart';

/// The `session_box` record — spec.md section 13. Snapshot of an
/// in-progress game, saved on pause / backgrounding, so it can be resumed.
/// Hand-written adapter for the same reason as `SettingsModel` — see that
/// file's doc comment.
class GameSessionModel {
  final List<int> boardCells;
  final int activePieceTypeIndex;
  final int activePieceRotationIndex;
  final int activePieceOriginRow;
  final int activePieceOriginCol;
  final List<int> nextQueueTypeIndices;
  final int? holdPieceTypeIndex;
  final bool holdUsed;
  final int score;
  final int level;
  final int totalLinesCleared;
  final int combo;
  final bool backToBack;
  final int elapsedSeconds;

  const GameSessionModel({
    required this.boardCells,
    required this.activePieceTypeIndex,
    required this.activePieceRotationIndex,
    required this.activePieceOriginRow,
    required this.activePieceOriginCol,
    required this.nextQueueTypeIndices,
    required this.holdPieceTypeIndex,
    required this.holdUsed,
    required this.score,
    required this.level,
    required this.totalLinesCleared,
    required this.combo,
    required this.backToBack,
    required this.elapsedSeconds,
  });
}

class GameSessionModelAdapter extends TypeAdapter<GameSessionModel> {
  @override
  final int typeId = 2;

  @override
  GameSessionModel read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numFields; i++) reader.readByte(): reader.read(),
    };
    return GameSessionModel(
      boardCells: (fields[0] as List).cast<int>(),
      activePieceTypeIndex: fields[1] as int,
      activePieceRotationIndex: fields[2] as int,
      activePieceOriginRow: fields[3] as int,
      activePieceOriginCol: fields[4] as int,
      nextQueueTypeIndices: (fields[5] as List).cast<int>(),
      holdPieceTypeIndex: fields[6] as int?,
      holdUsed: fields[7] as bool,
      score: fields[8] as int,
      level: fields[9] as int,
      totalLinesCleared: fields[10] as int,
      combo: fields[11] as int,
      backToBack: fields[12] as bool,
      elapsedSeconds: fields[13] as int,
    );
  }

  @override
  void write(BinaryWriter writer, GameSessionModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.boardCells)
      ..writeByte(1)
      ..write(obj.activePieceTypeIndex)
      ..writeByte(2)
      ..write(obj.activePieceRotationIndex)
      ..writeByte(3)
      ..write(obj.activePieceOriginRow)
      ..writeByte(4)
      ..write(obj.activePieceOriginCol)
      ..writeByte(5)
      ..write(obj.nextQueueTypeIndices)
      ..writeByte(6)
      ..write(obj.holdPieceTypeIndex)
      ..writeByte(7)
      ..write(obj.holdUsed)
      ..writeByte(8)
      ..write(obj.score)
      ..writeByte(9)
      ..write(obj.level)
      ..writeByte(10)
      ..write(obj.totalLinesCleared)
      ..writeByte(11)
      ..write(obj.combo)
      ..writeByte(12)
      ..write(obj.backToBack)
      ..writeByte(13)
      ..write(obj.elapsedSeconds);
  }
}
