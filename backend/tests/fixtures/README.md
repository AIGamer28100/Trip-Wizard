# Test Fixtures

This directory contains sample data and mock responses for testing the Trip Wizards backend.

## Files

### `sample_data.py`
Contains realistic mock data for all major entities in the Trip Wizards app:
- **Users**: Sample user IDs for testing different user scenarios
- **Organizations**: Enterprise organization data for multi-user testing
- **Trips**: Complete trip documents with metadata
- **Itinerary Items**: Sample activities, dining, transportation entries
- **Bookings**: Flight, hotel, and activity bookings with confirmation details
- **Community Trips**: Published trips with likes and comments
- **User Credits**: Billing credit balances and subscription plans
- **Badges**: Gamification badge definitions and user achievements
- **Billing Records**: Payment history and transaction records

### `adk_mock_responses.py`
Mock responses from the ADK (AI Development Kit) service:
- **Suggestion Responses**: Restaurant, activity, and general suggestions
- **Chat Responses**: @agent mention responses for weather, budget, transportation
- **Itinerary Generation**: Full multi-day itinerary with optimization
- **Error Responses**: Rate limiting, service unavailable, invalid input errors

## Usage

### Basic Usage
```python
from tests.fixtures import get_sample_trip, get_adk_mock_response

# Get a sample trip
trip = get_sample_trip()

# Get ADK restaurant suggestion
suggestion = get_adk_mock_response('restaurant')
```

### Complete Test Dataset
```python
from tests.fixtures import get_complete_test_fixture

# Get all sample data at once
all_data = get_complete_test_fixture()

# Access specific collections
trips = all_data['trips']
bookings = all_data['bookings']
community_trips = all_data['community_trips']
```

### Custom User IDs
```python
from tests.fixtures import get_sample_trip, SAMPLE_USER_IDS

# Create trip for specific user
trip = get_sample_trip(trip_id="custom_trip", user_id=SAMPLE_USER_IDS["user2"])
```

### ADK Mock Responses
```python
from tests.fixtures import get_adk_mock_response

# Different query types
restaurant_suggestion = get_adk_mock_response('restaurant')
activity_suggestion = get_adk_mock_response('activity')
itinerary_optimization = get_adk_mock_response('itinerary_optimization')

# Simulate errors
rate_limit_error = get_adk_mock_response('restaurant', error='rate_limit')
service_error = get_adk_mock_response('activity', error='service_unavailable')
```

### Simulating ADK Delays
```python
from tests.fixtures import simulate_adk_delay
import asyncio

async def test_adk_call():
    delay = simulate_adk_delay()
    await asyncio.sleep(delay)
    return get_adk_mock_response('restaurant')
```

## Testing Scenarios

### User Journey Testing
```python
from tests.fixtures import SAMPLE_USER_IDS, get_sample_trip, get_sample_bookings

# Simulate user creating trip and adding bookings
user_id = SAMPLE_USER_IDS["user1"]
trip = get_sample_trip("trip_001", user_id)
bookings = get_sample_bookings("trip_001", user_id)
```

### Enterprise Testing
```python
from tests.fixtures import SAMPLE_ORGANIZATION, SAMPLE_USER_IDS

# Test organization with multiple members
org = SAMPLE_ORGANIZATION
admin_id = org['adminIds'][0]
member_ids = org['memberIds']
```

### Community Features Testing
```python
from tests.fixtures import get_sample_community_trip

# Test published trip with engagement
community_trip = get_sample_community_trip()
likes = community_trip['likes']
comments = community_trip['comments']
```

### Billing & Credits Testing
```python
from tests.fixtures import get_sample_user_credits, get_sample_billing_records

# Test subscription and credit management
credits = get_sample_user_credits(SAMPLE_USER_IDS["user1"])
billing_history = get_sample_billing_records(SAMPLE_USER_IDS["user1"])
```

## Data Consistency

All sample data is internally consistent:
- Trip IDs match across trips, itineraries, and bookings
- User IDs are consistent across all collections
- Dates are relative to current time using `timedelta`
- Currency and amounts are realistic for the scenarios

## Extending Fixtures

To add new fixtures:

1. Add data generation function to `sample_data.py` or `adk_mock_responses.py`
2. Export the function in `__init__.py`
3. Update this README with usage examples
4. Ensure data consistency with existing fixtures

## Notes

- All timestamps use ISO 8601 format
- User IDs are prefixed with `test_` to distinguish from production data
- ADK responses include confidence scores and metadata for realistic testing
- Error responses include proper error codes and retry information
