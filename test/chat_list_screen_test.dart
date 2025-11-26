import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swapit_marketplace/presentation/chat/chat_list_screen.dart';
import 'test_helpers.dart';
import 'package:swapit_marketplace/data/providers/providers.dart';
import 'package:swapit_marketplace/data/models/chat.dart';

void main() {
  testWidgets('ChatList shows chat items', (WidgetTester tester) async {
    final chat = ChatModel(id: 'c1', participants: ['u1', 'u2'], lastMessageAt: DateTime.now());

    await tester.pumpWidget(ProviderScope(
      overrides: [
        userChatsProvider.overrideWithProvider(StreamProvider((ref) => Stream.value([chat]))),
        currentUserIdProvider.overrideWithValue('u1'),
      ],
      child: const MaterialApp(home: ChatListScreen()),
    ));

    await tester.pumpAndSettle();

    // Expect a list tile with a chevron
    expect(find.byIcon(Icons.chevron_right), findsWidgets);
  });
}
