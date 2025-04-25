import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  String? id;
  String userId;
  String comment;
  double rating;
  DateTime timestamp;

  Review({
    this.id,
    required this.userId,
    required this.comment,
    required this.rating,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String?,
      userId: json['userId'] as String,
      comment: json['comment'] as String,
      rating: (json['rating'] as num).toDouble(),
      timestamp: json['timestamp'] != null
          ? (json['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'comment': comment,
      'rating': rating,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}