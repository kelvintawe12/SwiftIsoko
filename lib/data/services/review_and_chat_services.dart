import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swapit_marketplace/data/models/chat.dart';
import 'package:swapit_marketplace/data/models/message.dart';
import 'package:swapit_marketplace/data/models/person_rating_model.dart';
import 'package:swapit_marketplace/data/models/reviews.dart';
import 'package:uuid/uuid.dart';
import '../core/failures.dart';

// Review Service
class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Add product review
  Future<Either<Failure, ReviewModel>> addProductReview({
    required String productId,
    required String userId,
    required String userName,
    required int rating,
    String? message,
  }) async {
    try {
      if (rating < 1 || rating > 5) {
        return const Left(ValidationFailure('Rating must be between 1 and 5'));
      }

      // Check if user already reviewed this product
      final existingReviews = await _firestore
          .collection('reviews')
          .where('productId', isEqualTo: productId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (existingReviews.docs.isNotEmpty) {
        return const Left(
          ValidationFailure('You have already reviewed this product'),
        );
      }

      final reviewId = _uuid.v4();
      final review = ReviewModel(
        id: reviewId,
        productId: productId,
        userId: userId,
        userName: userName,
        rating: rating,
        message: message,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('reviews')
          .doc(reviewId)
          .set(review.toFirestore());

      // Update product rating (this should ideally be in Cloud Function)
      await _updateProductRating(productId);

      return Right(review);
    } catch (e) {
      return Left(ServerFailure('Failed to add review: ${e.toString()}'));
    }
  }

  // Get product reviews
  Stream<List<ReviewModel>> getProductReviews(String productId) {
    return _firestore
        .collection('reviews')
        .where('productId', isEqualTo: productId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReviewModel.fromFirestore(doc))
            .toList());
  }

  // Update product rating aggregate
  Future<void> _updateProductRating(String productId) async {
    final reviewsSnapshot = await _firestore
        .collection('reviews')
        .where('productId', isEqualTo: productId)
        .get();

    if (reviewsSnapshot.docs.isEmpty) return;

    int totalRating = 0;
    for (final doc in reviewsSnapshot.docs) {
      final review = ReviewModel.fromFirestore(doc);
      totalRating += review.rating;
    }

    final average = totalRating / reviewsSnapshot.docs.length;

    await _firestore.collection('products').doc(productId).update({
      'ratingAverage': average,
      'numRatings': reviewsSnapshot.docs.length,
    });
  }

  // Add user rating
  Future<Either<Failure, UserRatingModel>> addUserRating({
    required String ratedUserId,
    required String ratedUserName,
    required String raterUserId,
    required String raterUserName,
    required int rating,
    String? review,
  }) async {
    try {
      if (rating < 1 || rating > 5) {
        return const Left(ValidationFailure('Rating must be between 1 and 5'));
      }

      if (ratedUserId == raterUserId) {
        return const Left(ValidationFailure('Cannot rate yourself'));
      }

      // Check if user already rated this user
      final existingRatings = await _firestore
          .collection('userRatings')
          .where('ratedUserId', isEqualTo: ratedUserId)
          .where('raterUserId', isEqualTo: raterUserId)
          .limit(1)
          .get();

      if (existingRatings.docs.isNotEmpty) {
        return const Left(
          ValidationFailure('You have already rated this user'),
        );
      }

      final ratingId = _uuid.v4();
      final userRating = UserRatingModel(
        id: ratingId,
        ratedUserId: ratedUserId,
        ratedUserName: ratedUserName,
        raterUserId: raterUserId,
        raterUserName: raterUserName,
        rating: rating,
        review: review,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('userRatings')
          .doc(ratingId)
          .set(userRating.toFirestore());

      // Update user rating (this should ideally be in Cloud Function)
      await _updateUserRating(ratedUserId);

      return Right(userRating);
    } catch (e) {
      return Left(ServerFailure('Failed to add user rating: ${e.toString()}'));
    }
  }

  // Get user ratings
  Stream<List<UserRatingModel>> getUserRatings(String userId) {
    return _firestore
        .collection('userRatings')
        .where('ratedUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserRatingModel.fromFirestore(doc))
            .toList());
  }

  // Update user rating aggregate
  Future<void> _updateUserRating(String userId) async {
    final ratingsSnapshot = await _firestore
        .collection('userRatings')
        .where('ratedUserId', isEqualTo: userId)
        .get();

    if (ratingsSnapshot.docs.isEmpty) return;

    int totalRating = 0;
    for (final doc in ratingsSnapshot.docs) {
      final rating = UserRatingModel.fromFirestore(doc);
      totalRating += rating.rating;
    }

    final average = totalRating / ratingsSnapshot.docs.length;

    await _firestore.collection('users').doc(userId).update({
      'ratingAverage': average,
      'numRatings': ratingsSnapshot.docs.length,
    });
  }
}

// Chat Service
class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Get or create chat between two users
  Future<Either<Failure, ChatModel>> getOrCreateChat(
    String userId1,
    String userId2,
  ) async {
    try {
      if (userId1 == userId2) {
        return const Left(ValidationFailure('Cannot chat with yourself'));
      }

      // Sort user IDs for consistent ordering
      final participants = [userId1, userId2]..sort();

      // Check for existing chat
      final snapshot = await _firestore
          .collection('chats')
          .where('participants', isEqualTo: participants)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return Right(ChatModel.fromFirestore(snapshot.docs.first));
      }

      // Create new chat
      final chatId = _uuid.v4();
      final chat = ChatModel(
        id: chatId,
        participants: participants,
        lastMessageAt: DateTime.now(),
      );

      await _firestore.collection('chats').doc(chatId).set(chat.toFirestore());

      return Right(chat);
    } catch (e) {
      return Left(ServerFailure('Failed to get/create chat: ${e.toString()}'));
    }
  }

  // Get user chats
  Stream<List<ChatModel>> getUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ChatModel.fromFirestore(doc)).toList());
  }

  // Get chat messages
  Stream<List<MessageModel>> getChatMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromFirestore(doc))
            .toList());
  }

  // Send message
  Future<Either<Failure, MessageModel>> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    try {
      if (text.trim().isEmpty) {
        return const Left(ValidationFailure('Message cannot be empty'));
      }

      final messageId = _uuid.v4();
      final now = DateTime.now();

      final message = MessageModel(
        id: messageId,
        chatId: chatId,
        senderId: senderId,
        text: text.trim(),
        createdAt: now,
      );

      final batch = _firestore.batch();

      // Add message
      batch.set(
        _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .doc(messageId),
        message.toFirestore(),
      );

      // Update chat lastMessageAt
      batch.update(
        _firestore.collection('chats').doc(chatId),
        {'lastMessageAt': Timestamp.fromDate(now)},
      );

      await batch.commit();

      return Right(message);
    } catch (e) {
      return Left(ServerFailure('Failed to send message: ${e.toString()}'));
    }
  }

  // Delete message
  Future<Either<Failure, void>> deleteMessage({
    required String chatId,
    required String messageId,
    required String senderId,
  }) async {
    try {
      final messageDoc = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .get();

      if (!messageDoc.exists) {
        return const Left(NotFoundFailure('Message not found'));
      }

      final message = MessageModel.fromFirestore(messageDoc);

      if (message.senderId != senderId) {
        return const Left(
          PermissionFailure('You can only delete your own messages'),
        );
      }

      await messageDoc.reference.delete();

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete message: ${e.toString()}'));
    }
  }

  // Mark messages as read (optional feature for future)
  Future<Either<Failure, void>> markMessagesAsRead({
    required String chatId,
    required String userId,
  }) async {
    try {
      // This would require adding an 'isRead' field to messages
      // For now, we'll just return success
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to mark as read: ${e.toString()}'));
    }
  }
}
