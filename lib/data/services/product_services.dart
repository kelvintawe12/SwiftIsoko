import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swapit_marketplace/data/models/product.dart';
import 'package:uuid/uuid.dart';
import '../core/failures.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Create product
  Future<Either<Failure, ProductModel>> createProduct({
    required String name,
    required List<String> imageUrls,
    required String category,
    required String description,
    required ProductCondition condition,
    required double price,
    required String currency,
    required String ownerId,
    required String ownerName,
  }) async {
    try {
      // Validate image URLs
      if (imageUrls.length < 3) {
        return const Left(
          ValidationFailure('At least 3 images are required'),
        );
      }

      if (price <= 0) {
        return const Left(ValidationFailure('Price must be greater than 0'));
      }

      final productId = _uuid.v4();
      final now = DateTime.now();

      final product = ProductModel(
        id: productId,
        name: name,
        nameLower: name.toLowerCase(),
        searchKeywords: _generateSearchKeywords(name),
        imageUrls: imageUrls,
        category: category,
        description: description,
        condition: condition,
        status: ProductStatus.active,
        price: price,
        currency: currency,
        ownerId: ownerId,
        ownerName: ownerName,
        createdAt: now,
        updatedAt: now,
      );

      await _firestore
          .collection('products')
          .doc(productId)
          .set(product.toFirestore());

      return Right(product);
    } catch (e) {
      return Left(ServerFailure('Failed to create product: ${e.toString()}'));
    }
  }

  // Get product by ID
  Future<Either<Failure, ProductModel>> getProductById(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();

      if (!doc.exists) {
        return const Left(NotFoundFailure('Product not found'));
      }

      return Right(ProductModel.fromFirestore(doc));
    } catch (e) {
      return Left(ServerFailure('Failed to get product: ${e.toString()}'));
    }
  }

  // Get products stream
  Stream<List<ProductModel>> getProductsStream({
    String? category,
    ProductStatus? status,
    int limit = 20,
  }) {
    Query query = _firestore.collection('products');

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }

    return query.orderBy('nameLower').limit(limit).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList());
  }

  // Get user's products
  Stream<List<ProductModel>> getUserProducts(String userId) {
    return _firestore
        .collection('products')
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromFirestore(doc))
            .toList());
  }

  // Search products
  Future<Either<Failure, List<ProductModel>>> searchProducts({
    required String query,
    String? category,
    String? excludeOwnerId,
    int limit = 20,
  }) async {
    try {
      final queryLower = query.toLowerCase();

      Query firestoreQuery = _firestore.collection('products');

      if (category != null) {
        firestoreQuery = firestoreQuery.where('category', isEqualTo: category);
      }

      firestoreQuery = firestoreQuery
          .where('nameLower', isGreaterThanOrEqualTo: queryLower)
          .where('nameLower', isLessThanOrEqualTo: '$queryLower\uf8ff')
          .where('status', isEqualTo: ProductStatus.active.name);

      if (excludeOwnerId != null) {
        firestoreQuery =
            firestoreQuery.where('ownerId', isNotEqualTo: excludeOwnerId);
      }

      final snapshot = await firestoreQuery.limit(limit).get();

      final products =
          snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList();

      return Right(products);
    } catch (e) {
      return Left(ServerFailure('Failed to search products: ${e.toString()}'));
    }
  }

  // Update product
  Future<Either<Failure, void>> updateProduct({
    required String productId,
    required String ownerId,
    String? name,
    List<String>? imageUrls,
    String? category,
    String? description,
    ProductCondition? condition,
    ProductStatus? status,
    double? price,
  }) async {
    try {
      // Verify ownership
      final productDoc =
          await _firestore.collection('products').doc(productId).get();

      if (!productDoc.exists) {
        return const Left(NotFoundFailure('Product not found'));
      }

      final product = ProductModel.fromFirestore(productDoc);

      if (product.ownerId != ownerId) {
        return const Left(PermissionFailure('You do not own this product'));
      }

      final updates = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (name != null) {
        updates['name'] = name;
        updates['nameLower'] = name.toLowerCase();
        updates['searchKeywords'] = _generateSearchKeywords(name);
      }

      if (imageUrls != null) {
        if (imageUrls.length < 3) {
          return const Left(
            ValidationFailure('At least 3 images are required'),
          );
        }
        updates['imageUrls'] = imageUrls;
      }

      if (category != null) updates['category'] = category;
      if (description != null) updates['description'] = description;
      if (condition != null) updates['condition'] = condition.name;
      if (status != null) updates['status'] = status.name;
      if (price != null) {
        if (price <= 0) {
          return const Left(ValidationFailure('Price must be greater than 0'));
        }
        updates['price'] = price;
      }

      await _firestore.collection('products').doc(productId).update(updates);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to update product: ${e.toString()}'));
    }
  }

  // Delete product
  Future<Either<Failure, void>> deleteProduct({
    required String productId,
    required String ownerId,
  }) async {
    try {
      // Verify ownership
      final productDoc =
          await _firestore.collection('products').doc(productId).get();

      if (!productDoc.exists) {
        return const Left(NotFoundFailure('Product not found'));
      }

      final product = ProductModel.fromFirestore(productDoc);

      if (product.ownerId != ownerId) {
        return const Left(PermissionFailure('You do not own this product'));
      }

      await _firestore.collection('products').doc(productId).delete();

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete product: ${e.toString()}'));
    }
  }

  // Update product status
  Future<Either<Failure, void>> updateProductStatus({
    required String productId,
    required ProductStatus status,
  }) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'status': status.name,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to update status: ${e.toString()}'));
    }
  }

  // Get products by category
  Future<Either<Failure, List<ProductModel>>> getProductsByCategory({
    required String category,
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('category', isEqualTo: category)
          .where('status', isEqualTo: ProductStatus.active.name)
          .orderBy('nameLower')
          .limit(limit)
          .get();

      final products =
          snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList();

      return Right(products);
    } catch (e) {
      return Left(ServerFailure('Failed to get products: ${e.toString()}'));
    }
  }

  // Generate search keywords (simple tokenization)
  List<String> _generateSearchKeywords(String name) {
    final nameLower = name.toLowerCase();
    final words = nameLower.split(RegExp(r'\s+'));
    final keywords = <String>{};

    // Add full name
    keywords.add(nameLower);

    // Add individual words
    keywords.addAll(words);

    // Add prefixes for autocomplete (min 2 chars)
    for (final word in words) {
      for (int i = 2; i <= word.length; i++) {
        keywords.add(word.substring(0, i));
      }
    }

    return keywords.toList();
  }
}
