import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/community_trip.dart';
import '../models/trip.dart';
import '../services/auth_service.dart';
import 'trip_repository.dart';
import 'badge_repository.dart';

class CommunityRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Allow injecting AuthService, TripRepository and BadgeRepository to
  // avoid implicit circular construction. When not provided, we create
  // safe defaults for simple usage.
  final AuthService _authService;
  final TripRepository? _tripRepository;
  final BadgeRepository _badgeRepository;

  CommunityRepository({
    AuthService? authService,
    TripRepository? tripRepository,
    BadgeRepository? badgeRepository,
  }) : _authService = authService ?? AuthService(),
       _tripRepository = tripRepository,
       _badgeRepository = badgeRepository ?? BadgeRepository();

  // Publish a trip to community (sanitized)
  Future<String> publishTrip(Trip trip) async {
    final user = _authService.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Basic moderation - check for inappropriate content
    if (_containsInappropriateContent(trip.title) ||
        _containsInappropriateContent(trip.description)) {
      throw Exception('Trip contains inappropriate content');
    }

    // Sanitize the trip data (remove PII)
    final sanitizedTrip = CommunityTrip(
      id: '', // Will be set by Firestore
      originalTripId: trip.id,
      authorId: trip.creatorId,
      authorName: user.displayName ?? user.email ?? 'Anonymous',
      title: trip.title,
      description: trip.description,
      destination: trip.destination ?? '',
      startDate: trip.startDate,
      endDate: trip.endDate,
      likes: 0,
      likedBy: [],
      comments: [],
      publishedAt: DateTime.now(),
    );

    // Avoid creating duplicate community posts for the same original trip.
    // If a community document already exists for this originalTripId, update
    // it with the sanitized content instead of creating a new document.
    final query = await _firestore
        .collection('community_trips')
        .where('originalTripId', isEqualTo: trip.id)
        .limit(1)
        .get();

    late DocumentReference docRef;
    if (query.docs.isNotEmpty) {
      final existing = query.docs.first;
      await existing.reference.update(sanitizedTrip.toFirestore());
      docRef = existing.reference;
    } else {
      docRef = await _firestore
          .collection('community_trips')
          .add(sanitizedTrip.toFirestore());
    }

    // Check for badges after publishing
    await _badgeRepository.checkAndAwardBadges(trip.creatorId);

    return docRef.id;
  }

  // Update an existing community trip's editable fields (title/description/dates)
  Future<void> updateCommunityTrip(
    String communityTripId,
    Map<String, dynamic> updates,
  ) async {
    final ref = _firestore.collection('community_trips').doc(communityTripId);
    final doc = await ref.get();
    if (!doc.exists) throw Exception('Community trip not found');
    await ref.update(updates);
  }

  // Get all published community trips
  Stream<List<CommunityTrip>> getCommunityTrips() {
    return _firestore
        .collection('community_trips')
        .orderBy('publishedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CommunityTrip.fromFirestore(doc))
              .toList(),
        );
  }

  // Get a specific community trip
  Future<CommunityTrip?> getCommunityTrip(String tripId) async {
    final doc = await _firestore
        .collection('community_trips')
        .doc(tripId)
        .get();
    if (doc.exists) {
      return CommunityTrip.fromFirestore(doc);
    }
    return null;
  }

  // Like/unlike a community trip
  Future<void> toggleLike(String tripId, String userId) async {
    final tripRef = _firestore.collection('community_trips').doc(tripId);
    final tripDoc = await tripRef.get();
    if (!tripDoc.exists) return;

    final trip = CommunityTrip.fromFirestore(tripDoc);
    final likedBy = List<String>.from(trip.likedBy);
    final wasLiked = likedBy.contains(userId);

    if (wasLiked) {
      likedBy.remove(userId);
    } else {
      likedBy.add(userId);
    }

    await tripRef.update({'likedBy': likedBy, 'likes': likedBy.length});

    // Check for badges if this was a new like for the trip author
    if (!wasLiked && trip.authorId != userId) {
      await _badgeRepository.checkAndAwardBadges(trip.authorId);
    }
  }

  // Add a comment to a community trip
  Future<void> addComment(
    String tripId,
    String userId,
    String userName,
    String text,
  ) async {
    // Basic moderation - check for inappropriate content
    if (_containsInappropriateContent(text)) {
      throw Exception('Comment contains inappropriate content');
    }

    final comment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      userName: userName,
      text: text,
      createdAt: DateTime.now(),
    );

    final tripRef = _firestore.collection('community_trips').doc(tripId);
    final tripDoc = await tripRef.get();
    if (!tripDoc.exists) return;

    final trip = CommunityTrip.fromFirestore(tripDoc);
    final comments = List<Comment>.from(trip.comments);
    comments.add(comment);

    await tripRef.update({'comments': comments.map((c) => c.toMap()).toList()});
  }

  // Basic content moderation
  bool _containsInappropriateContent(String text) {
    final inappropriateWords = [
      'spam', 'inappropriate', 'offensive', // Add more words as needed
    ];

    final lowerText = text.toLowerCase();
    return inappropriateWords.any((word) => lowerText.contains(word));
  }

  // Save community trip as template (create new trip for user)
  Future<String> saveAsTemplate(
    CommunityTrip communityTrip,
    String userId,
  ) async {
    final newTrip = Trip(
      id: '', // Will be set by repository
      title: '${communityTrip.title} (Template)',
      description: communityTrip.description,
      creatorId: userId,
      memberIds: [userId],
      startDate: communityTrip.startDate,
      endDate: communityTrip.endDate,
      destination: communityTrip.destination,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Use the injected TripRepository if present, otherwise create a
    // local TripRepository. Since TripRepository no longer unconditionally
    // constructs a CommunityRepository, this is safe and avoids recursion.
    final tripRepo = _tripRepository ?? TripRepository();
    return await tripRepo.createTrip(newTrip);
  }
}
