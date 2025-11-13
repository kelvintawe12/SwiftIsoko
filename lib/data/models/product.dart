import 'package:cloud_firestore/cloud_firestore.dart';

// enum ProductCondition { newCondition, likeNew, used, damaged }
// enum ProductStatus { active, inCart, sold, hidden }

// enum ProductCategory {
//   electronics,
//   fashion,
//   furniture,
//   accessories,
//   sports,
//   books,
//   toys,
//   beauty,
//   others
// }

class Product {
  final String id;
  final String name;
  final List<String> imageUrls;
  final String category;
  final String description;
  final String condition;
  final String status;
  final double price;
  final String currency;
  final String ownerId;
  final String? ownerName;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.imageUrls,
    required this.category,
    required this.description,
    required this.condition,
    required this.status,
    required this.price,
    this.currency = 'RWF',
    required this.ownerId,
    this.ownerName,
    required this.createdAt,
    required this.updatedAt,
  }) : assert(imageUrls.length >= 2, 'A product must have at least 2 images');

  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      category: map['category'],
      description: map['description'] ?? '',
      condition: map['condition'],
      status: map['status'],
      price: (map['price'] ?? 0.0).toDouble(),
      currency: map['currency'] ?? 'RWF',
      ownerId: map['ownerId'] ?? '',
      ownerName: map['ownerName'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrls': imageUrls,
      'category': category,
      'description': description,
      'condition': condition,
      'status': status,
      'price': price,
      'currency': currency,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Product copyWith({
    String? name,
    List<String>? imageUrls,
    String? category,
    String? description,
    String? condition,
    String? status,
    double? price,
    String? currency,
    String? ownerName,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      imageUrls: imageUrls ?? this.imageUrls,
      category: category ?? this.category,
      description: description ?? this.description,
      condition: condition ?? this.condition,
      status: status ?? this.status,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      ownerId: ownerId,
      ownerName: ownerName ?? this.ownerName,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
