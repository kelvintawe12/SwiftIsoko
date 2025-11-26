import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swapit_marketplace/presentation/home/home_screen.dart';
import 'test_helpers.dart';
import 'package:swapit_marketplace/data/providers/providers.dart';

void main() {
  testWidgets('HomeScreen shows sample product', (WidgetTester tester) async {
    final sample = makeSampleProduct();

    await tester.pumpWidget(ProviderScope(
      overrides: [
        productsStreamProvider.overrideWithProvider(StreamProvider.autoDispose((ref) => Stream.value([sample]))),
        heroProductsProvider.overrideWithProvider(StreamProvider.autoDispose((ref) => Stream.value([sample]))),
        currentUserProvider.overrideWithProvider(StreamProvider((ref) => Stream.value(null))),
      ],
      child: const MaterialApp(home: HomeScreen()),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Sample Product'), findsOneWidget);
  });
}
