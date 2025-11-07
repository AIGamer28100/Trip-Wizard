import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../repositories/billing_repository.dart';
import '../models/billing.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final BillingRepository _billingRepository = BillingRepository();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Subscription Plans')),
      body: user == null
          ? const Center(child: Text('Please sign in to view subscriptions'))
          : FutureBuilder<SubscriptionPlan>(
              future: _billingRepository.getUserSubscriptionPlan(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final currentPlan = snapshot.data ?? SubscriptionPlan.free;

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Plan: ${currentPlan.displayName}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: ListView(
                          children: [
                            _buildPlanCard(
                              SubscriptionPlan.free,
                              currentPlan,
                              'Perfect for trying out Trip Wizards',
                              [
                                '10 AI suggestions per month',
                                'Basic trip planning',
                                'Community access',
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildPlanCard(
                              SubscriptionPlan.pro,
                              currentPlan,
                              'For frequent travelers and trip planners',
                              [
                                '100 AI suggestions per month',
                                'Advanced itinerary planning',
                                'Priority community features',
                                'Booking integration',
                                'Calendar sync',
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildPlanCard(
                              SubscriptionPlan.enterprise,
                              currentPlan,
                              'For teams and organizations',
                              [
                                '1000 AI suggestions per month',
                                'Team collaboration tools',
                                'Admin dashboard',
                                'Custom integrations',
                                'Priority support',
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildPlanCard(
    SubscriptionPlan plan,
    SubscriptionPlan currentPlan,
    String description,
    List<String> features,
  ) {
    final isCurrentPlan = plan == currentPlan;
    final user = Provider.of<AuthService>(context, listen: false).currentUser;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: isCurrentPlan ? 4 : 1,
      color: isCurrentPlan
          ? colorScheme.primaryContainer
          : colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCurrentPlan
              ? colorScheme.primary
              : colorScheme.outlineVariant,
          width: isCurrentPlan ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  plan.displayName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isCurrentPlan
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurface,
                  ),
                ),
                if (isCurrentPlan) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Current',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '\$${plan.monthlyPrice.toStringAsFixed(2)}/month',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: isCurrentPlan
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isCurrentPlan
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            ...features.map(
              (feature) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: isCurrentPlan
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isCurrentPlan
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (!isCurrentPlan)
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _upgradePlan(user?.uid, plan),
                  child: Text('Upgrade to ${plan.displayName}'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _upgradePlan(String? userId, SubscriptionPlan plan) async {
    if (userId == null) return;

    try {
      // In a real implementation, this would redirect to Stripe Checkout
      // For now, we'll simulate the upgrade
      await _billingRepository.upgradeSubscription(userId, plan);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully upgraded to ${plan.displayName}!'),
          ),
        );
        // Refresh the screen
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to upgrade: $e')));
      }
    }
  }
}
