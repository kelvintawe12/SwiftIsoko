import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swapit_marketplace/data/models/product.dart';
import 'package:swapit_marketplace/data/models/person.dart';

ProductModel makeSampleProduct({String id = 'p1', String ownerId = 'u1', String ownerName = 'Seller'}) {
  final now = DateTime.now();
  return ProductModel(
    id: id,
    name: 'Sample Product',
    nameLower: 'sample product',
    searchKeywords: ['sample', 'product'],
    imageUrls: [],
    category: 'Electronics',
    description: 'A sample product for tests',
    condition: ProductCondition.newItem,
    status: ProductStatus.active,
    price: 100.0,
    currency: 'USD',
    ownerId: ownerId,
    ownerName: ownerName,
    createdAt: now,
    updatedAt: now,
  );
}

UserModel makeSampleUser({String uid = 'u1', String name = 'Test User'}) {
  return UserModel(
    uid: uid,
    name: name,
    email: 'test@example.com',
    isEmailVerified: true,
    profileImageUrl: null,
    phoneNumber: null,
    bio: null,
    location: 'Test City',
    ratingAverage: 4.5,
    numRatings: 10,
    createdAt: DateTime.now(),
  );
}
