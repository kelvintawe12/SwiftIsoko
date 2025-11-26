import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/providers.dart';
// chat model not directly referenced here
import '../../core/constants/colors.dart';
import 'chat_screen.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);
    final chatsAsync = ref.watch(userChatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(userChatsProvider),
            tooltip: 'Refresh',
          )
        ],
      ),
      body: chatsAsync.when(
        data: (chats) {
          if (chats.isEmpty) return const Center(child: Text('No conversations yet'));

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: chats.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final chat = chats[index];

              // determine other participant
              final other = chat.participants.where((p) => p != userId).toList();
              final otherId = other.isNotEmpty ? other.first : chat.participants.first;

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  leading: Consumer(builder: (ctx, r, _) {
                    final otherAsync = r.watch(userByIdProvider(otherId));
                    return otherAsync.when(
                      data: (otherUser) {
                        if (otherUser == null) return CircleAvatar(child: Text(otherId.isNotEmpty ? otherId[0].toUpperCase() : '?'));
                        return CircleAvatar(
                          backgroundImage: otherUser.profileImageUrl != null ? NetworkImage(otherUser.profileImageUrl!) : null,
                          backgroundColor: AppColors.primary,
                          child: otherUser.profileImageUrl == null ? Text(otherUser.name.isNotEmpty ? otherUser.name[0].toUpperCase() : '?') : null,
                        );
                      },
                      loading: () => const CircleAvatar(child: CircularProgressIndicator(strokeWidth: 2)),
                      error: (_, __) => CircleAvatar(child: Text(otherId.isNotEmpty ? otherId[0].toUpperCase() : '?')),
                    );
                  }),
                  title: Consumer(builder: (ctx, r, _) {
                    final otherAsync = r.watch(userByIdProvider(otherId));
                    return otherAsync.when(
                      data: (otherUser) => Text(otherUser?.name ?? otherId, style: const TextStyle(fontWeight: FontWeight.bold)),
                      loading: () => const Text('User'),
                      error: (_, __) => Text(otherId),
                    );
                  }),
                  subtitle: Text('Updated ${chat.lastMessageAt.toLocal().toString().split('.').first}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ChatScreen(chatId: chat.id, otherUserId: otherId),
                    ));
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
