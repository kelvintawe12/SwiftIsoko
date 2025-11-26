import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/providers.dart';
import '../../data/models/message.dart';
import '../../core/constants/colors.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String otherUserId;

  const ChatScreen({super.key, required this.chatId, required this.otherUserId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please sign in to send messages')));
      return;
    }

    if (text.isEmpty) return;

    final chatService = ref.read(chatServiceProvider);
    final res = await chatService.sendMessage(chatId: widget.chatId, senderId: userId, text: text);
    res.fold((failure) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message)));
    }, (message) {
      _controller.clear();
      // scroll to bottom (messages are returned descending — wait a tick then jump)
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.minScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider(widget.chatId));
    final userId = ref.watch(currentUserIdProvider);
    // fetch other user's profile for display in appbar
    final otherAsync = ref.watch(userByIdProvider(widget.otherUserId));

    return Scaffold(
      appBar: AppBar(
        title: otherAsync.when(
          data: (other) => Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: other?.profileImageUrl != null ? NetworkImage(other!.profileImageUrl!) : null,
                backgroundColor: AppColors.primary,
                child: other?.profileImageUrl == null ? Text(other?.name.isNotEmpty == true ? other!.name[0].toUpperCase() : '?') : null,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(other?.name ?? 'Chat')),
            ],
          ),
          loading: () => const Text('Chat'),
          error: (_, __) => const Text('Chat'),
        ),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () => _openChatListSheet(context),
            tooltip: 'Switch conversation',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                    colors: [AppColors.primary.withAlpha(31), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: messagesAsync.when(
                  data: (messages) {
                    final list = List<MessageModel>.from(messages.reversed);

                    return ListView.builder(
                      controller: _scrollController,
                      reverse: false,
                      padding: const EdgeInsets.all(12),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final m = list[index];
                        final isMe = m.senderId == userId;
                        final bubble = Container(
                          decoration: BoxDecoration(
                            gradient: isMe
                              ? LinearGradient(colors: [AppColors.primary, AppColors.primary.withAlpha(217)])
                                : null,
                            color: isMe ? null : Colors.grey[200],
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(12),
                              topRight: const Radius.circular(12),
                              bottomLeft: Radius.circular(isMe ? 12 : 4),
                              bottomRight: Radius.circular(isMe ? 4 : 12),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                m.text,
                                style: TextStyle(color: isMe ? Colors.white : Colors.black87),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                m.createdAt.toLocal().toString().split('.').first,
                                style: TextStyle(fontSize: 10, color: isMe ? Colors.white70 : Colors.black54),
                              ),
                            ],
                          ),
                        );

                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: bubble,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Error: $e')),
                ),
              ),

              // Composer
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          minLines: 1,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: 'Write a message...',
                            isDense: true,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: AppColors.primary,
                        radius: 24,
                        child: IconButton(
                          onPressed: _send,
                          icon: const Icon(Icons.send, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

    void _openChatListSheet(BuildContext context) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (ctx) {
          return SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.75,
            child: const Padding(
              padding: EdgeInsets.all(12.0),
              child: ChatListSheet(),
            ),
          );
        },
      );
    }
}

  class ChatListSheet extends ConsumerWidget {
    const ChatListSheet({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final chatsAsync = ref.watch(userChatsProvider);
      final userId = ref.watch(currentUserIdProvider);

      return chatsAsync.when(
        data: (chats) {
          if (chats.isEmpty) return const Center(child: Text('No conversations'));
          return ListView.separated(
            itemCount: chats.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final chat = chats[index];
              final other = chat.participants.where((p) => p != userId).toList();
              final otherId = other.isNotEmpty ? other.first : chat.participants.first;

              return ListTile(
                leading: Consumer(builder: (ctx, r, _) {
                  final otherAsync = r.watch(userByIdProvider(otherId));
                  return otherAsync.when(
                    data: (otherUser) {
                      if (otherUser == null) return CircleAvatar(child: Text(otherId.isNotEmpty ? otherId[0].toUpperCase() : '?'));
                      return CircleAvatar(backgroundImage: otherUser.profileImageUrl != null ? NetworkImage(otherUser.profileImageUrl!) : null, backgroundColor: AppColors.primary, child: otherUser.profileImageUrl == null ? Text(otherUser.name.isNotEmpty ? otherUser.name[0].toUpperCase() : '?') : null);
                    },
                    loading: () => const CircleAvatar(child: CircularProgressIndicator(strokeWidth: 2)),
                    error: (_, __) => CircleAvatar(child: Text(otherId.isNotEmpty ? otherId[0].toUpperCase() : '?')),
                  );
                }),
                title: Consumer(builder: (ctx, r, _) {
                  final otherAsync = r.watch(userByIdProvider(otherId));
                  return otherAsync.when(
                    data: (otherUser) => Text(otherUser?.name ?? otherId),
                    loading: () => const Text('User'),
                    error: (_, __) => Text(otherId),
                  );
                }),
                subtitle: Text('Updated ${chat.lastMessageAt.toLocal().toString().split('.').first}'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ChatScreen(chatId: chat.id, otherUserId: otherId)));
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      );
    }
  }
