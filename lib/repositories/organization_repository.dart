import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/organization.dart';
import '../models/organization_credit_usage.dart';

class OrganizationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new organization
  Future<String> createOrganization(String name, String adminId) async {
    final now = DateTime.now();
    final orgData = {
      'name': name,
      'adminId': adminId,
      'memberIds': [adminId],
      'pendingInvites': [],
      'createdAt': now,
      'updatedAt': now,
    };

    final docRef = await _firestore.collection('organizations').add(orgData);
    return docRef.id;
  }

  // Get organization by ID
  Future<Organization?> getOrganization(String orgId) async {
    final doc = await _firestore.collection('organizations').doc(orgId).get();
    if (doc.exists) {
      return Organization.fromFirestore(doc);
    }
    return null;
  }

  // Get organizations for a user (as admin or member)
  Stream<List<Organization>> getUserOrganizations(String userId) {
    return _firestore
        .collection('organizations')
        .where('memberIds', arrayContains: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Organization.fromFirestore(doc))
              .toList(),
        );
  }

  // Update organization
  Future<void> updateOrganization(
    String orgId,
    Map<String, dynamic> updates,
  ) async {
    updates['updatedAt'] = DateTime.now();
    await _firestore.collection('organizations').doc(orgId).update(updates);
  }

  // Add member to organization
  Future<void> addMember(String orgId, String userId) async {
    await _firestore.collection('organizations').doc(orgId).update({
      'memberIds': FieldValue.arrayUnion([userId]),
      'updatedAt': DateTime.now(),
    });
  }

  // Remove member from organization
  Future<void> removeMember(String orgId, String userId) async {
    await _firestore.collection('organizations').doc(orgId).update({
      'memberIds': FieldValue.arrayRemove([userId]),
      'updatedAt': DateTime.now(),
    });
  }

  // Add pending invite
  Future<void> addPendingInvite(String orgId, String email) async {
    await _firestore.collection('organizations').doc(orgId).update({
      'pendingInvites': FieldValue.arrayUnion([email]),
      'updatedAt': DateTime.now(),
    });
  }

  // Remove pending invite
  Future<void> removePendingInvite(String orgId, String email) async {
    await _firestore.collection('organizations').doc(orgId).update({
      'pendingInvites': FieldValue.arrayRemove([email]),
      'updatedAt': DateTime.now(),
    });
  }

  // Delete organization
  Future<void> deleteOrganization(String orgId) async {
    await _firestore.collection('organizations').doc(orgId).delete();
  }

  // Check if user can manage organization
  Future<bool> canUserManageOrg(String orgId, String userId) async {
    final org = await getOrganization(orgId);
    return org?.isAdmin(userId) ?? false;
  }

  // Get all members of an organization with their details
  Stream<List<Map<String, dynamic>>> getOrganizationMembers(String orgId) {
    return _firestore
        .collection('organizations')
        .doc(orgId)
        .snapshots()
        .asyncMap((orgDoc) async {
          if (!orgDoc.exists) return [];

          final org = Organization.fromFirestore(orgDoc);
          final members = <Map<String, dynamic>>[];

          for (final memberId in org.memberIds) {
            final userDoc = await _firestore
                .collection('users')
                .doc(memberId)
                .get();
            if (userDoc.exists) {
              final userData = userDoc.data() as Map<String, dynamic>;
              members.add({
                'id': memberId,
                'email': userData['email'] ?? 'Unknown',
                'displayName': userData['displayName'] ?? 'Unknown',
                'isAdmin': memberId == org.adminId,
              });
            }
          }

          return members;
        });
  }

  // Transfer admin rights to another member
  Future<void> transferAdmin(String orgId, String newAdminId) async {
    await _firestore.collection('organizations').doc(orgId).update({
      'adminId': newAdminId,
      'updatedAt': DateTime.now(),
    });
  }

  // ============= Credit Pool Management =============

  /// Add credits to organization pool
  Future<void> addCreditsToPool(String orgId, int credits) async {
    await _firestore.collection('organizations').doc(orgId).update({
      'creditPool': FieldValue.increment(credits),
      'updatedAt': DateTime.now(),
    });
  }

  /// Deduct credits from organization pool
  Future<bool> deductCreditsFromPool(String orgId, int credits) async {
    final org = await getOrganization(orgId);
    if (org == null || org.creditPool < credits) {
      return false; // Not enough credits
    }

    await _firestore.collection('organizations').doc(orgId).update({
      'creditPool': FieldValue.increment(-credits),
      'updatedAt': DateTime.now(),
    });
    return true;
  }

  /// Set credit limit for a specific member
  Future<void> setMemberCreditLimit(
    String orgId,
    String userId,
    int limit,
  ) async {
    await _firestore.collection('organizations').doc(orgId).update({
      'memberCreditLimits.$userId': limit,
      'updatedAt': DateTime.now(),
    });
  }

  /// Remove credit limit for a member
  Future<void> removeMemberCreditLimit(String orgId, String userId) async {
    await _firestore.collection('organizations').doc(orgId).update({
      'memberCreditLimits.$userId': FieldValue.delete(),
      'updatedAt': DateTime.now(),
    });
  }

  /// Record credit usage by a member
  Future<void> recordCreditUsage({
    required String organizationId,
    required String userId,
    required String userName,
    required int creditsUsed,
    required String action,
    String? tripId,
  }) async {
    final usage = OrganizationCreditUsage(
      id: '', // Will be generated by Firestore
      organizationId: organizationId,
      userId: userId,
      userName: userName,
      creditsUsed: creditsUsed,
      action: action,
      tripId: tripId,
      timestamp: DateTime.now(),
    );

    await _firestore
        .collection('organization_credit_usage')
        .add(usage.toFirestore());
  }

  /// Get credit usage history for organization
  Stream<List<OrganizationCreditUsage>> getCreditUsageHistory(
    String orgId, {
    int limit = 50,
  }) {
    return _firestore
        .collection('organization_credit_usage')
        .where('organizationId', isEqualTo: orgId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => OrganizationCreditUsage.fromFirestore(doc))
              .toList(),
        );
  }

  /// Get credit usage summary by member
  Future<List<MemberCreditSummary>> getMemberCreditSummaries(
    String orgId,
  ) async {
    final org = await getOrganization(orgId);
    if (org == null) return [];

    // Get all usage records
    final usageSnapshot = await _firestore
        .collection('organization_credit_usage')
        .where('organizationId', isEqualTo: orgId)
        .get();

    // Group by user
    final Map<String, List<OrganizationCreditUsage>> usageByUser = {};
    for (final doc in usageSnapshot.docs) {
      final usage = OrganizationCreditUsage.fromFirestore(doc);
      usageByUser.putIfAbsent(usage.userId, () => []).add(usage);
    }

    // Create summaries
    final summaries = <MemberCreditSummary>[];
    for (final userId in org.memberIds) {
      final userUsage = usageByUser[userId] ?? [];
      final totalCredits = userUsage.fold<int>(
        0,
        (sum, usage) => sum + usage.creditsUsed,
      );

      DateTime? lastActivity;
      if (userUsage.isNotEmpty) {
        lastActivity = userUsage
            .map((u) => u.timestamp)
            .reduce((a, b) => a.isAfter(b) ? a : b);
      }

      // Get user details
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userName = userDoc.exists
          ? (userDoc.data() as Map<String, dynamic>)['displayName'] ?? 'Unknown'
          : 'Unknown';

      summaries.add(
        MemberCreditSummary(
          userId: userId,
          userName: userName,
          totalCreditsUsed: totalCredits,
          creditLimit: org.getMemberCreditLimit(userId),
          lastActivity: lastActivity,
        ),
      );
    }

    return summaries;
  }

  /// Check if member can use credits (hasn't exceeded limit)
  Future<bool> canMemberUseCredits(
    String orgId,
    String userId,
    int creditsNeeded,
  ) async {
    final org = await getOrganization(orgId);
    if (org == null) return false;

    // Check organization pool
    if (org.creditPool < creditsNeeded) return false;

    // Check member limit if set
    final limit = org.getMemberCreditLimit(userId);
    if (limit > 0) {
      final summaries = await getMemberCreditSummaries(orgId);
      final userSummary = summaries.firstWhere(
        (s) => s.userId == userId,
        orElse: () => MemberCreditSummary(
          userId: userId,
          userName: 'Unknown',
          totalCreditsUsed: 0,
          creditLimit: limit,
        ),
      );

      if (userSummary.totalCreditsUsed + creditsNeeded > limit) {
        return false; // Would exceed personal limit
      }
    }

    return true;
  }
}
