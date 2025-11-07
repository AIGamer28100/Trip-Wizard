import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../repositories/billing_repository.dart';
import '../models/billing.dart';

class CreditMeter extends StatefulWidget {
  const CreditMeter({super.key});

  @override
  State<CreditMeter> createState() => _CreditMeterState();
}

class _CreditMeterState extends State<CreditMeter> {
  final BillingRepository _billingRepository = BillingRepository();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).currentUser;

    if (user == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<UserCredits?>(
      stream: _billingRepository.getUserCredits(user.uid).asStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(child: LinearProgressIndicator());
        }

        final credits = snapshot.data;
        if (credits == null) {
          // Initialize credits for new users
          _initializeCredits(user.uid);
          return const SizedBox(height: 20, child: LinearProgressIndicator());
        }

        final progress = credits.totalCredits > 0
            ? credits.remainingCredits / credits.totalCredits
            : 0.0;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.bolt, size: 16, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    'AI Credits: ${credits.remainingCredits}/${credits.totalCredits}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress > 0.2 ? Colors.amber : Colors.red,
                ),
              ),
              if (credits.remainingCredits == 0) ...[
                const SizedBox(height: 4),
                Text(
                  'Upgrade to Pro for more credits!',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _initializeCredits(String userId) async {
    final plan = await _billingRepository.getUserSubscriptionPlan(userId);
    await _billingRepository.updateUserCredits(
      userId,
      plan.monthlyCredits,
      plan,
    );
  }
}
