import 'package:hive/hive.dart';
import '../models/trip.dart';
import '../models/itinerary_item.dart';

class CacheService {
  static const String tripsBox = 'trips';
  static const String itineraryBox = 'itinerary_items';
  static const String chatBox = 'chat_messages';
  static const String syncMetadataBox = 'sync_metadata';

  Future<void> init() async {
    await Hive.openBox<Trip>(tripsBox);
    await Hive.openBox<ItineraryItem>(itineraryBox);
    await Hive.openBox<Map>(chatBox);
    await Hive.openBox<Map>(syncMetadataBox);
  }

  // Trip caching
  Future<void> cacheTrip(Trip trip) async {
    final box = Hive.box<Trip>(tripsBox);
    await box.put(trip.id, trip);
  }

  Future<Trip?> getCachedTrip(String tripId) async {
    final box = Hive.box<Trip>(tripsBox);
    return box.get(tripId);
  }

  Future<List<Trip>> getAllCachedTrips() async {
    final box = Hive.box<Trip>(tripsBox);
    return box.values.toList();
  }

  Future<void> removeCachedTrip(String tripId) async {
    final box = Hive.box<Trip>(tripsBox);
    await box.delete(tripId);
  }

  // Itinerary item caching
  Future<void> cacheItineraryItem(ItineraryItem item) async {
    final box = Hive.box<ItineraryItem>(itineraryBox);
    await box.put(item.id, item);
  }

  Future<List<ItineraryItem>> getCachedItineraryItems(String tripId) async {
    final box = Hive.box<ItineraryItem>(itineraryBox);
    return box.values.where((item) => item.tripId == tripId).toList();
  }

  Future<void> removeCachedItineraryItem(String itemId) async {
    final box = Hive.box<ItineraryItem>(itineraryBox);
    await box.delete(itemId);
  }

  // Chat message caching
  Future<void> cacheChatMessage(
    String tripId,
    Map<String, dynamic> message,
  ) async {
    final box = Hive.box<Map>(chatBox);
    final key = '${tripId}_${message['timestamp']}_${message['sender']}';
    await box.put(key, message);
  }

  Future<List<Map<String, dynamic>>> getCachedChatMessages(
    String tripId,
  ) async {
    final box = Hive.box<Map>(chatBox);
    final messages =
        box.keys
            .where((key) => key.toString().startsWith('${tripId}_'))
            .map((key) => box.get(key)!)
            .toList()
          ..sort((a, b) => a['timestamp'].compareTo(b['timestamp']));

    return messages.map((msg) => Map<String, dynamic>.from(msg)).toList();
  }

  // Sync metadata
  Future<void> updateLastSyncTime(String collection, DateTime timestamp) async {
    final box = Hive.box<Map>(syncMetadataBox);
    await box.put('last_sync_$collection', {
      'timestamp': timestamp.toIso8601String(),
    });
  }

  Future<DateTime?> getLastSyncTime(String collection) async {
    final box = Hive.box<Map>(syncMetadataBox);
    final data = box.get('last_sync_$collection');
    if (data != null && data['timestamp'] != null) {
      return DateTime.parse(data['timestamp']);
    }
    return null;
  }

  // Pending operations (for offline changes)
  Future<void> addPendingOperation(
    String operationId,
    Map<String, dynamic> operation,
  ) async {
    final box = Hive.box<Map>(syncMetadataBox);
    await box.put('pending_$operationId', operation);
  }

  Future<List<Map<String, dynamic>>> getPendingOperations() async {
    final box = Hive.box<Map>(syncMetadataBox);
    final operations = box.keys
        .where((key) => key.toString().startsWith('pending_'))
        .map((key) => box.get(key)!)
        .toList();

    return operations.map((op) => Map<String, dynamic>.from(op)).toList();
  }

  Future<void> removePendingOperation(String operationId) async {
    final box = Hive.box<Map>(syncMetadataBox);
    await box.delete('pending_$operationId');
  }

  Future<void> clearAll() async {
    await Hive.box<Trip>(tripsBox).clear();
    await Hive.box<ItineraryItem>(itineraryBox).clear();
    await Hive.box<Map>(chatBox).clear();
    await Hive.box<Map>(syncMetadataBox).clear();
  }
}
