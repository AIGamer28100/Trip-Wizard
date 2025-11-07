import 'package:hive/hive.dart';
import '../models/itinerary_item.dart';

class ItineraryItemAdapter extends TypeAdapter<ItineraryItem> {
  @override
  final int typeId = 1;

  @override
  ItineraryItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return ItineraryItem(
      id: fields[0] as String,
      tripId: fields[1] as String,
      day: fields[2] as int,
      time: fields[3] as String,
      activity: fields[4] as String,
      description: fields[5] as String?,
      location: fields[6] as String?,
      cost: fields[7] as double?,
      aiSuggested: fields[8] as bool,
      createdAt: DateTime.parse(fields[9] as String),
      updatedAt: DateTime.parse(fields[10] as String),
    );
  }

  @override
  void write(BinaryWriter writer, ItineraryItem obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.tripId)
      ..writeByte(2)
      ..write(obj.day)
      ..writeByte(3)
      ..write(obj.time)
      ..writeByte(4)
      ..write(obj.activity)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.location)
      ..writeByte(7)
      ..write(obj.cost)
      ..writeByte(8)
      ..write(obj.aiSuggested)
      ..writeByte(9)
      ..write(obj.createdAt.toIso8601String())
      ..writeByte(10)
      ..write(obj.updatedAt.toIso8601String());
  }
}
