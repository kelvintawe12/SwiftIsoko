import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:swapit_marketplace/presentation/pages/sell_item_page.dart';

void main() {
  testWidgets('SellItemPage shows photo area and submit button', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SellItemPage()));
    await tester.pumpAndSettle();

    expect(find.text('Photos (up to 5)'), findsOneWidget);
    expect(find.text('Add Photo'), findsOneWidget);
    expect(find.text('List Item for Sale'), findsOneWidget);
  });
}
