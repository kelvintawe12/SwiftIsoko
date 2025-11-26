import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/colors.dart';
import '../../data/providers/providers.dart';
import '../../data/models/order.dart';
// cart item model is fetched via providers; no direct type import required here
import '../../pages/cart_page.dart';

class OrderDetailsPage extends ConsumerWidget {
  final String orderId;

  const OrderDetailsPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderProvider(orderId));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Order Details', style: TextStyle(color: AppColors.textDark)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: orderAsync.when(
        data: (order) {
          final cartItemsAsync = ref.watch(cartItemsProvider(order.cartId));

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order ID: ${order.id}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(DateFormat.yMMMd().add_jm().format(order.createdAt), style: const TextStyle(fontSize: 13, color: AppColors.textLight)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Chip(
                      label: Text(order.status.name.toUpperCase()),
                      backgroundColor: order.status == OrderStatus.paid
                          ? AppColors.primary.withAlpha((0.12 * 255).round())
                          : Colors.orange.withAlpha((0.12 * 255).round()),
                      labelStyle: TextStyle(color: order.status == OrderStatus.paid ? AppColors.primary : Colors.orange),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Shipping Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(order.shippingAddress.name),
                Text(order.shippingAddress.location),
                Text(order.shippingAddress.phone),
                const SizedBox(height: 20),
                const Text('Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                cartItemsAsync.when(
                  data: (items) {
                    final subtotal = items.fold<double>(0.0, (sum, it) => sum + it.priceAtAdd * it.quantity);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final it in items)
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 6.0),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.03 * 255).round()), blurRadius: 6)],
                            ),
                            child: Row(
                              children: [
                                Builder(builder: (context) {
                                  final productAsync = ref.watch(productProvider(it.productId));
                                  return productAsync.when(
                                    data: (product) {
                                      final imageUrl = product.imageUrls.isNotEmpty ? product.imageUrls.first : null;
                                      if (imageUrl != null && imageUrl.isNotEmpty) {
                                        return ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            imageUrl,
                                            width: 56,
                                            height: 56,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Container(
                                              width: 56,
                                              height: 56,
                                              color: Colors.grey.shade200,
                                              child: const Icon(Icons.image_not_supported, color: AppColors.textLight),
                                            ),
                                          ),
                                        );
                                      }
                                      return CircleAvatar(
                                        radius: 28,
                                        backgroundColor: Colors.grey.shade200,
                                        child: Text(
                                          (product.name).isNotEmpty ? product.name[0].toUpperCase() : '?',
                                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
                                        ),
                                      );
                                    },
                                    loading: () => Container(
                                      width: 56,
                                      height: 56,
                                      alignment: Alignment.center,
                                      child: const CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                    error: (_, __) => CircleAvatar(
                                      radius: 28,
                                      backgroundColor: Colors.grey.shade200,
                                      child: Text(
                                        (it.productName ?? it.productId).isNotEmpty ? (it.productName ?? it.productId)[0].toUpperCase() : '?',
                                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
                                      ),
                                    ),
                                  );
                                }),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(it.productName ?? it.productId, style: const TextStyle(fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 6),
                                      Text('Qty: ${it.quantity}', style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Text('\$${(it.priceAtAdd * it.quantity).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                            Text('\$${subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.primary)),
                          ],
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Text('Failed to load items: $e'),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const CartPage()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('Back to Cart'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Failed to load order: $err')),
      ),
    );
  }
}
