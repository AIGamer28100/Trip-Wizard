# Data Model: Trip Wizards

## Firestore Collections

### users

- **Purpose**: User profiles and preferences
- **Fields**: name (string), email (string), preferences (map), createdAt (timestamp)

**Example**:

```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "preferences": {"currency": "USD", "notifications": true},
  "createdAt": "2025-11-06T00:00:00Z"
}
```

### trips

- **Purpose**: Trip metadata and participants
- **Fields**: title (string), destination (string), dates (map), participants (array), createdBy (string)

**Example**:

```json
{
  "title": "Paris Trip",
  "destination": "Paris",
  "dates": {"start": "2025-12-01", "end": "2025-12-05"},
  "participants": ["user1", "user2"],
  "createdBy": "user1"
}
```

### itinerary_items

- **Purpose**: Activities and bookings in itinerary
- **Fields**: tripId (string), day (int), time (string), activity (string), aiSuggested (bool)

**Example**:

```json
{
  "tripId": "trip1",
  "day": 1,
  "time": "10:00",
  "activity": "Eiffel Tower Visit",
  "aiSuggested": true
}
```

### chat_messages

- **Purpose**: Trip chat messages
- **Fields**: tripId (string), sender (string), text (string), timestamp (timestamp)

**Example**:

```json
{
  "tripId": "trip1",
  "sender": "user1",
  "text": "@agent suggest lunch spots",
  "timestamp": 1636200000
}
```

### bookings

- **Purpose**: Confirmed bookings
- **Fields**: userId (string), type (string), provider (string), status (string), cost (float)

**Example**:

```json
{
  "userId": "user1",
  "type": "flight",
  "provider": "AirlineX",
  "status": "confirmed",
  "cost": 500.0
}
```

### community_trips

- **Purpose**: Published trips for sharing
- **Fields**: originalTripId (string), author (string), title (string), likes (int)

**Example**:

```json
{
  "originalTripId": "trip1",
  "author": "user1",
  "title": "Amazing Paris Adventure",
  "likes": 42
}
```

### orgs

- **Purpose**: Enterprise organizations
- **Fields**: name (string), admin (string), members (array)

**Example**:

```json
{
  "name": "Acme Corp",
  "admin": "user1",
  "members": ["user1", "user2"]
}
```

### billing

- **Purpose**: Invoices and credits
- **Fields**: userId (string), amount (float), period (string), status (string)

**Example**:

```json
{
  "userId": "user1",
  "amount": 9.99,
  "period": "monthly",
  "status": "paid"
}
```

### badges

- **Purpose**: User achievements
- **Fields**: userId (string), type (string), earnedAt (timestamp)

**Example**:

```json
{
  "userId": "user1",
  "type": "first_trip",
  "earnedAt": "2025-11-06T00:00:00Z"
}
```

## Validation Rules

- Users: email unique, preferences optional
- Trips: dates valid range, participants non-empty
- Itinerary: time valid format, activity non-empty
- Bookings: cost positive, status enum
- Orgs: admin in members

## Relationships

- Trips → users (participants)
- Itinerary → trips
- Chat → trips
- Bookings → users
- Community → trips
- Billing → users/orgs
- Badges → users
