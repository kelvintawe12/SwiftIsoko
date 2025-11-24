import 'product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Listing is a simplified view model for Product
/// It provides a compatibility layer for UI components
class Listing {
  final String id;
  final String title;
  final double price;
  final String imageUrl;
  final int views; // Optional reference to full product

  Listing({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    this.views = 0,
  });

  /// Create a Listing from a Product
  factory Listing.fromProduct(ProductModel product) {
    return Listing(
      id: product.id,
      title: product.name,
      price: product.price,
      imageUrl: product.imageUrls.isNotEmpty ? product.imageUrls[0] : '',
      // product: product, // Removed to avoid circular dependency if ProductModel also references Listing
    );
  }

  /// Convert back to Product if available
  ProductModel? toProduct() => null; // Placeholder, as product is no longer stored directly

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Listing && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Product Model
class ProductModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String ownerId;
  final List<String> imageUrls;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int views;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.ownerId,
    this.imageUrls = const [],
    required this.createdAt,
    required this.updatedAt,
    this.views = 0,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      category: data['category'] ?? '',
      ownerId: data['ownerId'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      views: data['views'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'ownerId': ownerId,
      'imageUrls': imageUrls,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'views': views,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        category,
        ownerId,
        imageUrls,
        createdAt,
        updatedAt,
        views,
      ];
}
