import 'package:cloud_firestore/cloud_firestore.dart';
import 'product.dart';

class CartItem {
  final String id;
  final String cartId;
  final String productId;
  final String? productName;
  final double priceAtAdd;
  final int quantity;
  final DateTime createdAt;
  final Product? product;

  CartItem({
    required this.id,
    required this.cartId,
    required this.productId,
    this.productName,
    required this.priceAtAdd,
    this.quantity = 1,
    required this.createdAt,
    this.product,
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
    Product? product,
  }) {
    return CartItem(
      id: id,
      cartId: cartId,
      productId: productId,
      productName: productName,
      priceAtAdd: priceAtAdd,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt,
      product: product ?? this.product,
    );
  }
}
