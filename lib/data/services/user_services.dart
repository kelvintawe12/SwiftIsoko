import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/failures.dart';
import '../models/person.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get user by ID
  Future<Either<Failure, UserModel>> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        return const Left(NotFoundFailure('User not found'));
      }

      return Right(UserModel.fromFirestore(doc));
    } catch (e) {
      return Left(ServerFailure('Failed to get user: ${e.toString()}'));
    }
  }

  // Get user stream
  Stream<UserModel?> getUserStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  // Update user profile
  Future<Either<Failure, void>> updateUserProfile({
    required String uid,
    String? name,
    String? phoneNumber,
    String? profileImageUrl,
    String? bio,
    String? location,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (name != null) updates['name'] = name;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
      if (profileImageUrl != null) updates['profileImageUrl'] = profileImageUrl;
      if (bio != null) updates['bio'] = bio;
      if (location != null) updates['location'] = location;

      if (updates.isEmpty) {
        return const Right(null);
      }

      await _firestore.collection('users').doc(uid).update(updates);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to update profile: ${e.toString()}'));
    }
  }

  // Update user rating
  Future<Either<Failure, void>> updateUserRating({
    required String uid,
    required double newRating,
  }) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        return const Left(NotFoundFailure('User not found'));
      }

      final user = UserModel.fromFirestore(userDoc);
      final currentTotal = user.ratingAverage * user.numRatings;
      final newNumRatings = user.numRatings + 1;
      final newAverage = (currentTotal + newRating) / newNumRatings;

      await _firestore.collection('users').doc(uid).update({
        'ratingAverage': newAverage,
        'numRatings': newNumRatings,
      });

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to update rating: ${e.toString()}'));
    }
  }

  // Search users by name
  Future<Either<Failure, List<UserModel>>> searchUsers(String query) async {
    try {
      final queryLower = query.toLowerCase();

      final snapshot = await _firestore
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: queryLower)
          .where('name', isLessThanOrEqualTo: '$queryLower\uf8ff')
          .limit(20)
          .get();

      final users =
          snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();

      return Right(users);
    } catch (e) {
      return Left(ServerFailure('Failed to search users: ${e.toString()}'));
    }
  }

  // Delete user account
  Future<Either<Failure, void>> deleteUserAccount(String uid) async {
    try {
      // Delete user document
      await _firestore.collection('users').doc(uid).delete();

      // Note: Firebase Auth user should be deleted separately
      // This is typically done after deleting Firestore data

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete account: ${e.toString()}'));
    }
  }

  // Get saved product ids from user document
  Future<Either<Failure, List<String>>> getSavedProductIds(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) return const Right([]);

      final data = doc.data() as Map<String, dynamic>;
      final ids = List<String>.from(data['savedProductIds'] ?? []);
      return Right(ids);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch saved ids: ${e.toString()}'));
    }
  }

  // Add a product id to the user's savedProductIds array
  Future<Either<Failure, void>> addSavedProductId(String uid, String productId) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'savedProductIds': FieldValue.arrayUnion([productId])
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to add saved id: ${e.toString()}'));
    }
  }

  // Remove a product id from the user's savedProductIds array
  Future<Either<Failure, void>> removeSavedProductId(String uid, String productId) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'savedProductIds': FieldValue.arrayRemove([productId])
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to remove saved id: ${e.toString()}'));
    }
  }
}
