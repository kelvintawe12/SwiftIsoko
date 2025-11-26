import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/providers.dart';
import '../../data/providers/state_notifiers.dart';
import '../../data/providers/preferences_provider.dart';
import '../chat/chat_list_screen.dart';
import '../../data/utils/validators.dart';
import '../../data/models/product.dart';
import '../auth/login_page.dart';
import 'settings_screen.dart';
import '../../core/utils/app_localizations.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final language = ref.watch(languageProvider);
    final localizations = AppLocalizations(language);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.profile),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: currentUser.when(
        data: (user) {
          if (user == null) {
            return const Center(
              child: Text('Please sign in to view profile'),
            );
          }

          // Preload user-related streams
          final userProductsAsync = ref.watch(userProductsProvider(user.uid));
          final userOrdersAsync = ref.watch(userOrdersProvider);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),

                // Header: Avatar, name, email, rating
                Row(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      backgroundImage: user.profileImageUrl != null
                          ? NetworkImage(user.profileImageUrl!)
                          : null,
                      child: user.profileImageUrl == null
                          ? Text(
                              Formatters.getInitials(user.name),
                              style: const TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                user.ratingAverage.toStringAsFixed(1),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 6),
                              Text('(${user.numRatings} reviews)',
                                  style: TextStyle(color: Colors.grey[600])),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (user.isEmailVerified)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified, size: 14, color: Colors.green),
                            SizedBox(width: 6),
                            Text('Verified',
                                style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 18),

                // Tabs
                Expanded(
                  child: DefaultTabController(
                    length: 5,
                    child: Column(
                      children: [
                        TabBar(
                          isScrollable: true,
                          labelColor: Theme.of(context).colorScheme.primary,
                          unselectedLabelColor: Colors.grey[600],
                          tabs: [
                            Tab(text: localizations.myListings),
                            Tab(text: localizations.myOrders),
                            const Tab(text: 'Made'),
                            const Tab(text: 'Saved'),
                            const Tab(text: 'More'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: TabBarView(
                            children: [
                              // My Listings
                              userProductsAsync.when(
                                data: (products) {
                                  // Sort client-side by createdAt desc to preserve UX without
                                  // relying on Firestore server-side ordering (avoids composite index requirements).
                                  final sorted =
                                      List<ProductModel>.from(products)
                                        ..sort((a, b) =>
                                            b.createdAt.compareTo(a.createdAt));

                                  if (sorted.isEmpty) {
                                    return const Center(
                                        child: Text('No listings yet'));
                                  }

                                  return ListView.separated(
                                    itemCount: sorted.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 8),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    itemBuilder: (context, index) {
                                      final p = sorted[index];
                                      return ListTile(
                                        leading: p.imageUrls.isNotEmpty
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.network(
                                                  p.imageUrls.first,
                                                  width: 60,
                                                  height: 60,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : Container(
                                                width: 60,
                                                height: 60,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[100],
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: const Icon(
                                                    Icons.image_outlined),
                                              ),
                                        title: Text(p.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis),
                                        subtitle: Text(
                                            '${p.currency} ${p.price.toStringAsFixed(0)}'),
                                        trailing: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 6),
                                          decoration: BoxDecoration(
                                            color:
                                                p.status == ProductStatus.sold
                                                    ? Colors.green[50]
                                                    : Colors.grey[100],
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            p.status.name.toUpperCase(),
                                            style: TextStyle(
                                              color:
                                                  p.status == ProductStatus.sold
                                                      ? Colors.green
                                                      : Colors.grey[700],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          // Open product details (not implemented)
                                        },
                                      );
                                    },
                                  );
                                },
                                loading: () => const Center(
                                    child: CircularProgressIndicator()),
                                error: (e, s) =>
                                    Center(child: Text('Error: $e')),
                              ),

                              // Purchases (orders)
                              userOrdersAsync.when(
                                data: (orders) {
                                  // Sort client-side by createdAt desc to avoid requiring a composite index.
                                  final sorted = List.from(orders)
                                    ..sort((a, b) =>
                                        b.createdAt.compareTo(a.createdAt));

                                  if (sorted.isEmpty) {
                                    return const Center(
                                        child: Text('No purchases yet'));
                                  }

                                  return ListView.separated(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    itemCount: sorted.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 8),
                                    itemBuilder: (context, index) {
                                      final o = sorted[index];
                                      return ListTile(
                                        leading: const Icon(
                                            Icons.shopping_bag_outlined),
                                        title: Text(
                                            'Order • ${o.totalAmount.toStringAsFixed(0)} ${o.paymentMethod ?? ''}'),
                                        subtitle: Text(
                                            '${o.status.name} • ${o.createdAt.toLocal().toString().split(' ').first}'),
                                        onTap: () {},
                                      );
                                    },
                                  );
                                },
                                loading: () => const Center(
                                    child: CircularProgressIndicator()),
                                error: (e, s) =>
                                    Center(child: Text('Error: $e')),
                              ),

                              // Made (sold items)
                              userProductsAsync.when(
                                data: (products) {
                                  final sold = products
                                      .where(
                                          (p) => p.status == ProductStatus.sold)
                                      .toList();
                                  if (sold.isEmpty) {
                                    return const Center(
                                        child: Text('No sold items yet'));
                                  }

                                  return ListView.separated(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    itemCount: sold.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 8),
                                    itemBuilder: (context, index) {
                                      final p = sold[index];
                                      return ListTile(
                                        leading: p.imageUrls.isNotEmpty
                                            ? Image.network(p.imageUrls.first,
                                                width: 60,
                                                height: 60,
                                                fit: BoxFit.cover)
                                            : const Icon(Icons.image_outlined),
                                        title: Text(p.name),
                                        subtitle: Text(
                                            '${p.currency} ${p.price.toStringAsFixed(0)}'),
                                      );
                                    },
                                  );
                                },
                                loading: () => const Center(
                                    child: CircularProgressIndicator()),
                                error: (e, s) =>
                                    Center(child: Text('Error: $e')),
                              ),

                              // Saved: show both user-doc savedProductIds and favorites subcollection
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: Column(
                                  children: [
                                    // Saved (user doc)
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0, vertical: 8.0),
                                        child: Text('Saved',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 160,
                                      child: Consumer(
                                          builder: (context, innerRef, _) {
                                        final savedAsync = innerRef.watch(
                                            savedProductsProvider(user.uid));
                                        return savedAsync.when(
                                          data: (products) {
                                            if (products.isEmpty) {
                                              return const Center(
                                                  child: Text(
                                                      'No saved items (user document).'));
                                            }
                                            return ListView.separated(
                                              scrollDirection: Axis.horizontal,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8),
                                              itemCount: products.length,
                                              separatorBuilder: (_, __) =>
                                                  const SizedBox(width: 8),
                                              itemBuilder: (context, i) {
                                                final p = products[i];
                                                return SizedBox(
                                                  width: 260,
                                                  child: Card(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12)),
                                                    child: Row(
                                                      children: [
                                                        if (p.imageUrls
                                                            .isNotEmpty)
                                                          ClipRRect(
                                                            borderRadius: const BorderRadius
                                                                .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        12),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        12)),
                                                            child:
                                                                Image.network(
                                                                    p.imageUrls
                                                                        .first,
                                                                    width: 90,
                                                                    height: 90,
                                                                    fit: BoxFit
                                                                        .cover),
                                                          )
                                                        else
                                                          Container(
                                                              width: 90,
                                                              height: 90,
                                                              color: Colors
                                                                  .grey[100],
                                                              child: const Icon(
                                                                  Icons
                                                                      .image_outlined)),
                                                        const SizedBox(
                                                            width: 8),
                                                        Expanded(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(p.name,
                                                                    maxLines: 2,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                                const SizedBox(
                                                                    height: 6),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                        '${p.currency} ${p.price.toStringAsFixed(0)}'),
                                                                    IconButton(
                                                                      icon: const Icon(
                                                                          Icons
                                                                              .bookmark_remove_outlined,
                                                                          color:
                                                                              Colors.red),
                                                                      onPressed:
                                                                          () async {
                                                                        final notifier =
                                                                            innerRef.read(savedIdsNotifierProvider(user.uid).notifier);
                                                                        await notifier
                                                                            .toggleSave(p.id);
                                                                        innerRef
                                                                            .invalidate(savedProductsProvider(user.uid));
                                                                      },
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          loading: () => const Center(
                                              child:
                                                  CircularProgressIndicator()),
                                          error: (e, s) =>
                                              Center(child: Text('Error: $e')),
                                        );
                                      }),
                                    ),

                                    const SizedBox(height: 12),

                                    // Favorites (subcollection)
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0, vertical: 8.0),
                                        child: Text('Favorites',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium),
                                      ),
                                    ),
                                    Expanded(
                                      child: Consumer(
                                          builder: (context, innerRef, _) {
                                        final favsAsync = innerRef.watch(
                                            favoritesSubcollectionProductsProvider(
                                                user.uid));
                                        return favsAsync.when(
                                          data: (products) {
                                            if (products.isEmpty)
                                              return const Center(
                                                  child: Text(
                                                      'No favorites yet.'));
                                            return ListView.separated(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                      horizontal: 8),
                                              itemCount: products.length,
                                              separatorBuilder: (_, __) =>
                                                  const SizedBox(height: 8),
                                              itemBuilder: (context, index) {
                                                final p = products[index];
                                                return ListTile(
                                                  leading: p
                                                          .imageUrls.isNotEmpty
                                                      ? Image.network(
                                                          p.imageUrls.first,
                                                          width: 60,
                                                          height: 60,
                                                          fit: BoxFit.cover)
                                                      : const Icon(
                                                          Icons.image_outlined),
                                                  title: Text(p.name),
                                                  subtitle: Text(
                                                      '${p.currency} ${p.price.toStringAsFixed(0)}'),
                                                  trailing: IconButton(
                                                    icon: const Icon(
                                                        Icons.delete_outline,
                                                        color: Colors.red),
                                                    onPressed: () async {
                                                      final notifier =
                                                          innerRef.read(
                                                              savedIdsNotifierProvider(
                                                                      user.uid)
                                                                  .notifier);
                                                      await notifier
                                                          .toggleSave(p.id);
                                                      innerRef.invalidate(
                                                          savedProductsProvider(
                                                              user.uid));
                                                    },
                                                  ),
                                                  onTap: () {},
                                                );
                                              },
                                            );
                                          },
                                          loading: () => const Center(
                                              child:
                                                  CircularProgressIndicator()),
                                          error: (e, s) =>
                                              Center(child: Text('Error: $e')),
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                              ),

                              // More (other menu items)
                              ListView(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                children: [
                                  _MenuItem(
                                    icon: Icons.chat_outlined,
                                    title: localizations.messages,
                                    subtitle: 'Chat with buyers and sellers',
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const ChatListScreen()));
                                    },
                                  ),
                                  _MenuItem(
                                    icon: Icons.location_on_outlined,
                                    title: 'Addresses',
                                    subtitle: 'Manage shipping addresses',
                                    onTap: () => ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                            content:
                                                Text('Addresses coming soon'))),
                                  ),
                                  _MenuItem(
                                    icon: Icons.help_outline,
                                    title: localizations.helpSupport,
                                    subtitle: 'Get help with your account',
                                    onTap: () => ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                            content:
                                                Text('Support coming soon'))),
                                  ),
                                  const Divider(height: 32),
                                  _MenuItem(
                                    icon: Icons.logout,
                                    title: localizations.signOut,
                                    subtitle: 'Sign out of your account',
                                    textColor: Colors.red,
                                    onTap: () => _showSignOutDialog(context, localizations),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
            ],
          ),
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, AppLocalizations localizations) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(localizations.signOut),
        content: Text(localizations.confirmSignOut),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogCtx).pop();

              // Capture UI helpers before awaiting to avoid using BuildContext
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);

              final authNotifier = ref.read(authNotifierProvider.notifier);
              final result = await authNotifier.signOut();

              if (!mounted) return;

              result.fold(
                (failure) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(failure.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
                (_) {
                  navigator.pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const SignInScreen()),
                    (route) => false,
                  );
                },
              );
            },
            child: Text(localizations.signOut, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? textColor;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
