"""
Mock responses for ADK (AI Development Kit) integration.
These fixtures simulate responses from the ADK submodule for testing purposes.
"""

from typing import Dict, List, Any

# Mock ADK AI suggestion responses
ADK_SUGGESTION_RESPONSES = {
    "restaurant": {
        "type": "restaurant_suggestion",
        "confidence": 0.92,
        "suggestions": [
            {
                "name": "The Golden Fork",
                "category": "fine_dining",
                "cuisine": "local",
                "rating": 4.7,
                "priceRange": "$$$",
                "description": "A highly rated restaurant specializing in regional dishes with a modern twist.",
                "location": {
                    "address": "123 Main Street, Downtown",
                    "coordinates": {"lat": 35.6762, "lng": 139.6503},
                },
                "why_recommended": "Based on your trip preferences for cultural experiences and local cuisine",
            },
            {
                "name": "Sakura Garden",
                "category": "casual_dining",
                "cuisine": "japanese",
                "rating": 4.5,
                "priceRange": "$$",
                "description": "Traditional Japanese restaurant with authentic dishes and beautiful garden seating.",
                "location": {
                    "address": "456 Cherry Blossom Lane",
                    "coordinates": {"lat": 35.6812, "lng": 139.7671},
                },
                "why_recommended": "Popular among locals, offers seasonal specialties",
            },
        ],
        "metadata": {
            "model": "adk-travel-concierge-v1",
            "response_time_ms": 234,
            "sources": ["google_maps", "tripadvisor", "local_db"],
        },
    },
    "activity": {
        "type": "activity_suggestion",
        "confidence": 0.88,
        "suggestions": [
            {
                "name": "Mountain Hiking Trail",
                "category": "outdoor",
                "duration_hours": 4,
                "difficulty": "moderate",
                "rating": 4.8,
                "description": "Scenic hiking trail with panoramic views of the valley. Best visited in spring or fall.",
                "location": {
                    "address": "National Park Entrance, North Gate",
                    "coordinates": {"lat": 35.3606, "lng": 138.7274},
                },
                "recommended_time": "morning",
                "why_recommended": "Matches your interest in outdoor activities and nature",
            },
            {
                "name": "Cultural History Museum",
                "category": "cultural",
                "duration_hours": 2.5,
                "rating": 4.6,
                "description": "Comprehensive museum showcasing local history, art, and cultural artifacts.",
                "location": {
                    "address": "789 Museum Boulevard",
                    "coordinates": {"lat": 35.6895, "lng": 139.6917},
                },
                "recommended_time": "afternoon",
                "why_recommended": "Excellent for cultural exploration as indicated in your trip preferences",
            },
        ],
        "metadata": {
            "model": "adk-travel-concierge-v1",
            "response_time_ms": 198,
            "sources": ["google_places", "yelp", "local_tourism_board"],
        },
    },
    "itinerary_optimization": {
        "type": "itinerary_optimization",
        "confidence": 0.95,
        "optimized_order": [
            {
                "itinerary_item_id": "itinerary_001",
                "recommended_time": "09:00",
                "reasoning": "Start early to avoid crowds at the temple",
            },
            {
                "itinerary_item_id": "itinerary_004",
                "recommended_time": "14:00",
                "reasoning": "Digital art museum is best experienced in the afternoon",
            },
            {
                "itinerary_item_id": "itinerary_003",
                "recommended_time": "19:00",
                "reasoning": "Dinner reservation already confirmed for this time",
            },
        ],
        "travel_time_estimates": [
            {
                "from": "itinerary_001",
                "to": "itinerary_004",
                "duration_minutes": 35,
                "mode": "train",
            },
            {
                "from": "itinerary_004",
                "to": "itinerary_003",
                "duration_minutes": 25,
                "mode": "train",
            },
        ],
        "notes": [
            "Consider purchasing day pass for unlimited train travel",
            "All locations are accessible via public transportation",
        ],
        "metadata": {
            "model": "adk-itinerary-optimizer-v2",
            "response_time_ms": 567,
            "sources": ["google_maps_directions", "transit_api"],
        },
    },
    "general": {
        "type": "general_suggestion",
        "confidence": 0.75,
        "suggestion": "Based on your trip details, I recommend planning your itinerary around the main attractions and considering local transportation options. Would you like specific recommendations for activities, dining, or accommodations?",
        "follow_up_questions": [
            "What type of activities are you most interested in?",
            "Do you have any dietary restrictions for restaurant recommendations?",
            "What's your preferred travel style - budget, comfort, or luxury?",
        ],
        "metadata": {
            "model": "adk-travel-concierge-v1",
            "response_time_ms": 145,
        },
    },
}


# Mock ADK chat responses for @agent mentions
ADK_CHAT_RESPONSES = {
    "weather": {
        "message": "Based on historical data, Tokyo typically has mild temperatures (18-22°C) with occasional rain in April. I recommend packing light layers and a compact umbrella.",
        "context": {
            "location": "Tokyo, Japan",
            "dates": "April 2024",
            "confidence": 0.89,
        },
        "suggested_actions": [
            "Add umbrella to packing list",
            "Consider booking covered activities as backup",
        ],
    },
    "budget": {
        "message": "Based on your $5000 budget for 7 days, here's a breakdown: Accommodation $980, Flights $1200, Food $1400 ($200/day), Activities $800, Transportation $300, Contingency $320. This leaves you comfortable room for spontaneous experiences!",
        "context": {
            "total_budget": 5000,
            "duration_days": 7,
            "confidence": 0.92,
        },
        "suggested_actions": [
            "Create budget tracking sheet",
            "Consider pre-purchasing attraction tickets for discounts",
        ],
    },
    "transportation": {
        "message": "I highly recommend getting a 7-day JR Pass ($280) for unlimited train travel. It will save you money and hassle. You can purchase it at Narita Airport upon arrival.",
        "context": {
            "destination": "Tokyo, Japan",
            "duration": "7 days",
            "confidence": 0.94,
        },
        "suggested_actions": [
            "Add JR Pass purchase to itinerary",
            "Download Tokyo Metro app for navigation",
        ],
    },
    "general_help": {
        "message": "I'm here to help with your trip planning! I can provide suggestions for restaurants, activities, optimize your itinerary, answer questions about weather, transportation, and more. Just mention @agent followed by your question!",
        "context": {
            "available_commands": [
                "restaurant suggestions",
                "activity recommendations",
                "itinerary optimization",
                "weather information",
                "transportation advice",
                "budget planning",
            ],
        },
    },
}


# Mock ADK itinerary generation response
ADK_ITINERARY_GENERATION = {
    "type": "full_itinerary",
    "confidence": 0.91,
    "itinerary": {
        "trip_title": "Tokyo Adventure 2024",
        "destination": "Tokyo, Japan",
        "days": [
            {
                "day": 1,
                "date": "2024-04-15",
                "theme": "Arrival and Traditional Tokyo",
                "items": [
                    {
                        "time": "14:00",
                        "title": "Arrival at Narita Airport",
                        "description": "Clear customs and purchase JR Pass",
                        "duration_minutes": 120,
                        "type": "transportation",
                    },
                    {
                        "time": "17:00",
                        "title": "Check-in at Hotel",
                        "description": "Hotel Gracery Shinjuku - Standard Double Room",
                        "duration_minutes": 60,
                        "type": "accommodation",
                    },
                    {
                        "time": "19:00",
                        "title": "Dinner at Local Izakaya",
                        "description": "Casual Japanese pub for your first authentic meal",
                        "duration_minutes": 120,
                        "type": "dining",
                    },
                ],
            },
            {
                "day": 2,
                "date": "2024-04-16",
                "theme": "Cultural Exploration",
                "items": [
                    {
                        "time": "09:00",
                        "title": "Visit Senso-ji Temple",
                        "description": "Tokyo's oldest and most famous Buddhist temple",
                        "duration_minutes": 180,
                        "type": "activity",
                    },
                    {
                        "time": "13:00",
                        "title": "Lunch in Asakusa",
                        "description": "Try traditional tempura or udon nearby",
                        "duration_minutes": 90,
                        "type": "dining",
                    },
                    {
                        "time": "15:00",
                        "title": "Explore Akihabara",
                        "description": "Electronics district and anime culture hub",
                        "duration_minutes": 180,
                        "type": "activity",
                    },
                ],
            },
            {
                "day": 3,
                "date": "2024-04-17",
                "theme": "Modern Tokyo and Technology",
                "items": [
                    {
                        "time": "10:00",
                        "title": "Tokyo Skytree",
                        "description": "Visit observation deck for panoramic city views",
                        "duration_minutes": 150,
                        "type": "activity",
                    },
                    {
                        "time": "14:00",
                        "title": "TeamLab Borderless",
                        "description": "Immersive digital art museum experience",
                        "duration_minutes": 180,
                        "type": "activity",
                    },
                    {
                        "time": "19:00",
                        "title": "Sushi Dinner at Ginza",
                        "description": "High-end sushi experience at Sukiyabashi Jiro",
                        "duration_minutes": 120,
                        "type": "dining",
                    },
                ],
            },
        ],
    },
    "estimated_costs": {
        "total": 4850,
        "breakdown": {
            "accommodation": 980,
            "transportation": 420,
            "food": 1800,
            "activities": 1200,
            "contingency": 450,
        },
        "currency": "USD",
    },
    "tips": [
        "Download offline maps before arrival",
        "Consider getting a local SIM card or portable WiFi",
        "Many places only accept cash - withdraw yen at 7-Eleven ATMs",
        "Learn basic Japanese phrases for better interactions",
    ],
    "metadata": {
        "model": "adk-itinerary-generator-v3",
        "response_time_ms": 1234,
        "sources": ["google_places", "tripadvisor", "japan_travel_guide"],
    },
}


# Mock ADK error responses
ADK_ERROR_RESPONSES = {
    "rate_limit": {
        "error": "rate_limit_exceeded",
        "message": "You have exceeded the rate limit for AI suggestions. Please try again in 60 seconds.",
        "retry_after_seconds": 60,
        "metadata": {
            "requests_remaining": 0,
            "limit_reset_at": "2024-01-15T10:30:00Z",
        },
    },
    "service_unavailable": {
        "error": "service_unavailable",
        "message": "The AI service is temporarily unavailable. Please try again later.",
        "metadata": {
            "estimated_recovery_time": "5 minutes",
        },
    },
    "invalid_input": {
        "error": "invalid_input",
        "message": "The provided input is invalid or incomplete. Please provide more details about your request.",
        "metadata": {
            "required_fields": ["destination", "dates"],
        },
    },
}


def get_adk_mock_response(query_type: str, error: str = None) -> Dict[str, Any]:
    """
    Get a mock ADK response based on query type.

    Args:
        query_type: Type of query - 'restaurant', 'activity', 'itinerary_optimization',
                   'general', 'weather', 'budget', 'transportation', 'itinerary_generation'
        error: Optional error type - 'rate_limit', 'service_unavailable', 'invalid_input'

    Returns:
        Mock ADK response dictionary
    """
    if error:
        return ADK_ERROR_RESPONSES.get(error, ADK_ERROR_RESPONSES["service_unavailable"])

    # Map query types to response fixtures
    if query_type in ADK_SUGGESTION_RESPONSES:
        return ADK_SUGGESTION_RESPONSES[query_type]
    elif query_type in ADK_CHAT_RESPONSES:
        return ADK_CHAT_RESPONSES[query_type]
    elif query_type == "itinerary_generation":
        return ADK_ITINERARY_GENERATION
    else:
        return ADK_SUGGESTION_RESPONSES["general"]


# Helper function to simulate ADK processing delay
def simulate_adk_delay() -> float:
    """Returns realistic processing delay in seconds for ADK responses"""
    import random
    return random.uniform(0.15, 0.8)  # 150ms to 800ms
