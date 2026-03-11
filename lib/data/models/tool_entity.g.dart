// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tool_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ToolEntityAdapter extends TypeAdapter<ToolEntity> {
  @override
  final int typeId = 0;

  @override
  ToolEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ToolEntity(
      name: fields[0] as String,
      description: fields[1] as String,
      price: fields[2] as double,
      imageBytes: fields[3] as Uint8List?,
      barcode: fields[4] as String?,
      quantity: fields[5] == null ? 0 : fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ToolEntity obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.price)
      ..writeByte(3)
      ..write(obj.imageBytes)
      ..writeByte(4)
      ..write(obj.barcode)
      ..writeByte(5)
      ..write(obj.quantity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
