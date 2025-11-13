import 'package:cloud_firestore/cloud_firestore.dart';

class PersonRating {
  final String id;
  final String ratedUserId;
  final String? ratedUserName;
  final String raterUserId;
  final String? raterUserName;
  final int rating;
  final String? review;
  final DateTime createdAt;

  PersonRating({
    required this.id,
    required this.ratedUserId,
    this.ratedUserName,
    required this.raterUserId,
    this.raterUserName,
    required this.rating,
    this.review,
    required this.createdAt,
  }) : assert(rating >= 1 && rating <= 5, 'Rating must be between 1 and 5');

  factory PersonRating.fromMap(Map<String, dynamic> map, String id) {
    return PersonRating(
      id: id,
      ratedUserId: map['ratedUserId'] ?? '',
      ratedUserName: map['ratedUserName'],
      raterUserId: map['raterUserId'] ?? '',
      raterUserName: map['raterUserName'],
      rating: map['rating'] ?? 0,
      review: map['review'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ratedUserId': ratedUserId,
      'ratedUserName': ratedUserName,
      'raterUserId': raterUserId,
      'raterUserName': raterUserName,
      'rating': rating,
      'review': review,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
