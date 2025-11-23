import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class CartItem {
  final String id;
  final String cartId;
  final String productId;
  final String? productName;
  final double priceAtAdd;
  final int quantity;
  final DateTime createdAt;

  CartItem({
    required this.id,
    required this.cartId,
    required this.productId,
    this.productName,
    required this.priceAtAdd,
    this.quantity = 1,
    required this.createdAt,
  });

  factory CartItem.fromMap(Map<String, dynamic> map, String id) {
    return CartItem(
      id: id,
      cartId: map['cartId'] ?? '',
      productId: map['productId'] ?? '',
      productName: map['productName'],
      priceAtAdd: (map['priceAtAdd'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 1,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cartId': cartId,
      'productId': productId,
      'productName': productName,
      'priceAtAdd': priceAtAdd,
      'quantity': quantity,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  double get totalPrice => priceAtAdd * quantity;

  CartItem copyWith({
    int? quantity,
  }) {
    return CartItem(
      id: id,
      cartId: cartId,
      productId: productId,
      productName: productName,
      priceAtAdd: priceAtAdd,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt,
    );
  }
}

// Cart Item Model
class CartItemModel extends Equatable {
  final String id;
  final String cartId;
  final String productId;
  final String? productName;
  final double priceAtAdd;
  final int quantity;
  final DateTime createdAt;

  const CartItemModel({
    required this.id,
    required this.cartId,
    required this.productId,
    this.productName,
    required this.priceAtAdd,
    required this.quantity,
    required this.createdAt,
  });

  factory CartItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CartItemModel(
      id: doc.id,
      cartId: data['cartId'] ?? '',
      productId: data['productId'] ?? '',
      productName: data['productName'],
      priceAtAdd: (data['priceAtAdd'] ?? 0.0).toDouble(),
      quantity: data['quantity'] ?? 1,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'cartId': cartId,
      'productId': productId,
      'productName': productName,
      'priceAtAdd': priceAtAdd,
      'quantity': quantity,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  @override
  List<Object?> get props =>
      [id, cartId, productId, productName, priceAtAdd, quantity, createdAt];
}
