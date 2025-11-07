import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String tripId;
  final String type; // 'hotel', 'flight', 'activity', etc.
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime? endDate;
  final double? price;
  final String? bookingReference;
  final String? itineraryItemId; // Link to itinerary item
  final Map<String, dynamic> details;
  final DateTime createdAt;
  final DateTime updatedAt;

  Booking({
    required this.id,
    required this.tripId,
    required this.type,
    required this.title,
    required this.description,
    required this.startDate,
    this.endDate,
    this.price,
    this.bookingReference,
    this.itineraryItemId,
    required this.details,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Booking.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Booking(
      id: doc.id,
      tripId: data['tripId'] ?? '',
      type: data['type'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: data['endDate'] != null
          ? (data['endDate'] as Timestamp).toDate()
          : null,
      price: data['price']?.toDouble(),
      bookingReference: data['bookingReference'],
      itineraryItemId: data['itineraryItemId'],
      details: data['details'] ?? {},
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'tripId': tripId,
      'type': type,
      'title': title,
      'description': description,
      'startDate': startDate,
      'endDate': endDate,
      'price': price,
      'bookingReference': bookingReference,
      'itineraryItemId': itineraryItemId,
      'details': details,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
