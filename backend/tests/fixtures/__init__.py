"""
Test fixtures package for Trip Wizards backend.

This package contains sample data and mock responses for testing:
- sample_data.py: Realistic mock data for Trips, Itineraries, Bookings, etc.
- adk_mock_responses.py: Mock responses from ADK AI service for testing

Usage:
    from tests.fixtures.sample_data import get_sample_trip, get_complete_test_fixture
    from tests.fixtures.adk_mock_responses import get_adk_mock_response

    # Get a single trip
    trip = get_sample_trip()

    # Get complete test dataset
    all_data = get_complete_test_fixture()

    # Get mock ADK response
    restaurant_suggestion = get_adk_mock_response('restaurant')
"""

from .sample_data import (
    SAMPLE_USER_IDS,
    SAMPLE_ORGANIZATION,
    get_sample_trip,
    get_sample_itinerary_items,
    get_sample_bookings,
    get_sample_community_trip,
    get_sample_user_credits,
    get_sample_badges,
    get_sample_user_badges,
    get_sample_billing_records,
    get_complete_test_fixture,
)

from .adk_mock_responses import (
    ADK_SUGGESTION_RESPONSES,
    ADK_CHAT_RESPONSES,
    ADK_ITINERARY_GENERATION,
    ADK_ERROR_RESPONSES,
    get_adk_mock_response,
    simulate_adk_delay,
)

__all__ = [
    # Sample data
    "SAMPLE_USER_IDS",
    "SAMPLE_ORGANIZATION",
    "get_sample_trip",
    "get_sample_itinerary_items",
    "get_sample_bookings",
    "get_sample_community_trip",
    "get_sample_user_credits",
    "get_sample_badges",
    "get_sample_user_badges",
    "get_sample_billing_records",
    "get_complete_test_fixture",
    # ADK mock responses
    "ADK_SUGGESTION_RESPONSES",
    "ADK_CHAT_RESPONSES",
    "ADK_ITINERARY_GENERATION",
    "ADK_ERROR_RESPONSES",
    "get_adk_mock_response",
    "simulate_adk_delay",
]
