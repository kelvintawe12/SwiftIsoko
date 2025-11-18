import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/product.dart';
import '../../../data/models/cart_item.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(CartInitial()) {
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<DecreaseQuantity>(_onDecreaseQuantity);
    on<ClearCart>(_onClearCart);
  }

  void _onAddToCart(AddToCart event, Emitter<CartState> emit) {
    final currentState = state is CartLoaded ? state as CartLoaded : const CartLoaded(items: []);
    final updated = List<CartItem>.from(currentState.items);
    final idx = updated.indexWhere((ci) => ci.productId == event.product.id);
    if (idx >= 0) {
      final existing = updated[idx];
      updated[idx] = existing.copyWith(quantity: existing.quantity + 1);
    } else {
      updated.add(CartItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        cartId: 'default',
        productId: event.product.id,
        productName: event.product.name,
        priceAtAdd: event.product.price,
        quantity: 1,
        createdAt: DateTime.now(),
        product: event.product,
      ));
    }
    emit(CartLoaded(items: updated));
  }

  void _onRemoveFromCart(RemoveFromCart event, Emitter<CartState> emit) {
    final currentState = state is CartLoaded ? state as CartLoaded : const CartLoaded(items: []);
    final updated = currentState.items.where((ci) => ci.productId != event.product.id).toList();
    emit(CartLoaded(items: updated));
  }

  void _onDecreaseQuantity(DecreaseQuantity event, Emitter<CartState> emit) {
    final currentState = state is CartLoaded ? state as CartLoaded : const CartLoaded(items: []);
    final updated = List<CartItem>.from(currentState.items);
    final idx = updated.indexWhere((ci) => ci.productId == event.product.id);
    if (idx >= 0) {
      final existing = updated[idx];
      if (existing.quantity > 1) {
        updated[idx] = existing.copyWith(quantity: existing.quantity - 1);
      } else {
        updated.removeAt(idx);
      }
    }
    emit(CartLoaded(items: updated));
  }

  void _onClearCart(ClearCart event, Emitter<CartState> emit) {
    emit(const CartLoaded(items: []));
  }
}
