import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityTrip {
  final String id;
  final String originalTripId;
  final String authorId;
  final String authorName;
  final String title;
  final String description;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final int likes;
  final List<String> likedBy;
  final List<Comment> comments;
  final DateTime publishedAt;

  CommunityTrip({
    required this.id,
    required this.originalTripId,
    required this.authorId,
    required this.authorName,
    required this.title,
    required this.description,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.likes,
    required this.likedBy,
    required this.comments,
    required this.publishedAt,
  });

  factory CommunityTrip.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommunityTrip(
      id: doc.id,
      originalTripId: data['originalTripId'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      destination: data['destination'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      likes: data['likes'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
      comments:
          (data['comments'] as List<dynamic>?)
              ?.map((c) => Comment.fromMap(c as Map<String, dynamic>))
              .toList() ??
          [],
      publishedAt: (data['publishedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'originalTripId': originalTripId,
      'authorId': authorId,
      'authorName': authorName,
      'title': title,
      'description': description,
      'destination': destination,
      'startDate': startDate,
      'endDate': endDate,
      'likes': likes,
      'likedBy': likedBy,
      'comments': comments.map((c) => c.toMap()).toList(),
      'publishedAt': publishedAt,
    };
  }
}

class Comment {
  final String id;
  final String userId;
  final String userName;
  final String text;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    required this.createdAt,
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      text: map['text'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'text': text,
      'createdAt': createdAt,
    };
  }
}
