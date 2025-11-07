import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/cache_service.dart';
import '../services/connectivity_service.dart';
import '../models/trip.dart';
import '../models/itinerary_item.dart';

class SyncService {
  final CacheService _cacheService;
  final ConnectivityService _connectivityService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription? _connectivitySubscription;

  SyncService(this._cacheService, this._connectivityService) {
    // Listen to connectivity changes
    _connectivityService.addListener(_onConnectivityChanged);
  }

  void _onConnectivityChanged() {
    if (_connectivityService.isOnline) {
      syncAllPendingOperations();
    }
  }

  // Sync trips
  Future<void> syncTrips() async {
    if (!_connectivityService.isOnline) {
      // Cache trips locally if offline
      return;
    }

    try {
      final tripsSnapshot = await _firestore.collection('trips').get();
      final remoteTrips = tripsSnapshot.docs
          .map((doc) => Trip.fromFirestore(doc))
          .toList();

      // Cache all trips
      for (final trip in remoteTrips) {
        await _cacheService.cacheTrip(trip);
      }

      await _cacheService.updateLastSyncTime('trips', DateTime.now());
    } catch (e) {
      print('Failed to sync trips: $e');
    }
  }

  // Sync itinerary items for a trip
  Future<void> syncItineraryItems(String tripId) async {
    if (!_connectivityService.isOnline) {
      return;
    }

    try {
      final itemsSnapshot = await _firestore
          .collection('itinerary_items')
          .where('tripId', isEqualTo: tripId)
          .get();

      final remoteItems = itemsSnapshot.docs
          .map((doc) => ItineraryItem.fromFirestore(doc))
          .toList();

      // Cache all items
      for (final item in remoteItems) {
        await _cacheService.cacheItineraryItem(item);
      }

      await _cacheService.updateLastSyncTime(
        'itinerary_$tripId',
        DateTime.now(),
      );
    } catch (e) {
      print('Failed to sync itinerary items: $e');
    }
  }

  // Sync chat messages for a trip
  Future<void> syncChatMessages(String tripId) async {
    if (!_connectivityService.isOnline) {
      return;
    }

    try {
      final lastSync = await _cacheService.getLastSyncTime('chat_$tripId');
      Query query = _firestore
          .collection('chat_messages')
          .where('tripId', isEqualTo: tripId);

      if (lastSync != null) {
        query = query.where(
          'timestamp',
          isGreaterThan: Timestamp.fromDate(lastSync),
        );
      }

      final messagesSnapshot = await query.get();

      // Cache new messages
      for (final doc in messagesSnapshot.docs) {
        final message = doc.data() as Map<String, dynamic>;
        await _cacheService.cacheChatMessage(tripId, message);
      }

      await _cacheService.updateLastSyncTime('chat_$tripId', DateTime.now());
    } catch (e) {
      print('Failed to sync chat messages: $e');
    }
  }

  // Add offline operation to queue
  Future<void> addOfflineOperation(
    String operationType,
    Map<String, dynamic> data,
  ) async {
    final operationId =
        '${operationType}_${DateTime.now().millisecondsSinceEpoch}';
    final operation = {
      'id': operationId,
      'type': operationType,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
      'retryCount': 0,
    };

    await _cacheService.addPendingOperation(operationId, operation);

    // Try to sync immediately if online
    if (_connectivityService.isOnline) {
      await syncAllPendingOperations();
    }
  }

  // Sync all pending operations
  Future<void> syncAllPendingOperations() async {
    if (!_connectivityService.isOnline) {
      return;
    }

    final pendingOperations = await _cacheService.getPendingOperations();

    for (final operation in pendingOperations) {
      try {
        await _executeOperation(operation);
        await _cacheService.removePendingOperation(operation['id']);
      } catch (e) {
        print('Failed to execute operation ${operation['id']}: $e');
        // Increment retry count and re-queue if under limit
        if (operation['retryCount'] < 3) {
          operation['retryCount'] = operation['retryCount'] + 1;
          await _cacheService.addPendingOperation(operation['id'], operation);
        } else {
          // Remove failed operation after max retries
          await _cacheService.removePendingOperation(operation['id']);
        }
      }
    }
  }

  Future<void> _executeOperation(Map<String, dynamic> operation) async {
    final type = operation['type'];
    final data = operation['data'];

    switch (type) {
      case 'create_trip':
        await _firestore.collection('trips').doc(data['id']).set(data);
        break;
      case 'update_trip':
        await _firestore.collection('trips').doc(data['id']).update(data);
        break;
      case 'create_itinerary_item':
        await _firestore
            .collection('itinerary_items')
            .doc(data['id'])
            .set(data);
        break;
      case 'update_itinerary_item':
        await _firestore
            .collection('itinerary_items')
            .doc(data['id'])
            .update(data);
        break;
      case 'delete_itinerary_item':
        await _firestore.collection('itinerary_items').doc(data['id']).delete();
        break;
      case 'send_chat_message':
        await _firestore.collection('chat_messages').add(data);
        break;
    }
  }

  // Get data with offline fallback
  Future<List<Trip>> getTripsWithOfflineFallback() async {
    if (_connectivityService.isOnline) {
      await syncTrips();
    }
    return await _cacheService.getAllCachedTrips();
  }

  Future<List<ItineraryItem>> getItineraryItemsWithOfflineFallback(
    String tripId,
  ) async {
    if (_connectivityService.isOnline) {
      await syncItineraryItems(tripId);
    }
    return await _cacheService.getCachedItineraryItems(tripId);
  }

  Future<List<Map<String, dynamic>>> getChatMessagesWithOfflineFallback(
    String tripId,
  ) async {
    if (_connectivityService.isOnline) {
      await syncChatMessages(tripId);
    }
    return await _cacheService.getCachedChatMessages(tripId);
  }

  // Conflict resolution for itinerary items
  Future<void> resolveItineraryConflict(
    String itemId,
    ItineraryItem localItem,
    ItineraryItem remoteItem,
  ) async {
    // Simple strategy: prefer the most recently updated
    if (localItem.updatedAt.isAfter(remoteItem.updatedAt)) {
      // Keep local version, update remote
      await addOfflineOperation(
        'update_itinerary_item',
        localItem.toFirestore(),
      );
    } else {
      // Use remote version, update local cache
      await _cacheService.cacheItineraryItem(remoteItem);
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }
}
