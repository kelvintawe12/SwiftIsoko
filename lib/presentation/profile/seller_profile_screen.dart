import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../data/providers/providers.dart';
import '../../data/models/product.dart';
import '../chat/chat_screen.dart';
import '../home/product_detail_screen.dart';

class SellerProfileScreen extends ConsumerStatefulWidget {
  final String sellerId;

  const SellerProfileScreen({super.key, required this.sellerId});

  @override
  ConsumerState<SellerProfileScreen> createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends ConsumerState<SellerProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userByIdProvider(widget.sellerId));
    final productsAsync = ref.watch(userProductsProvider(widget.sellerId));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Seller'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Seller not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 120, 16, 96),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header card with avatar and meta
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: AppColors.primary,
                        backgroundImage: user.profileImageUrl != null ? NetworkImage(user.profileImageUrl!) : null,
                        child: user.profileImageUrl == null ? Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U', style: const TextStyle(color: Colors.white, fontSize: 32)) : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            if (user.location != null) Text(user.location!, style: const TextStyle(color: AppColors.textLight)),
                            const SizedBox(height: 6),
                            Row(children: [
                              const Icon(Icons.star, color: Colors.amber, size: 18),
                              const SizedBox(width: 6),
                              Text('${user.ratingAverage.toStringAsFixed(1)} (${user.numRatings})'),
                            ])
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Action buttons (Message / Rate)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _openChat(context),
                        icon: const Icon(Icons.message_outlined),
                        label: const Text('Message'),
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => _showRateDialog(context),
                      icon: const Icon(Icons.star_border),
                      label: const Text('Rate Seller'),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                if (user.bio != null && user.bio!.isNotEmpty) ...[
                  Text('About', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(user.bio!),
                  const SizedBox(height: 12),
                ],

                Text('Listings', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                productsAsync.when(
                  data: (products) {
                    if (products.isEmpty) return const Text('No listings');
                    return Column(
                      children: products.map((p) => _listingTile(context, p)).toList(),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Error: $e')),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
      // Bottom action bar with primary actions so it visually sits above any app-level nav
      bottomNavigationBar: BottomAppBar(
        elevation: 8,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openChat(context),
                  icon: const Icon(Icons.message_outlined),
                  label: const Text('Message'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showRateDialog(context),
                  icon: const Icon(Icons.star_border),
                  label: const Text('Rate Seller'),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _listingTile(BuildContext context, ProductModel p) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: p.imageUrls.isNotEmpty ? Image.network(p.imageUrls.first, width: 56, height: 56, fit: BoxFit.cover) : const Icon(Icons.image_outlined),
        title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text('${p.currency} ${p.price.toStringAsFixed(0)}'),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p)));
        },
      ),
    );
  }



  Future<void> _openChat(BuildContext context) async {
    final currentUserId = ref.read(currentUserIdProvider);
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please sign in to message sellers')));
      return;
    }

    final chatService = ref.read(chatServiceProvider);
    final res = await chatService.getOrCreateChat(currentUserId, widget.sellerId);

    res.fold((failure) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message)));
    }, (chat) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatScreen(chatId: chat.id, otherUserId: widget.sellerId)));
    });
  }

  void _showRateDialog(BuildContext context) {
    int selected = 5;
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx2, setState) {
          return AlertDialog(
            title: const Text('Rate Seller'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Select a rating'),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final idx = i + 1;
                    return IconButton(
                      icon: Icon(idx <= selected ? Icons.star : Icons.star_border, color: Colors.amber),
                      onPressed: () => setState(() => selected = idx),
                    );
                  }),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx2).pop(), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  // submit rating
                  final currentUserId = ref.read(currentUserIdProvider);
                  final currentUserAsync = ref.read(currentUserProvider);
                  final raterName = currentUserAsync.asData?.value?.name ?? 'User';

                  if (currentUserId == null) {
                    Navigator.of(ctx2).pop();
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please sign in to rate sellers')));
                    return;
                  }

                  Navigator.of(ctx2).pop();
                  final reviewService = ref.read(reviewServiceProvider);
                  final res = await reviewService.addUserRating(
                    ratedUserId: widget.sellerId,
                    ratedUserName: ref.read(userByIdProvider(widget.sellerId)).asData?.value?.name ?? '',
                    raterUserId: currentUserId,
                    raterUserName: raterName,
                    rating: selected,
                    review: null,
                  );

                  res.fold((failure) {
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message)));
                  }, (rating) {
                    // refresh seller data so aggregates update
                    ref.invalidate(userByIdProvider(widget.sellerId));
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thanks for your rating!')));
                  });
                },
                child: const Text('Submit'),
              ),
            ],
          );
        });
      },
    );
  }
}
