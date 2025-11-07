import 'package:flutter_test/flutter_test.dart';
import 'package:trip_wizards/models/billing.dart';

void main() {
  group('SubscriptionPlan', () {
    test('should have correct pricing', () {
      expect(SubscriptionPlan.free.monthlyPrice, 0.0);
      expect(SubscriptionPlan.pro.monthlyPrice, 9.99);
      expect(SubscriptionPlan.enterprise.monthlyPrice, 49.99);
    });

    test('should have correct monthly credits', () {
      expect(SubscriptionPlan.free.monthlyCredits, 10);
      expect(SubscriptionPlan.pro.monthlyCredits, 100);
      expect(SubscriptionPlan.enterprise.monthlyCredits, 1000);
    });

    test('should have correct display names', () {
      expect(SubscriptionPlan.free.displayName, 'Free');
      expect(SubscriptionPlan.pro.displayName, 'Pro');
      expect(SubscriptionPlan.enterprise.displayName, 'Enterprise');
    });
  });

  group('UserCredits', () {
    test('should create UserCredits correctly', () {
      final now = DateTime.now();
      final credits = UserCredits(
        userId: 'test-user',
        remainingCredits: 50,
        totalCredits: 100,
        lastReset: now,
        updatedAt: now,
      );

      expect(credits.userId, 'test-user');
      expect(credits.remainingCredits, 50);
      expect(credits.totalCredits, 100);
      expect(credits.hasCredits, true);
    });

    test('should detect when no credits remain', () {
      final now = DateTime.now();
      final credits = UserCredits(
        userId: 'test-user',
        remainingCredits: 0,
        totalCredits: 100,
        lastReset: now,
        updatedAt: now,
      );

      expect(credits.hasCredits, false);
    });
  });

  group('BillingRecord', () {
    test('should create BillingRecord correctly', () {
      final now = DateTime.now();
      final record = BillingRecord(
        id: 'test-record-id',
        userId: 'test-user',
        amount: 9.99,
        currency: 'USD',
        period: 'monthly',
        status: 'pending',
        createdAt: now,
      );

      expect(record.id, 'test-record-id');
      expect(record.userId, 'test-user');
      expect(record.amount, 9.99);
      expect(record.currency, 'USD');
      expect(record.period, 'monthly');
      expect(record.status, 'pending');
    });
  });
}
