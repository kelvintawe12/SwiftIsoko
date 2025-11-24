import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String uid;
  final String name;
  final String email;
  final bool isEmailVerified;
  final String? phoneNumber;
  final String? profileImageUrl;
  final String? bio;
  final String? location;
  final double ratingAverage;
  final int numRatings;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.isEmailVerified,
    this.phoneNumber,
    this.profileImageUrl,
    this.bio,
    this.location,
    this.ratingAverage = 0.0,
    this.numRatings = 0,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      isEmailVerified: data['isEmailVerified'] ?? false,
      phoneNumber: data['phoneNumber'],
      profileImageUrl: data['profileImageUrl'],
      bio: data['bio'],
      location: data['location'],
      ratingAverage: (data['ratingAverage'] ?? 0.0).toDouble(),
      numRatings: data['numRatings'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
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

  UserModel copyWith({
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
    return UserModel(
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

  @override
  List<Object?> get props => [
        uid,
        name,
        email,
        isEmailVerified,
        phoneNumber,
        profileImageUrl,
        bio,
        location,
        ratingAverage,
        numRatings,
        createdAt,
      ];
}
