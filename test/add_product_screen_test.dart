import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swapit_marketplace/presentation/home/add_product_screen.dart';
import 'package:swapit_marketplace/data/models/person.dart';
import 'package:swapit_marketplace/data/providers/providers.dart';
import 'package:swapit_marketplace/data/providers/state_notifiers.dart';

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
            productCreationNotifierProvider.overrideWith(
              (ref) => ProductCreationNotifier(
                ref.read(productServiceProvider),
                ref.read(cloudinaryServiceProvider),
              ),
            ),
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
