import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trip.dart';
import 'community_repository.dart';
import '../utils/logger.dart';

final _log = getLogger('TripRepository');

class TripRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Make the community repository optional to avoid circular construction.
  // If a caller needs the CommunityRepository, they can provide one via the
  // constructor. Creating a CommunityRepository by default would lead to
  // mutual instantiation between TripRepository and CommunityRepository.
  final CommunityRepository? _communityRepository;

  TripRepository({CommunityRepository? communityRepository})
    : _communityRepository = communityRepository;

  // Create a new trip
  Future<String> createTrip(Trip trip) async {
    final docRef = await _firestore.collection('trips').add(trip.toFirestore());
    return docRef.id;
  }

  // Get a trip by ID
  Future<Trip?> getTrip(String tripId) async {
    final doc = await _firestore.collection('trips').doc(tripId).get();
    if (doc.exists) {
      return Trip.fromFirestore(doc);
    }
    return null;
  }

  // Get trips for a user
  Stream<List<Trip>> getUserTrips(String userId) {
    _log.info('Getting trips for user: $userId');
    return _firestore
        .collection('trips')
        .where('memberIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
          _log.fine('Received ${snapshot.docs.length} documents');
          try {
            final trips = snapshot.docs.map((doc) {
              _log.finer('Processing doc ${doc.id}');
              return Trip.fromFirestore(doc);
            }).toList();
            _log.info('Successfully processed ${trips.length} trips');
            return trips;
          } catch (e, stackTrace) {
            // If mapping fails for any reason, log and return an empty list
            // to avoid bubbling an exception up to the StreamBuilder which
            // causes the app to show a red error screen.
            _log.severe('Error processing trips: $e', e, stackTrace);
            return <Trip>[];
          }
        });
  }

  // Update a trip
  Future<void> updateTrip(String tripId, Map<String, dynamic> updates) async {
    await _firestore.collection('trips').doc(tripId).update(updates);
  }

  // Delete a trip
  Future<void> deleteTrip(String tripId) async {
    await _firestore.collection('trips').doc(tripId).delete();
  }

  // Publish trip to community
  Future<String> publishTrip(String tripId) async {
    final trip = await getTrip(tripId);
    if (trip == null) throw Exception('Trip not found');

    // Delegate to the provided CommunityRepository if available. If not,
    // construct a local CommunityRepository. CommunityRepository no longer
    // eagerly instantiates a TripRepository, so this avoids recursion.
    final community = _communityRepository ?? CommunityRepository();
    final communityId = await community.publishTrip(trip);

    // Persist a backlink from the trip to the community post so future
    // publishes update the same community document instead of creating
    // duplicates. This also enables the UI to link directly to the
    // community post.
    await _firestore.collection('trips').doc(tripId).update({
      'communityTripId': communityId,
    });

    return communityId;
  }
}
