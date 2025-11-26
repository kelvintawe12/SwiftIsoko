import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: unused_import
import 'package:mockito/mockito.dart';
import 'package:swapit_marketplace/presentation/home/home_screen.dart';
import 'package:swapit_marketplace/data/models/product.dart';
import 'package:swapit_marketplace/data/models/person.dart';
import 'package:swapit_marketplace/data/providers/providers.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    testWidgets('HomeScreen displays app title "SwiftIsoko"',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith((ref) => Stream.value(null)),
            productsStreamProvider.overrideWith((ref) => Stream.value([])),
            heroProductsProvider.overrideWith((ref) => Stream.value([])),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('SwiftIsoko'), findsOneWidget);
    });

    testWidgets('HomeScreen displays welcome message for logged-in user',
        (WidgetTester tester) async {
      // Arrange
      final testUser = UserModel(
        uid: 'test-uid',
        name: 'John Doe',
        email: 'merukelvine@gmail.com',
        isEmailVerified: true,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith((ref) => Stream.value(testUser)),
            productsStreamProvider.overrideWith((ref) => Stream.value([])),
            heroProductsProvider.overrideWith((ref) => Stream.value([])),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('Welcome back'), findsOneWidget);
      expect(find.textContaining('T.K'), findsOneWidget);
    });

    testWidgets('HomeScreen displays categories', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith((ref) => Stream.value(null)),
            productsStreamProvider.overrideWith((ref) => Stream.value([])),
            heroProductsProvider.overrideWith((ref) => Stream.value([])),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Categories'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Fashion'), findsOneWidget);
      expect(find.text('Electronics'), findsOneWidget);
    });

    testWidgets('HomeScreen displays FloatingActionButton with "Sell" label',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith((ref) => Stream.value(null)),
            productsStreamProvider.overrideWith((ref) => Stream.value([])),
            heroProductsProvider.overrideWith((ref) => Stream.value([])),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.widgetWithText(FloatingActionButton, 'Sell'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('HomeScreen displays products in horizontal list',
        (WidgetTester tester) async {
      // Arrange
      final testProducts = [
        ProductModel(
          id: '1',
          name: 'MacBook Pro',
          nameLower: 'macbook pro',
          searchKeywords: ['macbook', 'pro'],
          imageUrls: ['url1.jpg', 'url2.jpg', 'url3.jpg'],
          category: 'Electronics',
          description: 'Great laptop',
          condition: ProductCondition.newItem,
          status: ProductStatus.active,
          price: 1500.0,
          currency: 'USD',
          ownerId: 'owner1',
          ownerName: 'John Seller',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        ProductModel(
          id: '2',
          name: 'iPhone 15',
          nameLower: 'iphone 15',
          searchKeywords: ['iphone', '15'],
          imageUrls: ['url1.jpg', 'url2.jpg', 'url3.jpg'],
          category: 'Electronics',
          description: 'Latest iPhone',
          condition: ProductCondition.newItem,
          status: ProductStatus.active,
          price: 999.0,
          currency: 'USD',
          ownerId: 'owner2',
          ownerName: 'Jane Seller',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith((ref) => Stream.value(null)),
            productsStreamProvider
                .overrideWith((ref) => Stream.value(testProducts)),
            heroProductsProvider
                .overrideWith((ref) => Stream.value(testProducts)),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('MacBook Pro'), findsWidgets);
      expect(find.text('iPhone 15'), findsWidgets);
      expect(find.text('New arrivals'), findsOneWidget);
    });
  });
}
