import 'package:cloud_firestore/cloud_firestore.dart';

enum BadgeType {
  firstTripPublished,
  firstLikeReceived,
  communityContributor,
  tripPlanner,
  socialButterfly,
}

extension BadgeTypeExtension on BadgeType {
  String get displayName {
    switch (this) {
      case BadgeType.firstTripPublished:
        return 'First Publisher';
      case BadgeType.firstLikeReceived:
        return 'Liked!';
      case BadgeType.communityContributor:
        return 'Community Contributor';
      case BadgeType.tripPlanner:
        return 'Trip Planner';
      case BadgeType.socialButterfly:
        return 'Social Butterfly';
    }
  }

  String get description {
    switch (this) {
      case BadgeType.firstTripPublished:
        return 'Published your first trip to the community';
      case BadgeType.firstLikeReceived:
        return 'Received your first like on a community trip';
      case BadgeType.communityContributor:
        return 'Contributed 5 trips to the community';
      case BadgeType.tripPlanner:
        return 'Planned 10 trips';
      case BadgeType.socialButterfly:
        return 'Received 50 likes on your trips';
    }
  }

  String get icon {
    switch (this) {
      case BadgeType.firstTripPublished:
        return '📝';
      case BadgeType.firstLikeReceived:
        return '❤️';
      case BadgeType.communityContributor:
        return '🌟';
      case BadgeType.tripPlanner:
        return '🗺️';
      case BadgeType.socialButterfly:
        return '🦋';
    }
  }
}

class Badge {
  final String id;
  final String userId;
  final BadgeType type;
  final DateTime earnedAt;

  Badge({
    required this.id,
    required this.userId,
    required this.type,
    required this.earnedAt,
  });

  factory Badge.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Badge(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: BadgeType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => BadgeType.firstTripPublished,
      ),
      earnedAt: (data['earnedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'userId': userId, 'type': type.name, 'earnedAt': earnedAt};
  }
}

class LeaderboardEntry {
  final String userId;
  final String userName;
  final int score;
  final int tripsPublished;
  final int likesReceived;
  final int commentsReceived;

  LeaderboardEntry({
    required this.userId,
    required this.userName,
    required this.score,
    required this.tripsPublished,
    required this.likesReceived,
    required this.commentsReceived,
  });
}
