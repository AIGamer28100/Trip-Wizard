import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../repositories/trip_repository.dart';
import '../models/trip.dart';
import 'create_trip_screen.dart';
import 'chat_screen.dart';
import 'booking/manual_booking_screen.dart';
import 'community_screen.dart';
import 'community_trip_detail_screen.dart';
import 'achievements_screen.dart';
import 'subscription_screen.dart';
import 'profile_screen.dart';
import '../widgets/credit_meter.dart';
import 'itinerary_screen.dart';
import 'trip_detail_screen.dart';
import '../l10n/app_localizations.dart';
// import 'accommodation_search_screen.dart'; // Removed - not using search screen in bottom nav

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _showTripContextMenu(BuildContext context, Trip trip) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('View Itinerary'),
              onTap: () {
                Navigator.pop(context);
                _handleTripAction(context, trip, 'itinerary');
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_box),
              title: const Text('Add Booking'),
              onTap: () {
                Navigator.pop(context);
                _handleTripAction(context, trip, 'booking');
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Chat'),
              onTap: () {
                Navigator.pop(context);
                _handleTripAction(context, trip, 'chat');
              },
            ),
            ListTile(
              leading: Icon(
                trip.communityTripId != null && trip.communityTripId!.isNotEmpty
                    ? Icons.link
                    : Icons.cloud_upload,
              ),
              title: Text(
                trip.communityTripId != null && trip.communityTripId!.isNotEmpty
                    ? 'View Community Post'
                    : 'Publish to Community',
              ),
              onTap: () {
                Navigator.pop(context);
                _handleTripAction(
                  context,
                  trip,
                  trip.communityTripId != null &&
                          trip.communityTripId!.isNotEmpty
                      ? 'view_community'
                      : 'publish',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleTripAction(
    BuildContext context,
    Trip trip,
    String action,
  ) async {
    switch (action) {
      case 'itinerary':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ItineraryScreen(trip: trip)),
        );
        break;
      case 'booking':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ManualBookingScreen(tripId: trip.id),
          ),
        );
        break;
      case 'chat':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ChatScreen(tripId: trip.id)),
        );
        break;
      case 'view_community':
        if (trip.communityTripId != null && trip.communityTripId!.isNotEmpty) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CommunityTripDetailScreen(
                communityTripId: trip.communityTripId!,
              ),
            ),
          );
        }
        break;
      case 'publish':
        try {
          final tripRepository = Provider.of<TripRepository>(
            context,
            listen: false,
          );
          final communityId = await tripRepository.publishTrip(trip.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Trip published to community!')),
            );
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    CommunityTripDetailScreen(communityTripId: communityId),
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to publish trip: $e')),
            );
          }
        }
        break;
    }
  }

  // Publishing handled inline in the list tile so we can navigate after publish.

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).currentUser;
    final tripRepository = Provider.of<TripRepository>(context, listen: false);
    final theme = Theme.of(context);

    Widget body;
    switch (_selectedIndex) {
      case 0:
        body = _buildTripsView(user, tripRepository, theme);
        break;
      case 1:
        body = const CommunityScreen();
        break;
      case 2:
        body = const AchievementsScreen();
        break;
      case 3:
        body = const SubscriptionScreen();
        break;
      default:
        body = _buildTripsView(user, tripRepository, theme);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? AppLocalizations.of(context).homeTrips
              : _selectedIndex == 1
              ? 'Community'
              : _selectedIndex == 2
              ? 'Achievements'
              : 'Subscription',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Profile Avatar Button
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 18,
                backgroundColor: theme.colorScheme.primaryContainer,
                backgroundImage:
                    user?.photoURL != null && user!.photoURL!.isNotEmpty
                    ? NetworkImage(user.photoURL!)
                    : null,
                child: user?.photoURL == null || user!.photoURL!.isEmpty
                    ? Text(
                        _getInitials(user?.displayName ?? 'U'),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.card_travel_outlined),
            selectedIcon: Icon(Icons.card_travel),
            label: 'Trips',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Community',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'Achievements',
          ),
          NavigationDestination(
            icon: Icon(Icons.subscriptions_outlined),
            selectedIcon: Icon(Icons.subscriptions),
            label: 'Subscription',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreateTripScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('New Trip'),
            )
          : null,
    );
  }

  String _getInitials(String name) {
    return name
        .split(' ')
        .map((e) => e.isNotEmpty ? e[0] : '')
        .take(2)
        .join()
        .toUpperCase();
  }

  Widget _buildTripsView(user, TripRepository tripRepository, ThemeData theme) {
    return Column(
      children: [
        const CreditMeter(),
        Expanded(
          child: StreamBuilder<List<Trip>>(
            stream: tripRepository.getUserTrips(user?.uid ?? ''),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final trips = snapshot.data ?? [];

              if (trips.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.explore_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context).homeEmptyTitle,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context).homeEmptySubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const CreateTripScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: Text(
                          AppLocalizations.of(context).homeCreateFirstTrip,
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: trips.length,
                itemBuilder: (context, index) {
                  final trip = trips[index];
                  return _TripCard(
                    trip: trip,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TripDetailScreen(trip: trip),
                        ),
                      );
                    },
                    onLongPress: () {
                      _showTripContextMenu(context, trip);
                    },
                    onMenuSelected: (value) =>
                        _handleTripAction(context, trip, value),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// Wanderlog-style Trip Card
class _TripCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Function(String) onMenuSelected;

  const _TripCard({
    required this.trip,
    required this.onTap,
    required this.onLongPress,
    required this.onMenuSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPublished =
        trip.communityTripId != null && trip.communityTripId!.isNotEmpty;
    final daysDiff = trip.endDate.difference(trip.startDate).inDays + 1;

    final cardColor = theme.colorScheme.surface;
    final cardBorderColor = theme.colorScheme.outlineVariant;
    return Card(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: cardBorderColor.withOpacity(0.4), width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trip Header Image/Gradient
            Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primaryContainer.withOpacity(0.85),
                    theme.colorScheme.secondaryContainer.withOpacity(0.85),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Destination icon
                  Center(
                    child: Icon(
                      Icons.travel_explore,
                      size: 60,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  // Published badge
                  if (isPublished)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: _StatusBadge(
                        label: 'Published',
                        icon: Icons.public,
                        color: Colors.green,
                        theme: theme,
                      ),
                    ),
                  // Menu button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: PopupMenuButton<String>(
                      color: theme.colorScheme.surfaceContainerHighest,
                      elevation: 3,
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.28),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24, width: 1),
                        ),
                        child: const Icon(
                          Icons.more_vert,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      onSelected: onMenuSelected,
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'itinerary',
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, size: 20),
                              SizedBox(width: 12),
                              Text('View Itinerary'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'booking',
                          child: Row(
                            children: [
                              Icon(Icons.add_box, size: 20),
                              SizedBox(width: 12),
                              Text('Add Booking'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'chat',
                          child: Row(
                            children: [
                              Icon(Icons.chat, size: 20),
                              SizedBox(width: 12),
                              Text('Chat'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: isPublished ? 'view_community' : 'publish',
                          child: Row(
                            children: [
                              Icon(
                                isPublished ? Icons.link : Icons.cloud_upload,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                isPublished
                                    ? 'View Community Post'
                                    : 'Publish to Community',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Trip Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (trip.destination != null)
                    Row(
                      children: [
                        Icon(Icons.place, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            trip.destination!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[700],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${trip.startDate.toString().split(' ')[0]} - ${trip.endDate.toString().split(' ')[0]}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$daysDiff ${daysDiff == 1 ? 'day' : 'days'}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final ThemeData theme;

  const _StatusBadge({
    required this.label,
    required this.icon,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color.withOpacity(
      theme.brightness == Brightness.dark ? 0.25 : 0.12,
    );
    final border = color.withOpacity(
      theme.brightness == Brightness.dark ? 0.6 : 0.8,
    );
    final fg = color.withOpacity(
      theme.brightness == Brightness.dark ? 0.9 : 0.9,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
