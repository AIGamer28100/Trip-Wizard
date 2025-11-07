import 'package:firebase_auth/firebase_auth.dart';
import '../models/billing.dart';
import '../repositories/billing_repository.dart';

class BillingService {
  final BillingRepository _repository = BillingRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream of user credits
  Stream<UserCredits?> get creditsStream {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value(null);
    }
    return Stream.periodic(
      const Duration(seconds: 5),
    ).asyncMap((_) => _repository.getUserCredits(userId));
  }

  // Get current user credits
  Future<UserCredits?> getCurrentUserCredits() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;
    return _repository.getUserCredits(userId);
  }

  // Consume a credit for AI usage
  Future<bool> consumeCredit() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;
    return _repository.consumeCredit(userId);
  }

  // Check if user has credits available
  Future<bool> hasCreditsAvailable() async {
    final credits = await getCurrentUserCredits();
    return credits?.hasCredits ?? false;
  }

  // Initialize credits for new user
  Future<void> initializeUserCredits(SubscriptionPlan plan) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    await _repository.updateUserCredits(userId, plan.monthlyCredits, plan);
  }

  // Reset monthly credits
  Future<void> resetMonthlyCredits(SubscriptionPlan plan) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    await _repository.resetMonthlyCredits(userId, plan);
  }

  // Get billing records stream
  Stream<List<BillingRecord>> getBillingRecordsStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }
    return _repository.getUserBillingRecords(userId);
  }

  // Create billing record
  Future<String> createBillingRecord(BillingRecord record) async {
    return _repository.createBillingRecord(record);
  }

  // Update billing record status
  Future<void> updateBillingRecordStatus(
    String recordId,
    String status, {
    String? stripePaymentId,
    DateTime? paidAt,
  }) async {
    await _repository.updateBillingRecordStatus(
      recordId,
      status,
      stripePaymentId: stripePaymentId,
      paidAt: paidAt,
    );
  }
}
