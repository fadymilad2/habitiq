// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitModelAdapter extends TypeAdapter<HabitModel> {
  @override
  final int typeId = 1;

  @override
  HabitModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HabitModel(
      id: fields[0] as String,
      title: fields[1] as String,
      icon: fields[2] as int,
      colorHex: fields[3] as String,
      isCompletedToday: fields[4] == null ? false : fields[4] as bool,
      completionDates: (fields[5] as List?)?.cast<DateTime>(),
      createdAt: fields[6] as DateTime,
      frequency: fields[7] == null ? 0 : fields[7] as int,
      targetDays: fields[8] == null ? 66 : fields[8] as int,
      hasReminder: fields[9] == null ? false : fields[9] as bool,
      reminderTime: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, HabitModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.icon)
      ..writeByte(3)
      ..write(obj.colorHex)
      ..writeByte(4)
      ..write(obj.isCompletedToday)
      ..writeByte(5)
      ..write(obj.completionDates)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.frequency)
      ..writeByte(8)
      ..write(obj.targetDays)
      ..writeByte(9)
      ..write(obj.hasReminder)
      ..writeByte(10)
      ..write(obj.reminderTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
