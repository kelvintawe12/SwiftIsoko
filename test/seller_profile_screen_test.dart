import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swapit_marketplace/presentation/profile/seller_profile_screen.dart';
import 'test_helpers.dart';
import 'package:swapit_marketplace/data/providers/providers.dart';

void main() {
  testWidgets('SellerProfile shows seller name and listings', (WidgetTester tester) async {
    final user = makeSampleUser(uid: 'seller1', name: 'Seller One');
    final product = makeSampleProduct(id: 'p1', ownerId: 'seller1', ownerName: 'Seller One');

    await tester.pumpWidget(ProviderScope(
      overrides: [
        userByIdProvider.overrideWithProvider(StreamProvider.family((ref, uid) => Stream.value(user))),
        userProductsProvider.overrideWithProvider(StreamProvider.family((ref, uid) => Stream.value([product]))),
      ],
      child: MaterialApp(home: SellerProfileScreen(sellerId: 'seller1')),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Seller One'), findsWidgets);
    expect(find.text('Sample Product'), findsOneWidget);
  });
}
