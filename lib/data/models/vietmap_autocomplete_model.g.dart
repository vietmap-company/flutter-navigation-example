// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vietmap_autocomplete_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VietmapAutocompleteModelAdapter
    extends TypeAdapter<VietmapAutocompleteModel> {
  @override
  final int typeId = 0;

  @override
  VietmapAutocompleteModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VietmapAutocompleteModel(
      refId: fields[0] as String?,
      address: fields[3] as String?,
      name: fields[4] as String?,
      display: fields[5] as String?,
    )
      ..lat = fields[1] as double?
      ..lng = fields[2] as double?;
  }

  @override
  void write(BinaryWriter writer, VietmapAutocompleteModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.refId)
      ..writeByte(1)
      ..write(obj.lat)
      ..writeByte(2)
      ..write(obj.lng)
      ..writeByte(3)
      ..write(obj.address)
      ..writeByte(4)
      ..write(obj.name)
      ..writeByte(5)
      ..write(obj.display);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VietmapAutocompleteModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
