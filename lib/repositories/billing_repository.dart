import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/billing.dart';

class BillingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get user credits
  Future<UserCredits?> getUserCredits(String userId) async {
    final doc = await _firestore.collection('user_credits').doc(userId).get();
    if (doc.exists) {
      return UserCredits.fromFirestore(doc);
    }
    return null;
  }

  // Initialize or update user credits
  Future<void> updateUserCredits(
    String userId,
    int credits,
    SubscriptionPlan plan,
  ) async {
    final now = DateTime.now();
    final userCredits = UserCredits(
      userId: userId,
      remainingCredits: credits,
      totalCredits: plan.monthlyCredits,
      lastReset: now,
      updatedAt: now,
    );

    await _firestore
        .collection('user_credits')
        .doc(userId)
        .set(userCredits.toFirestore());
  }

  // Consume credits
  Future<bool> consumeCredit(String userId) async {
    final credits = await getUserCredits(userId);
    if (credits == null || !credits.hasCredits) {
      return false;
    }

    await _firestore.collection('user_credits').doc(userId).update({
      'remainingCredits': credits.remainingCredits - 1,
      'updatedAt': DateTime.now(),
    });

    return true;
  }

  // Reset monthly credits
  Future<void> resetMonthlyCredits(String userId, SubscriptionPlan plan) async {
    final now = DateTime.now();
    await _firestore.collection('user_credits').doc(userId).update({
      'remainingCredits': plan.monthlyCredits,
      'totalCredits': plan.monthlyCredits,
      'lastReset': now,
      'updatedAt': now,
    });
  }

  // Create billing record
  Future<String> createBillingRecord(BillingRecord record) async {
    final docRef = await _firestore
        .collection('billing')
        .add(record.toFirestore());
    return docRef.id;
  }

  // Get user billing records
  Stream<List<BillingRecord>> getUserBillingRecords(String userId) {
    return _firestore
        .collection('billing')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BillingRecord.fromFirestore(doc))
              .toList(),
        );
  }

  // Update billing record status
  Future<void> updateBillingRecordStatus(
    String recordId,
    String status, {
    String? stripePaymentId,
    DateTime? paidAt,
  }) async {
    final updates = {'status': status, 'updatedAt': DateTime.now()};
    if (stripePaymentId != null) {
      updates['stripePaymentId'] = stripePaymentId;
    }
    if (paidAt != null) {
      updates['paidAt'] = paidAt;
    }

    await _firestore.collection('billing').doc(recordId).update(updates);
  }

  // Get user subscription plan (this would be stored in user profile or separate collection)
  Future<SubscriptionPlan> getUserSubscriptionPlan(String userId) async {
    // For now, default to free plan. In production, this would check user's subscription status
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (userDoc.exists) {
      final data = userDoc.data();
      final planString = data?['subscriptionPlan'] as String?;
      if (planString != null) {
        return SubscriptionPlan.values.firstWhere(
          (plan) => plan.name == planString,
          orElse: () => SubscriptionPlan.free,
        );
      }
    }
    return SubscriptionPlan.free;
  }

  // Validate user entitlement for a feature
  Future<bool> hasEntitlement(String userId, String feature) async {
    final plan = await getUserSubscriptionPlan(userId);

    switch (feature) {
      case 'ai_suggestions':
        return true; // All plans have some AI suggestions
      case 'unlimited_ai':
        return plan == SubscriptionPlan.pro ||
            plan == SubscriptionPlan.enterprise;
      case 'team_collaboration':
        return plan == SubscriptionPlan.enterprise;
      case 'admin_dashboard':
        return plan == SubscriptionPlan.enterprise;
      case 'priority_support':
        return plan == SubscriptionPlan.pro ||
            plan == SubscriptionPlan.enterprise;
      default:
        return false;
    }
  }

  // Check if user can perform an action based on their plan
  Future<bool> canPerformAction(String userId, String action) async {
    final credits = await getUserCredits(userId);
    if (credits == null) return false;

    switch (action) {
      case 'ai_suggestion':
        return credits.hasCredits;
      case 'publish_trip':
        return true; // All users can publish
      case 'create_org':
        final plan = await getUserSubscriptionPlan(userId);
        return plan == SubscriptionPlan.enterprise;
      default:
        return false;
    }
  }

  // Get billing history for user
  Future<List<BillingRecord>> getBillingHistory(String userId) async {
    final snapshot = await _firestore
        .collection('billing')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => BillingRecord.fromFirestore(doc))
        .toList();
  }

  // Cancel subscription
  Future<void> cancelSubscription(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'subscriptionPlan': SubscriptionPlan.free.name,
      'subscriptionCancelled': true,
      'updatedAt': DateTime.now(),
    });

    // Reset to free tier credits
    await updateUserCredits(
      userId,
      SubscriptionPlan.free.monthlyCredits,
      SubscriptionPlan.free,
    );
  }

  // Reactivate subscription
  Future<void> reactivateSubscription(
    String userId,
    SubscriptionPlan plan,
  ) async {
    await _firestore.collection('users').doc(userId).update({
      'subscriptionPlan': plan.name,
      'subscriptionCancelled': false,
      'updatedAt': DateTime.now(),
    });

    // Update credits
    await updateUserCredits(userId, plan.monthlyCredits, plan);
  }

  // Upgrade subscription
  Future<void> upgradeSubscription(
    String userId,
    SubscriptionPlan newPlan,
  ) async {
    await _firestore.collection('users').doc(userId).update({
      'subscriptionPlan': newPlan.name,
      'updatedAt': DateTime.now(),
    });

    // Update credits
    await updateUserCredits(userId, newPlan.monthlyCredits, newPlan);
  }

  // Get organization pooled credits
  Future<int> getOrganizationCredits(String orgId) async {
    final orgDoc = await _firestore
        .collection('organizations')
        .doc(orgId)
        .get();
    if (!orgDoc.exists) return 0;

    final data = orgDoc.data();
    return data?['pooledCredits'] ?? 0;
  }

  // Add credits to organization pool
  Future<void> addOrganizationCredits(String orgId, int credits) async {
    final currentCredits = await getOrganizationCredits(orgId);
    await _firestore.collection('organizations').doc(orgId).update({
      'pooledCredits': currentCredits + credits,
      'updatedAt': DateTime.now(),
    });
  }

  // Consume organization pooled credits
  Future<bool> consumeOrganizationCredit(String orgId) async {
    final currentCredits = await getOrganizationCredits(orgId);
    if (currentCredits <= 0) return false;

    await _firestore.collection('organizations').doc(orgId).update({
      'pooledCredits': currentCredits - 1,
      'updatedAt': DateTime.now(),
    });

    return true;
  }

  // Get organization usage analytics
  Future<Map<String, dynamic>> getOrganizationAnalytics(String orgId) async {
    final orgDoc = await _firestore
        .collection('organizations')
        .doc(orgId)
        .get();
    if (!orgDoc.exists) return {};

    final orgData = orgDoc.data()!;
    final memberIds = List<String>.from(orgData['memberIds'] ?? []);

    // Get billing records for all members
    final billingRecords = <BillingRecord>[];
    for (final memberId in memberIds) {
      final memberRecords = await getBillingHistory(memberId);
      billingRecords.addAll(memberRecords);
    }

    // Calculate analytics
    final totalSpent = billingRecords
        .where((record) => record.status == 'paid')
        .fold<double>(0, (total, record) => total + record.amount);

    final monthlyRevenue = billingRecords
        .where(
          (record) =>
              record.status == 'paid' &&
              record.createdAt.isAfter(
                DateTime.now().subtract(const Duration(days: 30)),
              ),
        )
        .fold<double>(0, (total, record) => total + record.amount);

    return {
      'totalMembers': memberIds.length,
      'totalSpent': totalSpent,
      'monthlyRevenue': monthlyRevenue,
      'pooledCredits': orgData['pooledCredits'] ?? 0,
      'pendingInvites': (orgData['pendingInvites'] as List?)?.length ?? 0,
      'createdAt': orgData['createdAt'],
    };
  }
}
