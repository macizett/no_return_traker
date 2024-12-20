// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'NodesProgressModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProgressNodeAdapter extends TypeAdapter<UserProgressNode> {
  @override
  final int typeId = 3;

  @override
  UserProgressNode read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProgressNode(
      id: fields[0] as int,
      uniqueID: fields[1] as int,
      text: fields[2] as String,
      option: fields[3] as String,
      person: fields[4] as String,
      act: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, UserProgressNode obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.uniqueID)
      ..writeByte(2)
      ..write(obj.text)
      ..writeByte(3)
      ..write(obj.option)
      ..writeByte(4)
      ..write(obj.person)
      ..writeByte(5)
      ..write(obj.act);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProgressNodeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
