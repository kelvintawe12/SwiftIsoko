// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/providers/providers.dart';
import '../../data/models/cart_item.dart';
import '../../data/models/product.dart';
import 'product_detail_screen.dart';
import '../../data/utils/validators.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  Future<List<ProductModel>>? _searchFuture;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _runSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchFuture = null;
      });
      return;
    }

    final productService = ref.read(productServiceProvider);
    setState(() {
      _searchFuture = productService
          .searchProducts(query: query, limit: 50)
          .then((either) => either.fold((_) => <ProductModel>[], (list) => list));
    });
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
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search for products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchFuture = null;
                          });
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () => _runSearch(),
                    ),
                  ],
                ),
              ),
              onSubmitted: (_) => _runSearch(),
            ),
          ),

          // Results area
          Expanded(
            child: _searchController.text.isEmpty && _searchFuture == null
                ? Consumer(builder: (context, ref, _) {
                    // show active products stream when no query
                    final productsAsync = ref.watch(productsStreamProvider);
                    return productsAsync.when(
                      data: (products) {
                        if (products.isEmpty) {
                          return const Center(child: Text('No products available'));
                        }
                        return ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: products.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final p = products[index];
                            return _ProductListTile(product: p);
                          },
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, s) => Center(child: Text('Error loading products: $e')),
                    );
                  })
                : FutureBuilder<List<ProductModel>>(
                    future: _searchFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Search error: ${snapshot.error}'));
                      }
                      final results = snapshot.data ?? [];
                      if (results.isEmpty) {
                        return const Center(child: Text('No results found'));
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: results.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final p = results[index];
                          return _ProductListTile(product: p);
                        },
                      );
                    },
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


class _ProductListTile extends StatelessWidget {
  final ProductModel product;

  const _ProductListTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: product.imageUrls.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: product.imageUrls.first,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 64,
                    height: 64,
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 64,
                    height: 64,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image),
                  ),
                )
              : Container(
                  width: 64,
                  height: 64,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image),
                ),
        ),
        title: Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text('${product.currency} ${product.price.toStringAsFixed(0)}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: product.status == ProductStatus.sold ? Colors.green[50] : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            product.status.name.toUpperCase(),
            style: TextStyle(
              color: product.status == ProductStatus.sold ? Colors.green : Colors.grey[700],
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ));
        },
      ),
    );
  }
}
