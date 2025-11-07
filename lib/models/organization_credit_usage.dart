import 'package:cloud_firestore/cloud_firestore.dart';

/// Tracks AI credit usage by organization members
class OrganizationCreditUsage {
  final String id;
  final String organizationId;
  final String userId;
  final String userName;
  final int creditsUsed;
  final String
  action; // 'ai_query', 'itinerary_generation', 'booking_search', etc.
  final String? tripId;
  final DateTime timestamp;

  OrganizationCreditUsage({
    required this.id,
    required this.organizationId,
    required this.userId,
    required this.userName,
    required this.creditsUsed,
    required this.action,
    this.tripId,
    required this.timestamp,
  });

  factory OrganizationCreditUsage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrganizationCreditUsage(
      id: doc.id,
      organizationId: data['organizationId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Unknown',
      creditsUsed: data['creditsUsed'] ?? 0,
      action: data['action'] ?? 'unknown',
      tripId: data['tripId'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'organizationId': organizationId,
      'userId': userId,
      'userName': userName,
      'creditsUsed': creditsUsed,
      'action': action,
      'tripId': tripId,
      'timestamp': timestamp,
    };
  }
}

/// Summary of credit usage by member
class MemberCreditSummary {
  final String userId;
  final String userName;
  final int totalCreditsUsed;
  final int creditLimit; // 0 = no limit
  final DateTime? lastActivity;

  MemberCreditSummary({
    required this.userId,
    required this.userName,
    required this.totalCreditsUsed,
    this.creditLimit = 0,
    this.lastActivity,
  });

  /// Check if member has exceeded their credit limit
  bool hasExceededLimit() {
    return creditLimit > 0 && totalCreditsUsed >= creditLimit;
  }

  /// Get remaining credits (null if no limit)
  int? getRemainingCredits() {
    if (creditLimit == 0) return null;
    return creditLimit - totalCreditsUsed;
  }

  /// Get credit usage percentage (0-100, null if no limit)
  double? getUsagePercentage() {
    if (creditLimit == 0) return null;
    return (totalCreditsUsed / creditLimit * 100).clamp(0, 100);
  }
}
