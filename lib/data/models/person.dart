import 'package:cloud_firestore/cloud_firestore.dart';

class Person {
  final String uid;
  final String name;
  final String email;
  final bool isEmailVerified;
  final String? phoneNumber;
  final String? profileImageUrl;
  final String? bio;
  final String location;
  final double ratingAverage;
  final int numRatings;
  final DateTime createdAt;

  Person({
    required this.uid,
    required this.name,
    required this.email,
    required this.isEmailVerified,
    this.phoneNumber,
    this.profileImageUrl,
    this.bio,
    required this.location,
    this.ratingAverage = 0.0,
    this.numRatings = 0,
    required this.createdAt,
  });

  factory Person.fromMap(Map<String, dynamic> map, String uid) {
    return Person(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      isEmailVerified: map['isEmailVerified'] ?? false,
      phoneNumber: map['phoneNumber'],
      profileImageUrl: map['profileImageUrl'],
      bio: map['bio'],
      location: map['location'] ?? '',
      ratingAverage: (map['ratingAverage'] ?? 0.0).toDouble(),
      numRatings: map['numRatings'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'isEmailVerified': isEmailVerified,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
      'location': location,
      'ratingAverage': ratingAverage,
      'numRatings': numRatings,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Person copyWith({
    String? name,
    String? email,
    bool? isEmailVerified,
    String? phoneNumber,
    String? profileImageUrl,
    String? bio,
    String? location,
    double? ratingAverage,
    int? numRatings,
  }) {
    return Person(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      ratingAverage: ratingAverage ?? this.ratingAverage,
      numRatings: numRatings ?? this.numRatings,
      createdAt: createdAt,
    );
  }
}
