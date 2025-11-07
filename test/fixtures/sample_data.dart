/// Test fixtures for Flutter app testing.
/// Contains sample data for Trips, Itineraries, Bookings, etc.

import 'package:trip_wizards/models/trip.dart';
import 'package:trip_wizards/models/itinerary_item.dart';
import 'package:trip_wizards/models/booking.dart';
import 'package:trip_wizards/models/community_trip.dart';
import 'package:trip_wizards/models/badge.dart';
import 'package:trip_wizards/models/billing.dart';

/// Sample user IDs for testing
class TestUsers {
  static const String user1 = 'test_user_alice_123';
  static const String user2 = 'test_user_bob_456';
  static const String user3 = 'test_user_charlie_789';
  static const String enterpriseUser = 'test_enterprise_user_001';
}

/// Get a sample Trip for testing
Trip getSampleTrip({String? tripId, String? userId}) {
  final now = DateTime.now();
  return Trip(
    id: tripId ?? 'trip_001',
    title: 'Tokyo Adventure 2024',
    destination: 'Tokyo, Japan',
    description:
        'An exciting trip to explore Tokyo\'s culture, cuisine, and technology',
    startDate: now.add(const Duration(days: 30)),
    endDate: now.add(const Duration(days: 37)),
    creatorId: userId ?? TestUsers.user1,
    collaboratorIds: [userId ?? TestUsers.user1, TestUsers.user2],
    createdAt: now.subtract(const Duration(days: 15)),
    updatedAt: now,
    budget: 5000.0,
    currency: 'USD',
    tags: ['cultural', 'food', 'technology'],
    visibility: 'private',
  );
}

/// Get sample ItineraryItems for testing
List<ItineraryItem> getSampleItineraryItems({String? tripId}) {
  final now = DateTime.now();
  final startDate = now.add(const Duration(days: 30));

  return [
    ItineraryItem(
      id: 'itinerary_001',
      tripId: tripId ?? 'trip_001',
      title: 'Arrival at Narita Airport',
      description: 'Arrival and check-in at hotel',
      date: startDate,
      startTime: '14:00',
      endTime: '18:00',
      location: 'Narita International Airport',
      type: 'transportation',
      notes: 'Don\'t forget to get JR Pass at airport',
      createdAt: now.subtract(const Duration(days: 10)),
      updatedAt: now,
    ),
    ItineraryItem(
      id: 'itinerary_002',
      tripId: tripId ?? 'trip_001',
      title: 'Visit Senso-ji Temple',
      description: 'Explore Tokyo\'s oldest and most famous temple',
      date: startDate.add(const Duration(days: 1)),
      startTime: '09:00',
      endTime: '12:00',
      location: 'Senso-ji Temple, Asakusa',
      type: 'activity',
      notes: 'Best to visit early to avoid crowds',
      createdAt: now.subtract(const Duration(days: 9)),
      updatedAt: now,
    ),
    ItineraryItem(
      id: 'itinerary_003',
      tripId: tripId ?? 'trip_001',
      title: 'Sushi Dinner at Sukiyabashi Jiro',
      description: 'World-famous sushi restaurant',
      date: startDate.add(const Duration(days: 2)),
      startTime: '19:00',
      endTime: '21:00',
      location: 'Ginza, Tokyo',
      type: 'dining',
      notes: 'Reservation confirmed, arrive 10 minutes early',
      createdAt: now.subtract(const Duration(days: 8)),
      updatedAt: now,
    ),
    ItineraryItem(
      id: 'itinerary_004',
      tripId: tripId ?? 'trip_001',
      title: 'TeamLab Borderless Digital Art Museum',
      description: 'Immersive digital art experience',
      date: startDate.add(const Duration(days: 3)),
      startTime: '14:00',
      endTime: '17:00',
      location: 'Odaiba, Tokyo',
      type: 'activity',
      notes: 'Pre-purchased tickets, wear comfortable shoes',
      createdAt: now.subtract(const Duration(days: 7)),
      updatedAt: now,
    ),
  ];
}

/// Get sample Bookings for testing
List<Booking> getSampleBookings({String? tripId, String? userId}) {
  final now = DateTime.now();
  final startDate = now.add(const Duration(days: 30));

  return [
    Booking(
      id: 'booking_001',
      userId: userId ?? TestUsers.user1,
      tripId: tripId ?? 'trip_001',
      itineraryItemId: 'itinerary_001',
      type: 'flight',
      provider: 'United Airlines',
      confirmationNumber: 'UA123456',
      title: 'Flight to Tokyo',
      description: 'United Airlines UA881 - SFO to NRT',
      startDate: startDate,
      endDate: startDate.add(const Duration(days: 1)),
      cost: 1200.0,
      currency: 'USD',
      status: 'confirmed',
      bookingUrl: 'https://www.united.com/booking/UA123456',
      notes: 'Seat 12A, meal preference: vegetarian',
      createdAt: now.subtract(const Duration(days: 20)),
      updatedAt: now,
    ),
    Booking(
      id: 'booking_002',
      userId: userId ?? TestUsers.user1,
      tripId: tripId ?? 'trip_001',
      type: 'accommodation',
      provider: 'Booking.com',
      confirmationNumber: 'BK789012',
      title: 'Hotel Gracery Shinjuku',
      description: '7 nights, Standard Double Room',
      startDate: startDate,
      endDate: startDate.add(const Duration(days: 7)),
      cost: 980.0,
      currency: 'USD',
      status: 'confirmed',
      bookingUrl: 'https://www.booking.com/hotel/jp/gracery-shinjuku.html',
      notes: 'Free cancellation until 48 hours before check-in',
      createdAt: now.subtract(const Duration(days: 18)),
      updatedAt: now,
    ),
    Booking(
      id: 'booking_003',
      userId: userId ?? TestUsers.user1,
      tripId: tripId ?? 'trip_001',
      itineraryItemId: 'itinerary_003',
      type: 'activity',
      provider: 'Viator',
      confirmationNumber: 'VTR345678',
      title: 'Sushi Making Class',
      description: '3-hour hands-on sushi making experience',
      startDate: startDate.add(const Duration(days: 4)),
      endDate: startDate.add(const Duration(days: 4)),
      cost: 120.0,
      currency: 'USD',
      status: 'confirmed',
      bookingUrl:
          'https://www.viator.com/tours/Tokyo/Sushi-Making-Class/d334-345678',
      notes: 'Meet at Tsukiji Market, bring ID',
      createdAt: now.subtract(const Duration(days: 12)),
      updatedAt: now,
    ),
  ];
}

/// Get a sample CommunityTrip for testing
CommunityTrip getSampleCommunityTrip({String? tripId}) {
  final now = DateTime.now();

  return CommunityTrip(
    id: tripId ?? 'community_trip_001',
    originalTripId: 'trip_001',
    authorId: TestUsers.user1,
    authorName: 'Anonymous Traveler',
    title: 'Tokyo Adventure 2024',
    description:
        'An exciting trip to explore Tokyo\'s culture, cuisine, and technology',
    destination: 'Tokyo, Japan',
    startDate: now.add(const Duration(days: 30)),
    endDate: now.add(const Duration(days: 37)),
    likes: 42,
    likedBy: [TestUsers.user2, TestUsers.user3],
    comments: [
      Comment(
        id: 'comment_001',
        userId: TestUsers.user2,
        userName: 'Bob T.',
        text: 'Great itinerary! I\'m planning a similar trip next year.',
        timestamp: now.subtract(const Duration(days: 2)),
      ),
      Comment(
        id: 'comment_002',
        userId: TestUsers.user3,
        userName: 'Charlie W.',
        text: 'How did you book the TeamLab tickets? They\'re always sold out!',
        timestamp: now.subtract(const Duration(days: 1)),
      ),
    ],
    publishedAt: now.subtract(const Duration(days: 5)),
    updatedAt: now,
  );
}

/// Get sample Badges for testing
List<Badge> getSampleBadges() {
  return [
    Badge(
      id: 'badge_001',
      name: 'First Trip',
      description: 'Created your first trip',
      iconUrl: 'https://example.com/badges/first_trip.png',
      rarity: 'common',
      points: 10,
    ),
    Badge(
      id: 'badge_002',
      name: 'Globetrotter',
      description: 'Visited 10 different countries',
      iconUrl: 'https://example.com/badges/globetrotter.png',
      rarity: 'rare',
      points: 50,
    ),
    Badge(
      id: 'badge_003',
      name: 'Community Star',
      description: 'Published trip received 100+ likes',
      iconUrl: 'https://example.com/badges/community_star.png',
      rarity: 'epic',
      points: 100,
    ),
  ];
}

/// Get sample UserCredits for testing
UserCredits getSampleUserCredits({String? userId}) {
  final now = DateTime.now();

  return UserCredits(
    userId: userId ?? TestUsers.user1,
    remainingCredits: 85,
    totalCredits: 100,
    subscriptionPlan: 'pro',
    lastRefill: now.subtract(const Duration(days: 15)),
    nextRefill: now.add(const Duration(days: 15)),
    updatedAt: now,
  );
}

/// Get sample BillingRecords for testing
List<BillingRecord> getSampleBillingRecords({String? userId}) {
  final now = DateTime.now();

  return [
    BillingRecord(
      id: 'billing_001',
      userId: userId ?? TestUsers.user1,
      type: 'subscription',
      plan: 'pro',
      amount: 9.99,
      currency: 'USD',
      status: 'succeeded',
      stripePaymentIntentId: 'pi_test_123456789',
      timestamp: now.subtract(const Duration(days: 30)),
    ),
    BillingRecord(
      id: 'billing_002',
      userId: userId ?? TestUsers.user1,
      type: 'credit_purchase',
      plan: 'credit_pack_100',
      amount: 19.99,
      currency: 'USD',
      status: 'succeeded',
      stripePaymentIntentId: 'pi_test_987654321',
      timestamp: now.subtract(const Duration(days: 15)),
    ),
  ];
}
