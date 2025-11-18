import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swapit_marketplace/presentation/pages/cart_page.dart';
import 'package:swapit_marketplace/presentation/bloc/cart/cart_bloc.dart';
import 'package:swapit_marketplace/data/models/product.dart';

void main() {
  testWidgets('CartPage shows item and quantity changes', (tester) async {
    final bloc = CartBloc();
    final product = Product(
      id: '1',
      name: 'Test Item',
      price: 100.0,
      imageUrls: ['assets/images/macbook.png', 'assets/images/macbook.png'],
      category: 'electronics',
      description: 'Test description',
      condition: 'newCondition',
      status: 'active',
      ownerId: 'test-owner',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    // add twice to make quantity 2
    bloc.add(AddToCart(product));
    bloc.add(AddToCart(product));

    await tester.pumpWidget(BlocProvider<CartBloc>.value(
      value: bloc,
      child: const MaterialApp(home: CartPage()),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Test Item'), findsOneWidget);
    // quantity should show '2'
    expect(find.text('2'), findsWidgets);

    // tap decrement
    final dec = find.byIcon(Icons.remove).first;
    await tester.tap(dec);
    await tester.pumpAndSettle();

    // now quantity should be 1
    expect(find.text('1'), findsWidgets);
  });
}
