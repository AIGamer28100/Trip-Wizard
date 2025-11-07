"""
Sample data and fixtures for testing Trip Wizards app.
Contains realistic mock data for Trips, Itineraries, Bookings, Community Trips, etc.
"""

from datetime import datetime, timedelta
from typing import Dict, List, Any

# Sample user IDs for testing
SAMPLE_USER_IDS = {
    "user1": "test_user_alice_123",
    "user2": "test_user_bob_456",
    "user3": "test_user_charlie_789",
    "enterprise_user": "test_enterprise_user_001",
}

# Sample organization for enterprise testing
SAMPLE_ORGANIZATION = {
    "id": "org_001",
    "name": "Acme Travel Corp",
    "adminIds": [SAMPLE_USER_IDS["enterprise_user"]],
    "memberIds": [
        SAMPLE_USER_IDS["enterprise_user"],
        SAMPLE_USER_IDS["user1"],
    ],
    "billingPlan": "enterprise",
    "createdAt": (datetime.utcnow() - timedelta(days=365)).isoformat(),
    "updatedAt": datetime.utcnow().isoformat(),
}


def get_sample_trip(trip_id: str = "trip_001", user_id: str = None) -> Dict[str, Any]:
    """Generate a sample trip document"""
    if user_id is None:
        user_id = SAMPLE_USER_IDS["user1"]

    return {
        "id": trip_id,
        "title": "Tokyo Adventure 2024",
        "destination": "Tokyo, Japan",
        "description": "An exciting trip to explore Tokyo's culture, cuisine, and technology",
        "startDate": (datetime.utcnow() + timedelta(days=30)).isoformat(),
        "endDate": (datetime.utcnow() + timedelta(days=37)).isoformat(),
        "creatorId": user_id,
        "collaboratorIds": [user_id, SAMPLE_USER_IDS["user2"]],
        "createdAt": (datetime.utcnow() - timedelta(days=15)).isoformat(),
        "updatedAt": datetime.utcnow().isoformat(),
        "budget": 5000.0,
        "currency": "USD",
        "tags": ["cultural", "food", "technology"],
        "visibility": "private",
    }


def get_sample_itinerary_items(trip_id: str = "trip_001") -> List[Dict[str, Any]]:
    """Generate sample itinerary items for a trip"""
    start_date = datetime.utcnow() + timedelta(days=30)

    return [
        {
            "id": "itinerary_001",
            "tripId": trip_id,
            "title": "Arrival at Narita Airport",
            "description": "Arrival and check-in at hotel",
            "date": start_date.isoformat(),
            "startTime": "14:00",
            "endTime": "18:00",
            "location": "Narita International Airport",
            "type": "transportation",
            "notes": "Don't forget to get JR Pass at airport",
            "createdAt": (datetime.utcnow() - timedelta(days=10)).isoformat(),
            "updatedAt": datetime.utcnow().isoformat(),
        },
        {
            "id": "itinerary_002",
            "tripId": trip_id,
            "title": "Visit Senso-ji Temple",
            "description": "Explore Tokyo's oldest and most famous temple",
            "date": (start_date + timedelta(days=1)).isoformat(),
            "startTime": "09:00",
            "endTime": "12:00",
            "location": "Senso-ji Temple, Asakusa",
            "type": "activity",
            "notes": "Best to visit early to avoid crowds",
            "createdAt": (datetime.utcnow() - timedelta(days=9)).isoformat(),
            "updatedAt": datetime.utcnow().isoformat(),
        },
        {
            "id": "itinerary_003",
            "tripId": trip_id,
            "title": "Sushi Dinner at Sukiyabashi Jiro",
            "description": "World-famous sushi restaurant",
            "date": (start_date + timedelta(days=2)).isoformat(),
            "startTime": "19:00",
            "endTime": "21:00",
            "location": "Ginza, Tokyo",
            "type": "dining",
            "notes": "Reservation confirmed, arrive 10 minutes early",
            "createdAt": (datetime.utcnow() - timedelta(days=8)).isoformat(),
            "updatedAt": datetime.utcnow().isoformat(),
        },
        {
            "id": "itinerary_004",
            "tripId": trip_id,
            "title": "TeamLab Borderless Digital Art Museum",
            "description": "Immersive digital art experience",
            "date": (start_date + timedelta(days=3)).isoformat(),
            "startTime": "14:00",
            "endTime": "17:00",
            "location": "Odaiba, Tokyo",
            "type": "activity",
            "notes": "Pre-purchased tickets, wear comfortable shoes",
            "createdAt": (datetime.utcnow() - timedelta(days=7)).isoformat(),
            "updatedAt": datetime.utcnow().isoformat(),
        },
    ]


def get_sample_bookings(trip_id: str = "trip_001", user_id: str = None) -> List[Dict[str, Any]]:
    """Generate sample booking documents"""
    if user_id is None:
        user_id = SAMPLE_USER_IDS["user1"]

    start_date = datetime.utcnow() + timedelta(days=30)

    return [
        {
            "id": "booking_001",
            "userId": user_id,
            "tripId": trip_id,
            "itineraryItemId": "itinerary_001",
            "type": "flight",
            "provider": "United Airlines",
            "confirmationNumber": "UA123456",
            "title": "Flight to Tokyo",
            "description": "United Airlines UA881 - SFO to NRT",
            "startDate": start_date.isoformat(),
            "endDate": (start_date + timedelta(days=1)).isoformat(),
            "cost": 1200.0,
            "currency": "USD",
            "status": "confirmed",
            "bookingUrl": "https://www.united.com/booking/UA123456",
            "notes": "Seat 12A, meal preference: vegetarian",
            "createdAt": (datetime.utcnow() - timedelta(days=20)).isoformat(),
            "updatedAt": datetime.utcnow().isoformat(),
        },
        {
            "id": "booking_002",
            "userId": user_id,
            "tripId": trip_id,
            "itineraryItemId": None,
            "type": "accommodation",
            "provider": "Booking.com",
            "confirmationNumber": "BK789012",
            "title": "Hotel Gracery Shinjuku",
            "description": "7 nights, Standard Double Room",
            "startDate": start_date.isoformat(),
            "endDate": (start_date + timedelta(days=7)).isoformat(),
            "cost": 980.0,
            "currency": "USD",
            "status": "confirmed",
            "bookingUrl": "https://www.booking.com/hotel/jp/gracery-shinjuku.html",
            "notes": "Free cancellation until 48 hours before check-in",
            "createdAt": (datetime.utcnow() - timedelta(days=18)).isoformat(),
            "updatedAt": datetime.utcnow().isoformat(),
        },
        {
            "id": "booking_003",
            "userId": user_id,
            "tripId": trip_id,
            "itineraryItemId": "itinerary_003",
            "type": "activity",
            "provider": "Viator",
            "confirmationNumber": "VTR345678",
            "title": "Sushi Making Class",
            "description": "3-hour hands-on sushi making experience",
            "startDate": (start_date + timedelta(days=4)).isoformat(),
            "endDate": (start_date + timedelta(days=4)).isoformat(),
            "cost": 120.0,
            "currency": "USD",
            "status": "confirmed",
            "bookingUrl": "https://www.viator.com/tours/Tokyo/Sushi-Making-Class/d334-345678",
            "notes": "Meet at Tsukiji Market, bring ID",
            "createdAt": (datetime.utcnow() - timedelta(days=12)).isoformat(),
            "updatedAt": datetime.utcnow().isoformat(),
        },
    ]


def get_sample_community_trip(trip_id: str = "community_trip_001") -> Dict[str, Any]:
    """Generate a sample community trip (published trip)"""
    return {
        "id": trip_id,
        "originalTripId": "trip_001",
        "authorId": SAMPLE_USER_IDS["user1"],
        "authorName": "Anonymous Traveler",
        "title": "Tokyo Adventure 2024",
        "description": "An exciting trip to explore Tokyo's culture, cuisine, and technology",
        "destination": "Tokyo, Japan",
        "startDate": (datetime.utcnow() + timedelta(days=30)).isoformat(),
        "endDate": (datetime.utcnow() + timedelta(days=37)).isoformat(),
        "likes": 42,
        "likedBy": [SAMPLE_USER_IDS["user2"], SAMPLE_USER_IDS["user3"]],
        "comments": [
            {
                "id": "comment_001",
                "userId": SAMPLE_USER_IDS["user2"],
                "userName": "Bob T.",
                "text": "Great itinerary! I'm planning a similar trip next year.",
                "timestamp": (datetime.utcnow() - timedelta(days=2)).isoformat(),
            },
            {
                "id": "comment_002",
                "userId": SAMPLE_USER_IDS["user3"],
                "userName": "Charlie W.",
                "text": "How did you book the TeamLab tickets? They're always sold out!",
                "timestamp": (datetime.utcnow() - timedelta(days=1)).isoformat(),
            },
        ],
        "publishedAt": (datetime.utcnow() - timedelta(days=5)).isoformat(),
        "updatedAt": datetime.utcnow().isoformat(),
    }


def get_sample_user_credits(user_id: str = None) -> Dict[str, Any]:
    """Generate sample user credits document"""
    if user_id is None:
        user_id = SAMPLE_USER_IDS["user1"]

    return {
        "userId": user_id,
        "remainingCredits": 85,
        "totalCredits": 100,
        "subscriptionPlan": "pro",
        "lastRefill": (datetime.utcnow() - timedelta(days=15)).isoformat(),
        "nextRefill": (datetime.utcnow() + timedelta(days=15)).isoformat(),
        "updatedAt": datetime.utcnow().isoformat(),
    }


def get_sample_badges() -> List[Dict[str, Any]]:
    """Generate sample badge definitions"""
    return [
        {
            "id": "badge_001",
            "name": "First Trip",
            "description": "Created your first trip",
            "iconUrl": "https://example.com/badges/first_trip.png",
            "rarity": "common",
            "points": 10,
        },
        {
            "id": "badge_002",
            "name": "Globetrotter",
            "description": "Visited 10 different countries",
            "iconUrl": "https://example.com/badges/globetrotter.png",
            "rarity": "rare",
            "points": 50,
        },
        {
            "id": "badge_003",
            "name": "Community Star",
            "description": "Published trip received 100+ likes",
            "iconUrl": "https://example.com/badges/community_star.png",
            "rarity": "epic",
            "points": 100,
        },
    ]


def get_sample_user_badges(user_id: str = None) -> Dict[str, Any]:
    """Generate sample user badges document"""
    if user_id is None:
        user_id = SAMPLE_USER_IDS["user1"]

    return {
        "userId": user_id,
        "badges": [
            {
                "badgeId": "badge_001",
                "earnedAt": (datetime.utcnow() - timedelta(days=30)).isoformat(),
            },
            {
                "badgeId": "badge_002",
                "earnedAt": (datetime.utcnow() - timedelta(days=10)).isoformat(),
            },
        ],
        "totalPoints": 60,
        "updatedAt": datetime.utcnow().isoformat(),
    }


def get_sample_billing_records(user_id: str = None) -> List[Dict[str, Any]]:
    """Generate sample billing records"""
    if user_id is None:
        user_id = SAMPLE_USER_IDS["user1"]

    return [
        {
            "id": "billing_001",
            "userId": user_id,
            "type": "subscription",
            "plan": "pro",
            "amount": 9.99,
            "currency": "USD",
            "status": "succeeded",
            "stripePaymentIntentId": "pi_test_123456789",
            "timestamp": (datetime.utcnow() - timedelta(days=30)).isoformat(),
        },
        {
            "id": "billing_002",
            "userId": user_id,
            "type": "credit_purchase",
            "plan": "credit_pack_100",
            "amount": 19.99,
            "currency": "USD",
            "status": "succeeded",
            "stripePaymentIntentId": "pi_test_987654321",
            "timestamp": (datetime.utcnow() - timedelta(days=15)).isoformat(),
        },
    ]


# Comprehensive fixture combining all sample data
def get_complete_test_fixture() -> Dict[str, Any]:
    """
    Get a complete test fixture with all sample data.
    Useful for seeding test databases or mock responses.
    """
    return {
        "users": SAMPLE_USER_IDS,
        "organization": SAMPLE_ORGANIZATION,
        "trips": [
            get_sample_trip("trip_001", SAMPLE_USER_IDS["user1"]),
            get_sample_trip("trip_002", SAMPLE_USER_IDS["user2"]),
        ],
        "itinerary_items": get_sample_itinerary_items("trip_001"),
        "bookings": get_sample_bookings("trip_001", SAMPLE_USER_IDS["user1"]),
        "community_trips": [get_sample_community_trip("community_trip_001")],
        "user_credits": [
            get_sample_user_credits(SAMPLE_USER_IDS["user1"]),
            get_sample_user_credits(SAMPLE_USER_IDS["user2"]),
        ],
        "badges": get_sample_badges(),
        "user_badges": [
            get_sample_user_badges(SAMPLE_USER_IDS["user1"]),
        ],
        "billing_records": get_sample_billing_records(SAMPLE_USER_IDS["user1"]),
    }
