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

import 'package:equatable/equatable.dart';

enum ProductCondition { newItem, likeNew, used, damaged }

enum ProductStatus { active, incart, sold, hidden }

extension ProductConditionName on ProductCondition {
  String get name {
    switch (this) {
      case ProductCondition.newItem:
        return 'newItem';
      case ProductCondition.likeNew:
        return 'likeNew';
      case ProductCondition.used:
        return 'used';
      case ProductCondition.damaged:
        return 'damaged';
    }
  }
}

extension ProductStatusName on ProductStatus {
  String get name {
    switch (this) {
      case ProductStatus.active:
        return 'active';
      case ProductStatus.incart:
        return 'incart';
      case ProductStatus.sold:
        return 'sold';
      case ProductStatus.hidden:
        return 'hidden';
    }
  }
}

class ProductModel extends Equatable {
  final String id;
  final String name;
  final String nameLower;
  final List<String> searchKeywords;
  final List<String> imageUrls;
  final String category;
  final String description;
  final ProductCondition condition;
  final ProductStatus status;
  final double price;
  final String currency;
  final String ownerId;
  final String? ownerName;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductModel({
    required this.id,
    required this.name,
    required this.nameLower,
    required this.searchKeywords,
    required this.imageUrls,
    required this.category,
    required this.description,
    required this.condition,
    required this.status,
    required this.price,
    required this.currency,
    required this.ownerId,
    this.ownerName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      nameLower: data['nameLower'] ?? '',
      searchKeywords: List<String>.from(data['searchKeywords'] ?? []),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      condition: _parseCondition(data['condition']),
      status: _parseStatus(data['status']),
      price: (data['price'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'RWF',
      ownerId: data['ownerId'] ?? '',
      ownerName: data['ownerName'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'nameLower': nameLower,
      'searchKeywords': searchKeywords,
      'imageUrls': imageUrls,
      'category': category,
      'description': description,
      'condition': condition.name,
      'status': status.name,
      'price': price,
      'currency': currency,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static ProductCondition _parseCondition(String? value) {
    switch (value) {
      case 'newItem':
        return ProductCondition.newItem;
      case 'likeNew':
        return ProductCondition.likeNew;
      case 'used':
        return ProductCondition.used;
      case 'damaged':
        return ProductCondition.damaged;
      default:
        return ProductCondition.used;
    }
  }

  static ProductStatus _parseStatus(String? value) {
    switch (value) {
      case 'active':
        return ProductStatus.active;
      case 'incart':
        return ProductStatus.incart;
      case 'sold':
        return ProductStatus.sold;
      case 'hidden':
        return ProductStatus.hidden;
      default:
        return ProductStatus.active;
    }
  }

  ProductModel copyWith({
    String? name,
    List<String>? imageUrls,
    String? category,
    String? description,
    ProductCondition? condition,
    ProductStatus? status,
    double? price,
    String? currency,
  }) {
    return ProductModel(
      id: id,
      name: name ?? this.name,
      nameLower: name?.toLowerCase() ?? nameLower,
      searchKeywords: searchKeywords,
      imageUrls: imageUrls ?? this.imageUrls,
      category: category ?? this.category,
      description: description ?? this.description,
      condition: condition ?? this.condition,
      status: status ?? this.status,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      ownerId: ownerId,
      ownerName: ownerName,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        nameLower,
        searchKeywords,
        imageUrls,
        category,
        description,
        condition,
        status,
        price,
        currency,
        ownerId,
        ownerName,
        createdAt,
        updatedAt,
      ];
}
