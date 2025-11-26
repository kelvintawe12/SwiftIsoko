import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swapit_marketplace/presentation/home/add_product_screen.dart';
import 'package:swapit_marketplace/data/models/person.dart';
import 'package:swapit_marketplace/data/models/product.dart';
import 'package:swapit_marketplace/data/providers/providers.dart';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:swapit_marketplace/data/providers/state_notifiers.dart';
import 'package:swapit_marketplace/data/services/product_services.dart';
import 'package:swapit_marketplace/data/services/cloudinary_services.dart';
import 'package:swapit_marketplace/data/models/product.dart';
import 'package:swapit_marketplace/data/core/failures.dart';

// Simple fake services to avoid initializing Firebase/Cloudinary during tests
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

void main() {
  group('AddProductScreen Widget Tests', () {

    testWidgets('AddProductScreen displays all required form fields',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith((ref) => Stream.value(null)),
            currentUserIdProvider.overrideWith((ref) => null),
            productServiceProvider.overrideWithValue(FakeProductService()),
            cloudinaryServiceProvider.overrideWithValue(FakeCloudinaryService()),
          ],
          child: const MaterialApp(home: AddProductScreen()),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Sell Product'), findsOneWidget);
      expect(find.text('Product Name'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Condition'), findsOneWidget);
      expect(find.text('Price'), findsOneWidget);
      expect(find.text('Currency'), findsOneWidget);
    });

    testWidgets('AddProductScreen displays image picker buttons',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith((ref) => Stream.value(null)),
            currentUserIdProvider.overrideWith((ref) => null),
          ],
          child: const MaterialApp(home: AddProductScreen()),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Choose from Gallery'), findsOneWidget);
      expect(find.text('Take Photo'), findsOneWidget);
      expect(find.byIcon(Icons.photo_library), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    });

    testWidgets(
        'AddProductScreen shows validation message when form is incomplete',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith((ref) => Stream.value(UserModel(
                  uid: 'test-uid',
                  name: 'Test User',
                  email: 'test@example.com',
                  isEmailVerified: true,
                  createdAt: DateTime.now(),
                ))),
            currentUserIdProvider.overrideWith((ref) => 'test-uid'),
          ],
          child: const MaterialApp(home: AddProductScreen()),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Find and tap the Create Product button
      final createButton =
          find.widgetWithText(ElevatedButton, 'Create Product');
      expect(createButton, findsOneWidget);
      await tester.tap(createButton);
      await tester.pumpAndSettle();

      // Assert - Should show error for missing images
      expect(find.text('Please select at least 3 images'), findsOneWidget);
    });

    testWidgets(
        'AddProductScreen displays category dropdown with all categories',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith((ref) => Stream.value(null)),
            currentUserIdProvider.overrideWith((ref) => null),
          ],
          child: const MaterialApp(home: AddProductScreen()),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Find and tap the category dropdown
      final categoryDropdown = find.text('Category').last;
      await tester.tap(categoryDropdown);
      await tester.pumpAndSettle();

      // Assert - Check if categories appear
      expect(find.text('Fashion'), findsWidgets);
      expect(find.text('Electronics'), findsWidgets);
      expect(find.text('Furniture'), findsWidgets);
    });

    testWidgets('AddProductScreen displays condition dropdown options',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith((ref) => Stream.value(null)),
            currentUserIdProvider.overrideWith((ref) => null),
          ],
          child: const MaterialApp(home: AddProductScreen()),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Find the condition dropdown
      final conditionDropdown = find.text('Condition').last;
      await tester.tap(conditionDropdown);
      await tester.pumpAndSettle();

      // Assert - Check if condition options appear
      expect(find.text('New'), findsWidgets);
      expect(find.text('Like New'), findsWidgets);
      expect(find.text('Used'), findsWidgets);
      expect(find.text('Damaged'), findsWidgets);
    });
  });
}
