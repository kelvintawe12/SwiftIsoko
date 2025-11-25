import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swapit_marketplace/data/models/cart.dart';
import 'package:swapit_marketplace/data/models/cart_item.dart';
import 'package:swapit_marketplace/data/models/product.dart';
import 'package:uuid/uuid.dart';
import '../core/failures.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Get or create cart for user
  Future<Either<Failure, CartModel>> getOrCreateCart(String userId) async {
    try {
      // Check for existing open cart
      final snapshot = await _firestore
          .collection('carts')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: CartStatus.open.name)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return Right(CartModel.fromFirestore(snapshot.docs.first));
      }

      // Create new cart
      final cartId = _uuid.v4();
      final now = DateTime.now();

      final cart = CartModel(
        id: cartId,
        userId: userId,
        status: CartStatus.open,
        createdAt: now,
        updatedAt: now,
      );

      await _firestore.collection('carts').doc(cartId).set(cart.toFirestore());

      return Right(cart);
    } catch (e) {
      return Left(ServerFailure('Failed to get/create cart: ${e.toString()}'));
    }
  }

  // Get cart items
  Stream<List<CartItemModel>> getCartItems(String cartId) {
    return _firestore
        .collection('cartItems')
        .where('cartId', isEqualTo: cartId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CartItemModel.fromFirestore(doc))
            .toList());
  }

  // Add item to cart
  Future<Either<Failure, CartItemModel>> addItemToCart({
    required String userId,
    required String productId,
    required String productName,
    required double price,
    int quantity = 1,
  }) async {
    try {
      // Get or create cart
      final cartResult = await getOrCreateCart(userId);

      if (cartResult.isLeft()) {
        return Left((cartResult as Left).value);
      }

      final cart = (cartResult as Right<Failure, CartModel>).value;

      // Check if product is already in cart
      final existingItems = await _firestore
          .collection('cartItems')
          .where('cartId', isEqualTo: cart.id)
          .where('productId', isEqualTo: productId)
          .limit(1)
          .get();

      if (existingItems.docs.isNotEmpty) {
        return const Left(ValidationFailure('Product already in cart'));
      }

      // Create cart item
      final itemId = _uuid.v4();
      final cartItem = CartItemModel(
        id: itemId,
        cartId: cart.id,
        productId: productId,
        productName: productName,
        priceAtAdd: price,
        quantity: quantity,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('cartItems')
          .doc(itemId)
          .set(cartItem.toFirestore());

      // Update product status to incart
      await _firestore.collection('products').doc(productId).update({
        'status': ProductStatus.incart.name,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // Update cart timestamp
      await _firestore.collection('carts').doc(cart.id).update({
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      return Right(cartItem);
    } catch (e) {
      return Left(ServerFailure('Failed to add item to cart: ${e.toString()}'));
    }
  }

  // Remove item from cart
  Future<Either<Failure, void>> removeItemFromCart({
    required String cartItemId,
    required String productId,
  }) async {
    try {
      // Delete cart item
      await _firestore.collection('cartItems').doc(cartItemId).delete();

      // Update product status back to active
      await _firestore.collection('products').doc(productId).update({
        'status': ProductStatus.active.name,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to remove item: ${e.toString()}'));
    }
  }

  // Update item quantity
  Future<Either<Failure, void>> updateItemQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    try {
      if (quantity <= 0) {
        return const Left(ValidationFailure('Quantity must be greater than 0'));
      }

      await _firestore.collection('cartItems').doc(cartItemId).update({
        'quantity': quantity,
      });

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to update quantity: ${e.toString()}'));
    }
  }

  // Clear cart
  Future<Either<Failure, void>> clearCart(String cartId) async {
    try {
      // Get all cart items
      final snapshot = await _firestore
          .collection('cartItems')
          .where('cartId', isEqualTo: cartId)
          .get();

      // Delete all items and update product statuses
      final batch = _firestore.batch();

      for (final doc in snapshot.docs) {
        final item = CartItemModel.fromFirestore(doc);

        // Delete cart item
        batch.delete(doc.reference);

        // Update product status
        batch.update(
          _firestore.collection('products').doc(item.productId),
          {
            'status': ProductStatus.active.name,
            'updatedAt': Timestamp.fromDate(DateTime.now()),
          },
        );
      }

      await batch.commit();

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to clear cart: ${e.toString()}'));
    }
  }

  // Get cart total
  Future<Either<Failure, double>> getCartTotal(String cartId) async {
    try {
      final snapshot = await _firestore
          .collection('cartItems')
          .where('cartId', isEqualTo: cartId)
          .get();

      double total = 0;
      for (final doc in snapshot.docs) {
        final item = CartItemModel.fromFirestore(doc);
        total += item.priceAtAdd * item.quantity;
      }

      return Right(total);
    } catch (e) {
      return Left(ServerFailure('Failed to calculate total: ${e.toString()}'));
    }
  }

  // Update cart status
  Future<Either<Failure, void>> updateCartStatus({
    required String cartId,
    required CartStatus status,
  }) async {
    try {
      await _firestore.collection('carts').doc(cartId).update({
        'status': status.name,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      return const Right(null);
    } catch (e) {
      return Left(
          ServerFailure('Failed to update cart status: ${e.toString()}'));
    }
  }

  // Check if product is in any user's cart
  Future<Either<Failure, bool>> isProductInCart(String productId) async {
    try {
      final snapshot = await _firestore
          .collection('cartItems')
          .where('productId', isEqualTo: productId)
          .limit(1)
          .get();

      return Right(snapshot.docs.isNotEmpty);
    } catch (e) {
      return Left(ServerFailure('Failed to check product: ${e.toString()}'));
    }
  }
}
