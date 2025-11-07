import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/badge.dart';
import '../models/community_trip.dart';

class BadgeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Award a badge to a user
  Future<void> awardBadge(String userId, BadgeType type) async {
    // Check if user already has this badge
    final existingBadges = await getUserBadges(userId);
    if (existingBadges.any((badge) => badge.type == type)) {
      return; // Already has this badge
    }

    final badge = Badge(
      id: '', // Will be set by Firestore
      userId: userId,
      type: type,
      earnedAt: DateTime.now(),
    );

    await _firestore.collection('badges').add(badge.toFirestore());
  }

  // Get all badges for a user
  Future<List<Badge>> getUserBadges(String userId) async {
    final snapshot = await _firestore
        .collection('badges')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) => Badge.fromFirestore(doc)).toList();
  }

  // Check and award badges based on user actions
  Future<void> checkAndAwardBadges(String userId) async {
    await _checkFirstTripPublished(userId);
    await _checkFirstLikeReceived(userId);
    await _checkCommunityContributor(userId);
    await _checkTripPlanner(userId);
    await _checkSocialButterfly(userId);
  }

  Future<void> _checkFirstTripPublished(String userId) async {
    final publishedTrips = await _firestore
        .collection('community_trips')
        .where('authorId', isEqualTo: userId)
        .limit(1)
        .get();

    if (publishedTrips.docs.isNotEmpty) {
      await awardBadge(userId, BadgeType.firstTripPublished);
    }
  }

  Future<void> _checkFirstLikeReceived(String userId) async {
    final userTrips = await _firestore
        .collection('community_trips')
        .where('authorId', isEqualTo: userId)
        .get();

    bool hasReceivedLike = false;
    for (final tripDoc in userTrips.docs) {
      final trip = CommunityTrip.fromFirestore(tripDoc);
      if (trip.likes > 0) {
        hasReceivedLike = true;
        break;
      }
    }

    if (hasReceivedLike) {
      await awardBadge(userId, BadgeType.firstLikeReceived);
    }
  }

  Future<void> _checkCommunityContributor(String userId) async {
    final publishedTrips = await _firestore
        .collection('community_trips')
        .where('authorId', isEqualTo: userId)
        .get();

    if (publishedTrips.docs.length >= 5) {
      await awardBadge(userId, BadgeType.communityContributor);
    }
  }

  Future<void> _checkTripPlanner(String userId) async {
    final userTrips = await _firestore
        .collection('trips')
        .where('creatorId', isEqualTo: userId)
        .get();

    if (userTrips.docs.length >= 10) {
      await awardBadge(userId, BadgeType.tripPlanner);
    }
  }

  Future<void> _checkSocialButterfly(String userId) async {
    final userTrips = await _firestore
        .collection('community_trips')
        .where('authorId', isEqualTo: userId)
        .get();

    int totalLikes = 0;
    for (final tripDoc in userTrips.docs) {
      final trip = CommunityTrip.fromFirestore(tripDoc);
      totalLikes += trip.likes;
    }

    if (totalLikes >= 50) {
      await awardBadge(userId, BadgeType.socialButterfly);
    }
  }

  // Get leaderboard based on community engagement
  Future<List<LeaderboardEntry>> getLeaderboard() async {
    final communityTrips = await _firestore.collection('community_trips').get();

    // Group trips by author
    final authorStats = <String, Map<String, dynamic>>{};

    for (final tripDoc in communityTrips.docs) {
      final trip = CommunityTrip.fromFirestore(tripDoc);
      final authorId = trip.authorId;

      if (!authorStats.containsKey(authorId)) {
        authorStats[authorId] = {
          'userName': trip.authorName,
          'tripsPublished': 0,
          'likesReceived': 0,
          'commentsReceived': 0,
        };
      }

      authorStats[authorId]!['tripsPublished'] += 1;
      authorStats[authorId]!['likesReceived'] += trip.likes;
      authorStats[authorId]!['commentsReceived'] += trip.comments.length;
    }

    // Calculate scores and create leaderboard entries
    final leaderboard = <LeaderboardEntry>[];
    for (final entry in authorStats.entries) {
      final stats = entry.value;
      final score =
          (stats['tripsPublished'] * 10) +
          (stats['likesReceived'] * 2) +
          (stats['commentsReceived'] * 1);

      leaderboard.add(
        LeaderboardEntry(
          userId: entry.key,
          userName: stats['userName'],
          score: score,
          tripsPublished: stats['tripsPublished'],
          likesReceived: stats['likesReceived'],
          commentsReceived: stats['commentsReceived'],
        ),
      );
    }

    // Sort by score descending
    leaderboard.sort((a, b) => b.score.compareTo(a.score));

    return leaderboard.take(10).toList(); // Top 10
  }
}
