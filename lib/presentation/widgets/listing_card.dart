import 'package:flutter/material.dart';
import '../../data/models/listing.dart';
import '../widgets/animated_like.dart';
import '../../data/likes_service.dart';
 
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cart/cart_bloc.dart';

class ListingCard extends StatefulWidget {
  final Listing listing;
  final bool showRemove;
  const ListingCard({super.key, required this.listing, this.showRemove = false});

  @override
  State<ListingCard> createState() => _ListingCardState();
}

class _ListingCardState extends State<ListingCard> {
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _loadLiked();
  }

  void _loadLiked() async {
    final svc = await LikesService.getInstance();
    final liked = await svc.isLiked(widget.listing.id);
    if (mounted) setState(() => _isLiked = liked);
  }

  void _toggleLike() async {
    final svc = await LikesService.getInstance();
    final newVal = await svc.toggleLiked(widget.listing.id);
    if (mounted) setState(() => _isLiked = newVal);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: SizedBox(width: 60, child: Image.asset(widget.listing.imageUrl, fit: BoxFit.cover)),
        title: Text(widget.listing.title),
        subtitle: Text('\$${widget.listing.price.toStringAsFixed(2)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedLike(isLiked: _isLiked, onTap: _toggleLike),
            const SizedBox(width: 8),
            widget.showRemove
                ? IconButton(
                    icon: const Icon(Icons.delete_forever),
                    onPressed: () {
                      context.read<CartBloc>().add(RemoveFromCart(widget.listing));
                    },
                  )
                : IconButton(
                    icon: const Icon(Icons.add_shopping_cart),
                    onPressed: () {
                      context.read<CartBloc>().add(AddToCart(widget.listing));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart')));
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
