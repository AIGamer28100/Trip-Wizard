import 'package:cloud_firestore/cloud_firestore.dart';

class ItineraryItem {
  final String id;
  final String tripId;
  final int day;
  final String time;
  final String activity;
  final String? description;
  final String? location;
  final String? placeId; // Google Place ID for location validation
  final double? cost;
  final bool aiSuggested;
  final DateTime createdAt;
  final DateTime updatedAt;

  // New fields for travel planning
  final String? stayLocation; // Where the user is staying
  final String? stayPlaceId; // Place ID for stay location
  final String? travelMethod; // driving, walking, transit, etc.
  final int? travelDuration; // in seconds
  final String? travelDistance; // formatted distance (e.g., "5.2 km")

  ItineraryItem({
    required this.id,
    required this.tripId,
    required this.day,
    required this.time,
    required this.activity,
    this.description,
    this.location,
    this.placeId,
    this.cost,
    this.aiSuggested = false,
    required this.createdAt,
    required this.updatedAt,
    this.stayLocation,
    this.stayPlaceId,
    this.travelMethod,
    this.travelDuration,
    this.travelDistance,
  });

  factory ItineraryItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ItineraryItem(
      id: doc.id,
      tripId: data['tripId'] ?? '',
      day: data['day'] ?? 1,
      time: data['time'] ?? '',
      activity: data['activity'] ?? '',
      description: data['description'],
      location: data['location'],
      placeId: data['placeId'],
      cost: data['cost']?.toDouble(),
      aiSuggested: data['aiSuggested'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      stayLocation: data['stayLocation'],
      stayPlaceId: data['stayPlaceId'],
      travelMethod: data['travelMethod'],
      travelDuration: data['travelDuration'],
      travelDistance: data['travelDistance'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'tripId': tripId,
      'day': day,
      'time': time,
      'activity': activity,
      'description': description,
      'location': location,
      'placeId': placeId,
      'cost': cost,
      'aiSuggested': aiSuggested,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'stayLocation': stayLocation,
      'stayPlaceId': stayPlaceId,
      'travelMethod': travelMethod,
      'travelDuration': travelDuration,
      'travelDistance': travelDistance,
    };
  }

  ItineraryItem copyWith({
    String? id,
    String? tripId,
    int? day,
    String? time,
    String? activity,
    String? description,
    String? location,
    String? placeId,
    double? cost,
    bool? aiSuggested,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? stayLocation,
    String? stayPlaceId,
    String? travelMethod,
    int? travelDuration,
    String? travelDistance,
  }) {
    return ItineraryItem(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      day: day ?? this.day,
      time: time ?? this.time,
      activity: activity ?? this.activity,
      description: description ?? this.description,
      location: location ?? this.location,
      placeId: placeId ?? this.placeId,
      cost: cost ?? this.cost,
      aiSuggested: aiSuggested ?? this.aiSuggested,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      stayLocation: stayLocation ?? this.stayLocation,
      stayPlaceId: stayPlaceId ?? this.stayPlaceId,
      travelMethod: travelMethod ?? this.travelMethod,
      travelDuration: travelDuration ?? this.travelDuration,
      travelDistance: travelDistance ?? this.travelDistance,
    );
  }
}
