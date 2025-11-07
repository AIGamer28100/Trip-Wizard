import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/billing.dart';
import '../services/billing_service.dart';

class CreditMeterWidget extends StatelessWidget {
  final bool compact;

  const CreditMeterWidget({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserCredits?>(
      stream: context.watch<BillingService>().creditsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final credits = snapshot.data;
        if (credits == null) {
          return const SizedBox.shrink();
        }

        final percentage = credits.totalCredits > 0
            ? (credits.remainingCredits / credits.totalCredits)
            : 0.0;

        final color = percentage > 0.5
            ? Colors.green
            : percentage > 0.2
            ? Colors.orange
            : Colors.red;

        if (compact) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.stars, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                '${credits.remainingCredits}',
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          );
        }

        final theme = Theme.of(context);
        return Card(
          color: theme.colorScheme.surface,
          elevation: 0.5,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: theme.colorScheme.outlineVariant.withOpacity(0.4),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context).creditsTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${credits.remainingCredits} / ${credits.totalCredits}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 8,
                ),
                const SizedBox(height: 8),
                if (percentage < 0.2)
                  Text(
                    AppLocalizations.of(context).creditsLow,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.red[300],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
