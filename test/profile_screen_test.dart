import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swapit_marketplace/presentation/home/profile_screen.dart';
import 'package:swapit_marketplace/data/providers/providers.dart';
import 'package:swapit_marketplace/data/models/person.dart';

void main() {
  testWidgets('Profile screen shows sign in/guest welcome', (WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        currentUserProvider.overrideWith((ref) => Stream.value(null)),
      ],
      child: const MaterialApp(home: ProfileScreen()),
    ));

    await tester.pumpAndSettle();

    expect(find.textContaining('Welcome'), findsWidgets);
  });
}
