import 'package:flutter/material.dart';
import '../../data/models/listing.dart';
 
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cart/cart_bloc.dart';

class ListingCard extends StatelessWidget {
  final Listing listing;
  final bool showRemove;
  const ListingCard({super.key, required this.listing, this.showRemove = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: SizedBox(width: 60, child: Image.asset(listing.imageUrl, fit: BoxFit.cover)),
        title: Text(listing.title),
        subtitle: Text('\$${listing.price.toStringAsFixed(2)}'),
        trailing: showRemove
            ? IconButton(
                icon: const Icon(Icons.delete_forever),
                onPressed: () {
                  context.read<CartBloc>().add(RemoveFromCart(listing));
                },
              )
            : IconButton(
                icon: const Icon(Icons.add_shopping_cart),
                onPressed: () {
                  context.read<CartBloc>().add(AddToCart(listing));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart')));
                },
              ),
      ),
    );
  }
}
