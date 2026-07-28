import 'package:hive/hive.dart';

/// The `settings_box` record — spec.md section 13. `hive_generator`'s
/// latest release only supports `source_gen ^1.0.0`, which conflicts with
/// `riverpod_generator`'s `source_gen ^2.0.0` (see AGENT.md) — this adapter
/// is hand-written in the exact shape `hive_generator` would otherwise
/// produce, so there's no codegen dependency for this model at all.
class SettingsModel {
  final bool soundEnabled;
  final double ambientVolume;
  final double sfxVolume;
  final bool hapticsEnabled;
  final bool ghostPieceEnabled;
  final bool focusModeDefault;
  final int themeModeIndex;
  final String? localeCode;

  const SettingsModel({
    required this.soundEnabled,
    required this.ambientVolume,
    required this.sfxVolume,
    required this.hapticsEnabled,
    required this.ghostPieceEnabled,
    required this.focusModeDefault,
    required this.themeModeIndex,
    required this.localeCode,
  });
}

class SettingsModelAdapter extends TypeAdapter<SettingsModel> {
  @override
  final int typeId = 0;

  @override
  SettingsModel read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numFields; i++) reader.readByte(): reader.read(),
    };
    return SettingsModel(
      soundEnabled: fields[0] as bool,
      ambientVolume: fields[1] as double,
      sfxVolume: fields[2] as double,
      hapticsEnabled: fields[3] as bool,
      ghostPieceEnabled: fields[4] as bool,
      focusModeDefault: fields[5] as bool,
      themeModeIndex: fields[6] as int,
      localeCode: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SettingsModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.soundEnabled)
      ..writeByte(1)
      ..write(obj.ambientVolume)
      ..writeByte(2)
      ..write(obj.sfxVolume)
      ..writeByte(3)
      ..write(obj.hapticsEnabled)
      ..writeByte(4)
      ..write(obj.ghostPieceEnabled)
      ..writeByte(5)
      ..write(obj.focusModeDefault)
      ..writeByte(6)
      ..write(obj.themeModeIndex)
      ..writeByte(7)
      ..write(obj.localeCode);
  }
}
