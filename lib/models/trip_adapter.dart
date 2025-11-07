import 'package:hive/hive.dart';
import '../models/trip.dart';

class TripAdapter extends TypeAdapter<Trip> {
  @override
  final int typeId = 0;

  @override
  Trip read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return Trip(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      creatorId: fields[3] as String,
      memberIds: (fields[4] as List).cast<String>(),
      startDate: DateTime.parse(fields[5] as String),
      endDate: DateTime.parse(fields[6] as String),
      destination: fields[7] as String?,
      createdAt: DateTime.parse(fields[8] as String),
      updatedAt: DateTime.parse(fields[9] as String),
    );
  }

  @override
  void write(BinaryWriter writer, Trip obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.creatorId)
      ..writeByte(4)
      ..write(obj.memberIds)
      ..writeByte(5)
      ..write(obj.startDate.toIso8601String())
      ..writeByte(6)
      ..write(obj.endDate.toIso8601String())
      ..writeByte(7)
      ..write(obj.destination)
      ..writeByte(8)
      ..write(obj.createdAt.toIso8601String())
      ..writeByte(9)
      ..write(obj.updatedAt.toIso8601String());
  }
}
