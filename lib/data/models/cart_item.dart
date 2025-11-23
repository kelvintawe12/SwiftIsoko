import 'package:cloud_firestore/cloud_firestore.dart';
import 'listing.dart';

class CartItem {
  final String id;
  final String cartId;
  final String productId;
  final String? productName;
  final double priceAtAdd;
  final int quantity;
  final DateTime createdAt;
  final Listing listing; // Added for compatibility with UI

  CartItem({
    required this.id,
    required this.cartId,
    required this.productId,
    this.productName,
    required this.priceAtAdd,
    this.quantity = 1,
    required this.createdAt,
    Listing? listing,
  }) : listing = listing ??
            Listing(
              id: productId,
              title: productName ?? '',
              price: priceAtAdd,
              imageUrl: '',
            );

  factory CartItem.fromMap(Map<String, dynamic> map, String id) {
    // Create a simple listing from the map data
    final listing = Listing(
      id: map['productId'] ?? '',
      title: map['productName'] ?? '',
      price: (map['priceAtAdd'] ?? 0.0).toDouble(),
      imageUrl: '',
    );

    return CartItem(
      id: id,
      cartId: map['cartId'] ?? '',
      productId: map['productId'] ?? '',
      productName: map['productName'],
      priceAtAdd: (map['priceAtAdd'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 1,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      listing: listing,
    );
  }

  /// Create a CartItem from a Listing (for adding to cart from UI)
  factory CartItem.fromListing(Listing listing,
      {int quantity = 1, String cartId = ''}) {
    return CartItem(
      id: '', // Will be set when saved
      cartId: cartId,
      productId: listing.id,
      productName: listing.title,
      priceAtAdd: listing.price,
      quantity: quantity,
      createdAt: DateTime.now(),
      listing: listing,
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
    Listing? listing,
  }) {
    return CartItem(
      id: id,
      cartId: cartId,
      productId: productId,
      productName: productName,
      priceAtAdd: priceAtAdd,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt,
      listing: listing ?? this.listing,
    );
  }
}
