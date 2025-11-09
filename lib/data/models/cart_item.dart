import 'listing.dart';

class CartItem {
  final Listing listing;
  final int quantity;

  const CartItem({required this.listing, this.quantity = 1});

  CartItem copyWith({Listing? listing, int? quantity}) {
    return CartItem(listing: listing ?? this.listing, quantity: quantity ?? this.quantity);
  }
}
