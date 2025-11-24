import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Cart {
  final String id;
  final String userId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Cart({
    required this.id,
    required this.userId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Cart.fromMap(Map<String, dynamic> map, String id) {
    return Cart(
      id: id,
      userId: map['userId'] ?? '',
      status: map['status'] ?? 'Available',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Cart copyWith({
    String? status,
    DateTime? updatedAt,
  }) {
    return Cart(
      id: id,
      userId: userId,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

// Cart Model
enum CartStatus { open, checkedOut, abandoned }

class CartModel extends Equatable {
  final String id;
  final String userId;
  final CartStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CartModel({
    required this.id,
    required this.userId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CartModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CartModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      status: _parseCartStatus(data['status']),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static CartStatus _parseCartStatus(String? value) {
    switch (value) {
      case 'open':
        return CartStatus.open;
      case 'checkedOut':
        return CartStatus.checkedOut;
      case 'abandoned':
        return CartStatus.abandoned;
      default:
        return CartStatus.open;
    }
  }

  @override
  List<Object?> get props => [id, userId, status, createdAt, updatedAt];
}
