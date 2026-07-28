import 'package:hive/hive.dart';

/// The `stats_box` record — spec.md section 13. Hand-written adapter for
/// the same reason as `SettingsModel` — see that file's doc comment.
class StatisticsModel {
  final int highScore;
  final int gamesPlayed;
  final int totalLinesCleared;
  final int tetrises;
  final int tSpins;
  final int perfectClears;
  final int timePlayedSeconds;

  const StatisticsModel({
    required this.highScore,
    required this.gamesPlayed,
    required this.totalLinesCleared,
    required this.tetrises,
    required this.tSpins,
    required this.perfectClears,
    required this.timePlayedSeconds,
  });
}

class StatisticsModelAdapter extends TypeAdapter<StatisticsModel> {
  @override
  final int typeId = 1;

  @override
  StatisticsModel read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numFields; i++) reader.readByte(): reader.read(),
    };
    return StatisticsModel(
      highScore: fields[0] as int,
      gamesPlayed: fields[1] as int,
      totalLinesCleared: fields[2] as int,
      tetrises: fields[3] as int,
      tSpins: fields[4] as int,
      perfectClears: fields[5] as int,
      timePlayedSeconds: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, StatisticsModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.highScore)
      ..writeByte(1)
      ..write(obj.gamesPlayed)
      ..writeByte(2)
      ..write(obj.totalLinesCleared)
      ..writeByte(3)
      ..write(obj.tetrises)
      ..writeByte(4)
      ..write(obj.tSpins)
      ..writeByte(5)
      ..write(obj.perfectClears)
      ..writeByte(6)
      ..write(obj.timePlayedSeconds);
  }
}
