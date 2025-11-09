import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/listing.dart';
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
    // normalize existing items: accept either Listing (legacy) or CartItem
    final raw = currentState.items as List<dynamic>;
    final updated = raw.map<CartItem>((e) {
      if (e is CartItem) return e;
      // legacy: item might be a Listing
      return CartItem(listing: e as Listing, quantity: 1);
    }).toList();
    final idx = updated.indexWhere((ci) => ci.listing.id == event.listing.id);
    if (idx >= 0) {
      final existing = updated[idx];
      updated[idx] = existing.copyWith(quantity: existing.quantity + 1);
    } else {
      updated.add(CartItem(listing: event.listing, quantity: 1));
    }
    emit(CartLoaded(items: updated));
  }

  void _onRemoveFromCart(RemoveFromCart event, Emitter<CartState> emit) {
    final currentState = state is CartLoaded ? state as CartLoaded : const CartLoaded(items: []);
  final raw2 = currentState.items as List<dynamic>;
  final normalized = raw2.map<CartItem>((e) => e is CartItem ? e : CartItem(listing: e as Listing, quantity: 1)).toList();
    final updated = normalized.where((ci) => ci.listing.id != event.listing.id).toList();
    emit(CartLoaded(items: updated));
  }

  void _onDecreaseQuantity(DecreaseQuantity event, Emitter<CartState> emit) {
  final currentState = state is CartLoaded ? state as CartLoaded : const CartLoaded(items: []);
  final raw3 = currentState.items as List<dynamic>;
  final updated = raw3.map<CartItem>((e) => e is CartItem ? e : CartItem(listing: e as Listing, quantity: 1)).toList();
  final idx = updated.indexWhere((ci) => ci.listing.id == event.listing.id);
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
