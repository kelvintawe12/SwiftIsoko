import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cart/cart_bloc.dart';
import 'chat_page.dart';
import 'checkout_page.dart';
import 'thank_you_page.dart';

import '../../core/constants/colors.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            }),
        title:
            const Text('Shopping Cart', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoaded && state.items.isEmpty) {
            return const Center(child: Text('Your cart is empty'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  separatorBuilder: (_, __) => const SizedBox(height: 18),
                  itemCount: state is CartLoaded ? state.items.length : 0,
                  itemBuilder: (ctx, i) {
                    final item = (state as CartLoaded).items[i];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                                color: const Color.fromRGBO(0, 0, 0, 0.03),
                                blurRadius: 6)
                          ]),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: SizedBox(
                                width: 72,
                                height: 72,
                                child: Image.asset(item.listing.imageUrl,
                                    fit: BoxFit.cover)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.listing.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                Text('${item.listing.views} views',
                                    style: const TextStyle(
                                        color: AppColors.textLight,
                                        fontSize: 12)),
                                const SizedBox(height: 8),
                                Text(
                                    '\$${item.listing.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // qty control
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 6),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border:
                                    Border.all(color: Colors.grey.shade300)),
                            child: Row(
                              children: [
                                InkWell(
                                    onTap: () {
                                      // decrease quantity
                                      context
                                          .read<CartBloc>()
                                          .add(DecreaseQuantity(item.listing));
                                    },
                                    child: const CircleAvatar(
                                        radius: 12,
                                        backgroundColor: Colors.white,
                                        child: Icon(Icons.remove, size: 16))),
                                const SizedBox(width: 8),
                                Text('${item.quantity}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(width: 8),
                                InkWell(
                                    onTap: () {
                                      // increase quantity
                                      context
                                          .read<CartBloc>()
                                          .add(AddToCart(item.listing));
                                    },
                                    child: const CircleAvatar(
                                        radius: 12,
                                        backgroundColor: Colors.white,
                                        child: Icon(Icons.add, size: 16))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // bottom area
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                color: AppColors.background,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // coupon pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: const [
                          Icon(Icons.local_offer_outlined,
                              color: AppColors.textLight),
                          SizedBox(width: 12),
                          Expanded(
                              child: Text('Add coupon code',
                                  style:
                                      TextStyle(color: AppColors.textLight))),
                          Icon(Icons.close, color: AppColors.textLight)
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total:',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text('Free shipping',
                                style: TextStyle(
                                    fontSize: 12, color: AppColors.textLight)),
                          ],
                        ),
                        Text(
                            '\$${state is CartLoaded ? state.total.toStringAsFixed(2) : 0} USD',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Navigation buttons row
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const ChatPage()),
                              );
                            },
                            icon: const Icon(Icons.chat, size: 18),
                            label: const Text('Chat',
                                style: TextStyle(fontSize: 14)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const CheckoutPage()),
                              );
                            },
                            icon: const Icon(Icons.shopping_cart_checkout,
                                size: 18),
                            label: const Text('Checkout',
                                style: TextStyle(fontSize: 14)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const ThankYouPage()),
                              );
                            },
                            icon: const Icon(Icons.check_circle_outline,
                                size: 18),
                            label: const Text('Thank You',
                                style: TextStyle(fontSize: 14)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<CartBloc>().add(ClearCart());
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Proceeding to checkout (mock)')));
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12))),
                        child: const Text('Proceed to Checkout',
                            style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
