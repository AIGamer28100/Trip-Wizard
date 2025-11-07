import 'package:flutter/material.dart';
import '../models/billing.dart';
import '../screens/subscription_screen.dart';

class CreditGateDialog extends StatelessWidget {
  final UserCredits? credits;

  const CreditGateDialog({super.key, this.credits});

  @override
  Widget build(BuildContext context) {
    final hasNoCredits = credits == null || !credits!.hasCredits;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            hasNoCredits ? Icons.block : Icons.warning,
            color: hasNoCredits ? Colors.red : Colors.orange,
          ),
          const SizedBox(width: 8),
          Text(hasNoCredits ? 'No Credits' : 'Low Credits'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasNoCredits)
            const Text(
              'You have run out of AI credits. Upgrade your plan to continue using AI features.',
            )
          else
            Text(
              'You have ${credits!.remainingCredits} credits remaining. Consider upgrading for more credits.',
            ),
          const SizedBox(height: 16),
          const Text('Plans:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildPlanTile(SubscriptionPlan.free),
          _buildPlanTile(SubscriptionPlan.pro),
          _buildPlanTile(SubscriptionPlan.enterprise),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        if (!hasNoCredits)
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Continue Anyway'),
          ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(false);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const SubscriptionScreen(),
              ),
            );
          },
          child: const Text('View Plans'),
        ),
      ],
    );
  }

  Widget _buildPlanTile(SubscriptionPlan plan) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('${plan.displayName}: ${plan.monthlyCredits} credits/mo'),
          Text(
            '\$${plan.monthlyPrice.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Static method to show the dialog and return whether to proceed
  static Future<bool> show(BuildContext context, UserCredits? credits) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CreditGateDialog(credits: credits),
    );
    return result ?? false;
  }
}
