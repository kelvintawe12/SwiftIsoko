import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:swapit_marketplace/data/core/failures.dart';
import 'package:swapit_marketplace/data/models/product.dart';
import 'package:swapit_marketplace/data/services/product_services.dart';
import 'package:swapit_marketplace/data/services/cloudinary_services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:ui';

class FakeCloudinaryService implements CloudinaryService {
  @override
  Future<Either<Failure, String>> uploadImage(File imageFile) async {
    return const Right('https://example.com/image.jpg');
  }

  @override
  Future<Either<Failure, List<String>>> uploadImages(List<File> imageFiles) async {
    if (imageFiles.length < 3) return const Left(ValidationFailure('At least 3 images are required'));
    return Right(List<String>.filled(imageFiles.length, 'https://example.com/image.jpg'));
  }

  @override
  Future<Either<Failure, String>> uploadProfileImage(File imageFile) async {
    return const Right('https://example.com/profile.jpg');
  }

  @override
  Future<Either<Failure, void>> deleteImage(String imageUrl) async {
    return const Right(null);
  }

  @override
  String getThumbnailUrl(String originalUrl, {int width = 300, int height = 300}) {
    return originalUrl;
  }

  @override
  bool isValidImageFile(File file) => true;

  @override
  bool isValidFileSize(File file, {int maxSizeInMB = 10}) => true;
}

class FakeProductService implements ProductService {
  @override
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
    final now = DateTime.now();
    final product = ProductModel(
      id: 'p-test',
      name: name,
      nameLower: name.toLowerCase(),
      searchKeywords: [name.toLowerCase()],
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
    return Right(product);
  }

  @override
  Future<Either<Failure, ProductModel>> getProductById(String productId) async {
    return const Left(NotFoundFailure('not found'));
  }

  @override
  Stream<List<ProductModel>> getProductsStream({String? category, ProductStatus? status, int limit = 20}) {
    return Stream.value(<ProductModel>[]);
  }

  @override
  Stream<List<ProductModel>> getUserProducts(String userId) {
    return Stream.value(<ProductModel>[]);
  }

  @override
  Stream<List<ProductModel>> getUserProductsNoOrder(String userId) {
    return Stream.value(<ProductModel>[]);
  }

  @override
  Future<Either<Failure, List<ProductModel>>> searchProducts({required String query, String? category, String? excludeOwnerId, int limit = 20}) async {
    return const Right(<ProductModel>[]);
  }

  @override
  Future<Either<Failure, void>> updateProduct({required String productId, required String ownerId, String? name, List<String>? imageUrls, String? category, String? description, ProductCondition? condition, ProductStatus? status, double? price}) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteProduct({required String productId, required String ownerId}) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> updateProductStatus({required String productId, required ProductStatus status}) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<ProductModel>>> getProductsByCategory({required String category, int limit = 20}) async {
    return const Right(<ProductModel>[]);
  }
}

/// Set a larger test window to avoid layout overflows in widget tests.
void configureLargeTestWindow() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  binding.window.physicalSizeTestValue = const Size(1200, 800);
  binding.window.devicePixelRatioTestValue = 1.0;
}

/// Clear any window test values set by `configureLargeTestWindow`.
void clearTestWindow() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  binding.window.clearPhysicalSizeTestValue();
  binding.window.clearDevicePixelRatioTestValue();
}
