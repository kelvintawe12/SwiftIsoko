// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/providers/providers.dart';
import '../../data/models/cart_item.dart';
import '../../data/models/product.dart';
import '../../data/utils/validators.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Products'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Search for products',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start typing to find products',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  Future<void> _clearCart(BuildContext context, WidgetRef ref, String cartId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final cartService = ref.read(cartServiceProvider);
    final result = await cartService.clearCart(cartId);

    if (context.mounted) {
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: Colors.red,
            ),
          );
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cart cleared successfully'),
              backgroundColor: Colors.green,
            ),
          );
        },
      );
    }
  }

  Future<void> _removeItem(
    BuildContext context,
    WidgetRef ref,
    String cartItemId,
    String productId,
  ) async {
    final cartService = ref.read(cartServiceProvider);
    final result = await cartService.removeItemFromCart(
      cartItemId: cartItemId,
      productId: productId,
    );

    if (context.mounted) {
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: Colors.red,
            ),
          );
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Item removed from cart'),
              backgroundColor: Colors.green,
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(currentUserCartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        actions: [
          cart.when(
            data: (cartData) {
              if (cartData == null) return const SizedBox.shrink();
              return IconButton(
            icon: const Icon(Icons.delete_outline),
                onPressed: () => _clearCart(context, ref, cartData.id),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: cart.when(
        data: (cartData) {
          if (cartData == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Your cart is empty'),
                  SizedBox(height: 8),
                  Text(
                    'Add some products to get started',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final cartItems = ref.watch(cartItemsProvider(cartData.id));
          final cartTotal = ref.watch(cartTotalProvider(cartData.id));

          return cartItems.when(
            data: (items) {
              if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Your cart is empty'),
                  SizedBox(height: 8),
                  Text(
                    'Add some products to get started',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                    child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final product = ref.watch(productProvider(item.productId));

                        return product.when(
                          data: (productData) => _CartItemCard(
                            cartItem: item,
                            product: productData,
                            onRemove: () => _removeItem(
                              context,
                              ref,
                              item.id,
                              item.productId,
                            ),
                          ),
                          loading: () => Card(
                      child: ListTile(
                        leading: Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[300],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              title: Text(item.productName ?? 'Loading...'),
                              subtitle: Text(
                                Formatters.formatCurrency(
                                  item.priceAtAdd,
                                  currency: 'RWF',
                                ),
                        ),
                      ),
                    ),
                          error: (error, stack) => Card(
                            child: ListTile(
                              leading: Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[300],
                                child: const Icon(Icons.error),
                              ),
                              title: Text(item.productName ?? 'Product'),
                              subtitle: Text(
                                Formatters.formatCurrency(
                                  item.priceAtAdd,
                                  currency: 'RWF',
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                          cartTotal.when(
                            data: (total) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                                  Formatters.formatCurrency(total, currency: 'RWF'),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                            ),
                            loading: () => const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(),
                                ),
                              ],
                            ),
                            error: (_, __) => const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Error',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Checkout feature coming soon'),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Checkout'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error loading cart items: $error'),
                ],
              ),
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
              Text('Error loading cart: $error'),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItemModel cartItem;
  final ProductModel product;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.cartItem,
    required this.product,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: product.imageUrls.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: product.imageUrls.first,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image),
                  ),
                )
              : Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image),
                ),
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              Formatters.formatCurrency(
                cartItem.priceAtAdd,
                currency: product.currency,
              ),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            if (cartItem.quantity > 1)
              Text(
                'Quantity: ${cartItem.quantity}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onRemove,
          tooltip: 'Remove from cart',
        ),
      ),
    );
  }
}
