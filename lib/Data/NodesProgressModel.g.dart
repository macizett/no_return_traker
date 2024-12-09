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
      text: fields[1] as String,
      option: fields[2] as String,
      person: fields[3] as String,
      act: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, UserProgressNode obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.option)
      ..writeByte(3)
      ..write(obj.person)
      ..writeByte(4)
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
