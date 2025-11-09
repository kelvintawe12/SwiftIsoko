part of 'cart_bloc.dart';

abstract class CartState extends Equatable {
  const CartState();
  @override
  List<Object> get props => [];
}

class CartInitial extends CartState {}
class CartLoaded extends CartState {
  final List<CartItem> items;
  const CartLoaded({this.items = const []});
  double get total => items.fold(0.0, (sum, item) => sum + item.listing.price * item.quantity);
  @override
  List<Object> get props => [items];
}
