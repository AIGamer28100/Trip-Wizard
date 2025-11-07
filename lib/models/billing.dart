import 'package:cloud_firestore/cloud_firestore.dart';

class UserCredits {
  final String userId;
  final int remainingCredits;
  final int totalCredits;
  final DateTime lastReset;
  final DateTime updatedAt;

  UserCredits({
    required this.userId,
    required this.remainingCredits,
    required this.totalCredits,
    required this.lastReset,
    required this.updatedAt,
  });

  factory UserCredits.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserCredits(
      userId: doc.id,
      remainingCredits: data['remainingCredits'] ?? 0,
      totalCredits: data['totalCredits'] ?? 0,
      lastReset: (data['lastReset'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'remainingCredits': remainingCredits,
      'totalCredits': totalCredits,
      'lastReset': lastReset,
      'updatedAt': updatedAt,
    };
  }

  bool get hasCredits => remainingCredits > 0;
}

class BillingRecord {
  final String id;
  final String userId;
  final double amount;
  final String currency;
  final String period;
  final String status;
  final String? stripePaymentId;
  final DateTime createdAt;
  final DateTime? paidAt;

  BillingRecord({
    required this.id,
    required this.userId,
    required this.amount,
    required this.currency,
    required this.period,
    required this.status,
    this.stripePaymentId,
    required this.createdAt,
    this.paidAt,
  });

  factory BillingRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BillingRecord(
      id: doc.id,
      userId: data['userId'] ?? '',
      amount: (data['amount'] as num).toDouble(),
      currency: data['currency'] ?? 'USD',
      period: data['period'] ?? 'monthly',
      status: data['status'] ?? 'pending',
      stripePaymentId: data['stripePaymentId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      paidAt: data['paidAt'] != null
          ? (data['paidAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'amount': amount,
      'currency': currency,
      'period': period,
      'status': status,
      'stripePaymentId': stripePaymentId,
      'createdAt': createdAt,
      'paidAt': paidAt,
    };
  }
}

enum SubscriptionPlan { free, pro, enterprise }

extension SubscriptionPlanExtension on SubscriptionPlan {
  String get displayName {
    switch (this) {
      case SubscriptionPlan.free:
        return 'Free';
      case SubscriptionPlan.pro:
        return 'Pro';
      case SubscriptionPlan.enterprise:
        return 'Enterprise';
    }
  }

  int get monthlyCredits {
    switch (this) {
      case SubscriptionPlan.free:
        return 10;
      case SubscriptionPlan.pro:
        return 100;
      case SubscriptionPlan.enterprise:
        return 1000;
    }
  }

  double get monthlyPrice {
    switch (this) {
      case SubscriptionPlan.free:
        return 0.0;
      case SubscriptionPlan.pro:
        return 9.99;
      case SubscriptionPlan.enterprise:
        return 49.99;
    }
  }
}
