import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/product.dart';
import '../../data/models/cart_item.dart';
import '../../data/utils/validators.dart';
import '../../data/providers/providers.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();
  bool _isAddingToCart = false;
  bool _isRemovingFromCart = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _addToCart() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please sign in to add items to cart'),
          ),
        );
      }
      return;
    }

    setState(() {
      _isAddingToCart = true;
    });

    final cartService = ref.read(cartServiceProvider);
    final result = await cartService.addItemToCart(
      userId: userId,
      productId: widget.product.id,
      productName: widget.product.name,
      price: widget.product.price,
    );

    setState(() {
      _isAddingToCart = false;
    });

    if (mounted) {
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
              content: Text('Product added to cart successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          // Refresh the product to update status
          ref.invalidate(productProvider(widget.product.id));
        },
      );
    }
  }

  Future<void> _removeFromCart(String cartItemId) async {
    setState(() {
      _isRemovingFromCart = true;
    });

    final cartService = ref.read(cartServiceProvider);
    final result = await cartService.removeItemFromCart(
      cartItemId: cartItemId,
      productId: widget.product.id,
    );

    setState(() {
      _isRemovingFromCart = false;
    });

    if (mounted) {
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
              content: Text('Product removed from cart successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          // Refresh the product to update status
          ref.invalidate(productProvider(widget.product.id));
        },
      );
    }
  }

  String _formatCondition(ProductCondition condition) {
    switch (condition) {
      case ProductCondition.newItem:
        return 'New';
      case ProductCondition.likeNew:
        return 'Like New';
      case ProductCondition.used:
        return 'Used';
      case ProductCondition.damaged:
        return 'Damaged';
    }
  }

  Color _getConditionColor(ProductCondition condition) {
    switch (condition) {
      case ProductCondition.newItem:
        return Colors.green;
      case ProductCondition.likeNew:
        return Colors.blue;
      case ProductCondition.used:
        return Colors.orange;
      case ProductCondition.damaged:
        return Colors.red;
    }
  }

  String _formatStatus(ProductStatus status) {
    switch (status) {
      case ProductStatus.active:
        return 'Available';
      case ProductStatus.incart:
        return 'In Cart';
      case ProductStatus.sold:
        return 'Sold';
      case ProductStatus.hidden:
        return 'Hidden';
    }
  }

  Color _getStatusColor(ProductStatus status) {
    switch (status) {
      case ProductStatus.active:
        return Colors.green;
      case ProductStatus.incart:
        return Colors.orange;
      case ProductStatus.sold:
        return Colors.red;
      case ProductStatus.hidden:
        return Colors.grey;
    }
  }

  CartItemModel? _findCartItem(List<CartItemModel> items, String productId) {
    try {
      return items.firstWhere((item) => item.productId == productId);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: product.imageUrls.isNotEmpty
                  ? PageView.builder(
                      controller: _pageController,
                      itemCount: product.imageUrls.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return CachedNetworkImage(
                          imageUrl: product.imageUrls[index],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.broken_image,
                              size: 64,
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, size: 64),
                    ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share feature coming soon!')),
                  );
                },
              ),
            ],
          ),

          // Image Indicators
          if (product.imageUrls.length > 1)
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    product.imageUrls.length,
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentImageIndex == index
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[300],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Product Information
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name and Status
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              _getStatusColor(product.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _getStatusColor(product.status),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _formatStatus(product.status),
                          style: TextStyle(
                            color: _getStatusColor(product.status),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Price
                  Text(
                    Formatters.formatCurrency(
                      product.price,
                      currency: product.currency,
                    ),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Category and Condition Row
                  Row(
                    children: [
                      // Category Chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.category,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              product.category,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Condition Chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _getConditionColor(product.condition)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _getConditionColor(product.condition),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_outlined,
                              size: 16,
                              color: _getConditionColor(product.condition),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatCondition(product.condition),
                              style: TextStyle(
                                color: _getConditionColor(product.condition),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Divider
                  const Divider(),
                  const SizedBox(height: 16),

                  // Description Section
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),

                  // Seller Information Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Seller Information',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                child: Text(
                                  product.ownerName != null
                                      ? Formatters.getInitials(
                                          product.ownerName!)
                                      : '?',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.ownerName ?? 'Unknown Seller',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    TextButton.icon(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'View seller profile coming soon!',
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.person_outline),
                                      label: const Text('View Profile'),
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Product Details Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Product Details',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 12),
                          _DetailRow(
                            icon: Icons.category_outlined,
                            label: 'Category',
                            value: product.category,
                          ),
                          const SizedBox(height: 12),
                          _DetailRow(
                            icon: Icons.verified_outlined,
                            label: 'Condition',
                            value: _formatCondition(product.condition),
                          ),
                          const SizedBox(height: 12),
                          _DetailRow(
                            icon: Icons.calendar_today_outlined,
                            label: 'Posted',
                            value: Formatters.formatDate(product.createdAt),
                          ),
                          if (product.updatedAt != product.createdAt) ...[
                            const SizedBox(height: 12),
                            _DetailRow(
                              icon: Icons.update_outlined,
                              label: 'Last Updated',
                              value: Formatters.formatDate(product.updatedAt),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Message seller feature coming soon!'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.message_outlined),
                  label: const Text('Message'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Consumer(
                  builder: (context, ref, child) {
                    final cart = ref.watch(currentUserCartProvider);

                    return cart.when(
                      data: (cartData) {
                        if (cartData == null) {
                          return ElevatedButton.icon(
                            onPressed: product.status == ProductStatus.active &&
                                    !_isAddingToCart &&
                                    !_isRemovingFromCart
                                ? _addToCart
                                : null,
                            icon: _isAddingToCart
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.shopping_cart),
                            label: Text(
                                _isAddingToCart ? 'Adding...' : 'Add to Cart'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          );
                        }

                        final cartItems =
                            ref.watch(cartItemsProvider(cartData.id));

                        return cartItems.when(
                          data: (items) {
                            final cartItem = _findCartItem(items, product.id);
                            final isInCart = cartItem != null;
                            final cartItemId = cartItem?.id ?? '';

                            return ElevatedButton.icon(
                              onPressed: product.status ==
                                          ProductStatus.active &&
                                      !_isAddingToCart &&
                                      !_isRemovingFromCart
                                  ? () {
                                      if (isInCart && cartItemId.isNotEmpty) {
                                        _removeFromCart(cartItemId);
                                      } else {
                                        _addToCart();
                                      }
                                    }
                                  : null,
                              icon: _isAddingToCart || _isRemovingFromCart
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : Icon(isInCart
                                      ? Icons.remove_shopping_cart
                                      : Icons.shopping_cart),
                              label: Text(
                                _isAddingToCart
                                    ? 'Adding...'
                                    : _isRemovingFromCart
                                        ? 'Removing...'
                                        : isInCart
                                            ? 'Remove from Cart'
                                            : 'Add to Cart',
                              ),
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: isInCart
                                    ? Colors.red
                                    : Theme.of(context).colorScheme.primary,
                              ),
                            );
                          },
                          loading: () => ElevatedButton.icon(
                            onPressed: null,
                            icon: const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            label: const Text('Loading...'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                          error: (_, __) => ElevatedButton.icon(
                            onPressed: product.status == ProductStatus.active &&
                                    !_isAddingToCart &&
                                    !_isRemovingFromCart
                                ? _addToCart
                                : null,
                            icon: _isAddingToCart
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.shopping_cart),
                            label: Text(
                                _isAddingToCart ? 'Adding...' : 'Add to Cart'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        );
                      },
                      loading: () => ElevatedButton.icon(
                        onPressed: null,
                        icon: const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        label: const Text('Loading...'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                      error: (_, __) => ElevatedButton.icon(
                        onPressed: product.status == ProductStatus.active &&
                                !_isAddingToCart &&
                                !_isRemovingFromCart
                            ? _addToCart
                            : null,
                        icon: _isAddingToCart
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Icon(Icons.shopping_cart),
                        label:
                            Text(_isAddingToCart ? 'Adding...' : 'Add to Cart'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }
}
