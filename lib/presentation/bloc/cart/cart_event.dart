part of 'cart_bloc.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object> get props => [];
}

class AddToCart extends CartEvent {
  final Product product;
  const AddToCart(this.product);
  @override
  List<Object> get props => [product];
}

class RemoveFromCart extends CartEvent {
  final Product product;
  const RemoveFromCart(this.product);
  @override
  List<Object> get props => [product];
}

class ClearCart extends CartEvent {}

class DecreaseQuantity extends CartEvent {
  final Product product;
  const DecreaseQuantity(this.product);
  @override
  List<Object> get props => [product];
}
