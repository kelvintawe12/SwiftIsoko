import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/failures.dart';

/// Favorites stored as a subcollection under each user: users/{uid}/favorites
/// Each doc may have fields: productId: string, createdAt: Timestamp
class FavoriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream of productIds saved in the favorites subcollection
  Stream<List<String>> getFavoritesProductIdsStream(String uid) {
    final col = _firestore.collection('users').doc(uid).collection('favorites');
    return col.snapshots().map((snap) =>
        snap.docs.map((doc) => (doc.data()['productId'] as String?) ?? '').where((id) => id.isNotEmpty).toList());
  }

  /// Add a favorite (create or overwrite doc with id = productId)
  Future<Either<Failure, void>> addFavorite(String uid, String productId) async {
    try {
      final docRef = _firestore.collection('users').doc(uid).collection('favorites').doc(productId);
      await docRef.set({
        'productId': productId,
        'createdAt': Timestamp.now(),
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to add favorite: ${e.toString()}'));
    }
  }

  /// Remove a favorite
  Future<Either<Failure, void>> removeFavorite(String uid, String productId) async {
    try {
      final docRef = _firestore.collection('users').doc(uid).collection('favorites').doc(productId);
      await docRef.delete();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to remove favorite: ${e.toString()}'));
    }
  }
}
