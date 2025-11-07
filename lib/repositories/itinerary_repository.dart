import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/itinerary_item.dart';
import '../services/sync_service.dart';

class ItineraryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  SyncService? _syncService;

  void setSyncService(SyncService syncService) {
    _syncService = syncService;
  }

  // Add an itinerary item
  Future<String> addItineraryItem(ItineraryItem item) async {
    final docRef = await _firestore
        .collection('itinerary_items')
        .add(item.toFirestore());

    // Cache locally
    await _syncService?.addOfflineOperation(
      'create_itinerary_item',
      item.toFirestore(),
    );

    return docRef.id;
  }

  // Get itinerary items for a trip
  Stream<List<ItineraryItem>> getTripItineraryItems(String tripId) {
    return _firestore
        .collection('itinerary_items')
        .where('tripId', isEqualTo: tripId)
        .orderBy('day')
        .orderBy('time')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ItineraryItem.fromFirestore(doc))
              .toList(),
        );
  }

  // Get itinerary items for a specific day
  Stream<List<ItineraryItem>> getDayItineraryItems(String tripId, int day) {
    return _firestore
        .collection('itinerary_items')
        .where('tripId', isEqualTo: tripId)
        .where('day', isEqualTo: day)
        .orderBy('time')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ItineraryItem.fromFirestore(doc))
              .toList(),
        );
  }

  // Update an itinerary item
  Future<void> updateItineraryItem(
    String itemId,
    Map<String, dynamic> updates,
  ) async {
    await _firestore.collection('itinerary_items').doc(itemId).update(updates);

    // Cache locally
    updates['id'] = itemId;
    await _syncService?.addOfflineOperation('update_itinerary_item', updates);
  }

  // Delete an itinerary item
  Future<void> deleteItineraryItem(String itemId) async {
    await _firestore.collection('itinerary_items').doc(itemId).delete();

    // Cache locally
    await _syncService?.addOfflineOperation('delete_itinerary_item', {
      'id': itemId,
    });
  }

  // Get all itinerary items for a trip (for sync)
  Future<List<ItineraryItem>> getAllItineraryItems(String tripId) async {
    final snapshot = await _firestore
        .collection('itinerary_items')
        .where('tripId', isEqualTo: tripId)
        .get();

    return snapshot.docs
        .map((doc) => ItineraryItem.fromFirestore(doc))
        .toList();
  }

  // Get itinerary items with offline fallback
  Future<List<ItineraryItem>> getItineraryItemsWithOfflineFallback(
    String tripId,
  ) async {
    return await _syncService?.getItineraryItemsWithOfflineFallback(tripId) ??
        [];
  }
}
