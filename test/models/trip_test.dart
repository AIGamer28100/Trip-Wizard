import 'package:flutter_test/flutter_test.dart';
import 'package:trip_wizards/models/trip.dart';

void main() {
  group('Trip Model', () {
    test('should create Trip from Firestore data', () {
      final mockData = {
        'title': 'Test Trip',
        'description': 'A test trip',
        'creatorId': 'user1',
        'memberIds': ['user1', 'user2'],
        'startDate': DateTime(2024, 1, 1),
        'endDate': DateTime(2024, 1, 5),
        'destination': 'Test City',
        'createdAt': DateTime(2024, 1, 1),
        'updatedAt': DateTime(2024, 1, 1),
      };

      final trip = Trip(
        id: 'trip1',
        title: mockData['title'] as String,
        description: mockData['description'] as String,
        creatorId: mockData['creatorId'] as String,
        memberIds: mockData['memberIds'] as List<String>,
        startDate: mockData['startDate'] as DateTime,
        endDate: mockData['endDate'] as DateTime,
        destination: mockData['destination'] as String,
        createdAt: mockData['createdAt'] as DateTime,
        updatedAt: mockData['updatedAt'] as DateTime,
      );

      expect(trip.id, 'trip1');
      expect(trip.title, 'Test Trip');
      expect(trip.memberIds.length, 2);
    });
  });
}
