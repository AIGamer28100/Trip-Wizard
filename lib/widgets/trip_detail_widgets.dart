import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/itinerary_item.dart';
import '../repositories/itinerary_repository.dart';

/// Shared widgets for trip detail screens (both community and personal trips)

// Info card widget for displaying stats
class TripInfoCard extends StatelessWidget {
  final ThemeData theme;
  final IconData icon;
  final String label;
  final String value;

  const TripInfoCard({
    super.key,
    required this.theme,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

// Trip header with gradient background
class TripHeader extends StatelessWidget {
  final ThemeData theme;
  final String title;
  final String destination;
  final Widget? trailing;
  final Widget? subtitle;

  const TripHeader({
    super.key,
    required this.theme,
    required this.title,
    required this.destination,
    this.trailing,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.secondaryContainer,
          ],
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subtitle != null) ...[subtitle!, const SizedBox(height: 16)],
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(destination, style: theme.textTheme.titleMedium),
            ],
          ),
        ],
      ),
    );
  }
}

// Trip dates card
class TripDatesCard extends StatelessWidget {
  final ThemeData theme;
  final DateTime startDate;
  final DateTime endDate;

  const TripDatesCard({
    super.key,
    required this.theme,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return Card(
      elevation: 2,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trip Dates',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.flight_takeoff, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(dateFormat.format(startDate)),
                const Spacer(),
                Icon(Icons.flight_land, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(dateFormat.format(endDate)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Trip description card
class TripDescriptionCard extends StatelessWidget {
  final ThemeData theme;
  final String description;

  const TripDescriptionCard({
    super.key,
    required this.theme,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About this trip',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description.isNotEmpty ? description : 'No description provided.',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

// Day selector for itinerary
class ItineraryDaySelector extends StatelessWidget {
  final int totalDays;
  final int selectedDay;
  final ValueChanged<int> onDaySelected;

  const ItineraryDaySelector({
    super.key,
    required this.totalDays,
    required this.selectedDay,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: totalDays,
        itemBuilder: (context, index) {
          final day = index + 1;
          final isSelected = selectedDay == day;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text('Day $day'),
              onSelected: (selected) {
                if (selected) {
                  onDaySelected(day);
                }
              },
            ),
          );
        },
      ),
    );
  }
}

// Itinerary items list
class ItineraryItemsList extends StatelessWidget {
  final ThemeData theme;
  final String tripId;
  final int selectedDay;

  const ItineraryItemsList({
    super.key,
    required this.theme,
    required this.tripId,
    required this.selectedDay,
  });

  IconData _getActivityIcon(String activity) {
    final activityLower = activity.toLowerCase();
    if (activityLower.contains('flight') || activityLower.contains('fly')) {
      return Icons.flight;
    } else if (activityLower.contains('hotel') ||
        activityLower.contains('accommodation') ||
        activityLower.contains('stay')) {
      return Icons.hotel;
    } else if (activityLower.contains('restaurant') ||
        activityLower.contains('dining') ||
        activityLower.contains('eat') ||
        activityLower.contains('food')) {
      return Icons.restaurant;
    } else if (activityLower.contains('activity') ||
        activityLower.contains('tour') ||
        activityLower.contains('visit')) {
      return Icons.local_activity;
    } else if (activityLower.contains('transport') ||
        activityLower.contains('car') ||
        activityLower.contains('drive')) {
      return Icons.directions_car;
    }
    return Icons.event;
  }

  @override
  Widget build(BuildContext context) {
    final itineraryRepo = ItineraryRepository();

    return StreamBuilder<List<ItineraryItem>>(
      stream: itineraryRepo.getDayItineraryItems(tripId, selectedDay),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        final items = snapshot.data ?? [];

        if (items.isEmpty) {
          return SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Card(
                elevation: 1,
                shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'No activities planned for Day $selectedDay',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final item = items[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 2,
                shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      _getActivityIcon(item.activity),
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    item.activity,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.description?.isNotEmpty ?? false)
                        Text(item.description!),
                      Text(
                        '🕐 ${item.time}',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (item.location?.isNotEmpty ?? false)
                        Text('📍 ${item.location}'),
                    ],
                  ),
                ),
              );
            }, childCount: items.length),
          ),
        );
      },
    );
  }
}
