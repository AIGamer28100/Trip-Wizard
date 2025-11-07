import 'package:cloud_firestore/cloud_firestore.dart';

class Trip {
  final String id;
  final String title;
  final String description;
  final String? communityTripId;
  final String creatorId;
  final List<String> memberIds;
  final DateTime startDate;
  final DateTime endDate;
  final String? destination;
  final DateTime createdAt;
  final DateTime updatedAt;

  Trip({
    required this.id,
    required this.title,
    required this.description,
    this.communityTripId,
    required this.creatorId,
    required this.memberIds,
    required this.startDate,
    required this.endDate,
    this.destination,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Trip.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Document data is null');
    }

    return Trip(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      communityTripId: data['communityTripId'] as String?,
      creatorId: data['creatorId'] as String? ?? '',
      memberIds: data['memberIds'] != null
          ? List<String>.from(data['memberIds'] as List<dynamic>)
          : [],
      startDate: data['startDate'] is Timestamp
          ? (data['startDate'] as Timestamp).toDate()
          : DateTime.now(),
      endDate: data['endDate'] is Timestamp
          ? (data['endDate'] as Timestamp).toDate()
          : DateTime.now(),
      destination: data['destination'] as String?,
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'communityTripId': communityTripId,
      'creatorId': creatorId,
      'memberIds': memberIds,
      'startDate': startDate,
      'endDate': endDate,
      'destination': destination,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
