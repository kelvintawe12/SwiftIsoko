import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swapit_marketplace/presentation/chat/chat_screen.dart';
import 'package:swapit_marketplace/data/providers/providers.dart';
import 'test_fakes.dart';
import 'package:swapit_marketplace/data/models/message.dart';

void main() {
  testWidgets('ChatScreen displays messages and composer', (WidgetTester tester) async {
    final msg = MessageModel(id: 'm1', chatId: 'c1', senderId: 'u1', text: 'Hello', createdAt: DateTime.now());

    await tester.pumpWidget(ProviderScope(
      overrides: [
          chatMessagesProvider.overrideWith((ref, chatId) => Stream.value([msg])),
        currentUserIdProvider.overrideWithValue('u1'),
        productServiceProvider.overrideWithValue(FakeProductService()),
        cloudinaryServiceProvider.overrideWithValue(FakeCloudinaryService()),
      ],
      child: const MaterialApp(home: ChatScreen(chatId: 'c1', otherUserId: 'u2')),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Hello'), findsOneWidget);
    expect(find.byIcon(Icons.send), findsOneWidget);
  });
}
