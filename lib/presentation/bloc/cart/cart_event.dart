part of 'cart_bloc.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object> get props => [];
}

class AddToCart extends CartEvent {
  final Listing listing;
  const AddToCart(this.listing);
  @override
  List<Object> get props => [listing];
}

class RemoveFromCart extends CartEvent {
  final Listing listing;
  const RemoveFromCart(this.listing);
  @override
  List<Object> get props => [listing];
}

class ClearCart extends CartEvent {}

class DecreaseQuantity extends CartEvent {
  final Listing listing;
  const DecreaseQuantity(this.listing);
  @override
  List<Object> get props => [listing];
}
