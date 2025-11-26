import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swapit_marketplace/data/models/cart.dart';
import 'package:swapit_marketplace/data/models/cart_item.dart';
import 'package:swapit_marketplace/data/models/order.dart';
import 'package:uuid/uuid.dart';
import '../core/failures.dart';

import '../models/product.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Create order from cart
  Future<Either<Failure, OrderModel>> createOrder({
    required String userId,
    required String cartId,
    required ShippingAddress shippingAddress,
    String? paymentMethod,
  }) async {
    try {
      // Verify cart belongs to user
      final cartDoc = await _firestore.collection('carts').doc(cartId).get();

      if (!cartDoc.exists) {
        return const Left(NotFoundFailure('Cart not found'));
      }

      final cart = CartModel.fromFirestore(cartDoc);

      if (cart.userId != userId) {
        return const Left(PermissionFailure('Cart does not belong to user'));
      }

      if (cart.status != CartStatus.open) {
        return const Left(ValidationFailure('Cart is not open'));
      }

      // Get cart items
      final itemsSnapshot = await _firestore
          .collection('cartItems')
          .where('cartId', isEqualTo: cartId)
          .get();

      if (itemsSnapshot.docs.isEmpty) {
        return const Left(ValidationFailure('Cart is empty'));
      }

      // Calculate total and validate products
      double totalAmount = 0;
      final batch = _firestore.batch();

      for (final doc in itemsSnapshot.docs) {
        final item = CartItemModel.fromFirestore(doc);

        // Verify product exists and is available
        final productDoc =
            await _firestore.collection('products').doc(item.productId).get();

        if (!productDoc.exists) {
          return Left(NotFoundFailure('Product ${item.productName} not found'));
        }

        final product = ProductModel.fromFirestore(productDoc);

        // Prevent buying own products
        if (product.ownerId == userId) {
          return Left(ValidationFailure(
            'Cannot purchase your own product: ${product.name}',
          ));
        }

        // Check product is still in cart status
        if (product.status != ProductStatus.incart) {
          return Left(ValidationFailure(
            'Product ${product.name} is no longer available',
          ));
        }

        totalAmount += item.priceAtAdd * item.quantity;

        // Update product status to sold
        batch.update(
          _firestore.collection('products').doc(item.productId),
          {
            'status': ProductStatus.sold.name,
            'updatedAt': Timestamp.fromDate(DateTime.now()),
          },
        );
      }

      // Create order
      final orderId = _uuid.v4();
      final now = DateTime.now();

      final order = OrderModel(
        id: orderId,
        userId: userId,
        cartId: cartId,
        totalAmount: totalAmount,
        status: OrderStatus.pending,
        paymentMethod: paymentMethod,
        shippingAddress: shippingAddress,
        createdAt: now,
        updatedAt: now,
      );

      batch.set(
        _firestore.collection('orders').doc(orderId),
        order.toFirestore(),
      );

      // Update cart status to checked out
      batch.update(
        _firestore.collection('carts').doc(cartId),
        {
          'status': CartStatus.checkedOut.name,
          'updatedAt': Timestamp.fromDate(now),
        },
      );

      await batch.commit();

      return Right(order);
    } catch (e) {
      return Left(ServerFailure('Failed to create order: ${e.toString()}'));
    }
  }

  // Get user orders
  Stream<List<OrderModel>> getUserOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList());
  }

  // Get user orders without server-side ordering to avoid composite index requirements.
  Stream<List<OrderModel>> getUserOrdersNoOrder(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList());
  }

  // Get order by ID
  Future<Either<Failure, OrderModel>> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();

      if (!doc.exists) {
        return const Left(NotFoundFailure('Order not found'));
      }

      return Right(OrderModel.fromFirestore(doc));
    } catch (e) {
      return Left(ServerFailure('Failed to get order: ${e.toString()}'));
    }
  }

  // Get order items
  Future<Either<Failure, List<CartItemModel>>> getOrderItems(
      String cartId) async {
    try {
      final snapshot = await _firestore
          .collection('cartItems')
          .where('cartId', isEqualTo: cartId)
          .get();

      final items =
          snapshot.docs.map((doc) => CartItemModel.fromFirestore(doc)).toList();

      return Right(items);
    } catch (e) {
      return Left(ServerFailure('Failed to get order items: ${e.toString()}'));
    }
  }

  // Update order status
  Future<Either<Failure, void>> updateOrderStatus({
    required String orderId,
    required String userId,
    required OrderStatus status,
  }) async {
    try {
      // Verify order belongs to user
      final orderDoc = await _firestore.collection('orders').doc(orderId).get();

      if (!orderDoc.exists) {
        return const Left(NotFoundFailure('Order not found'));
      }

      final order = OrderModel.fromFirestore(orderDoc);

      if (order.userId != userId) {
        return const Left(PermissionFailure('Order does not belong to user'));
      }

      await _firestore.collection('orders').doc(orderId).update({
        'status': status.name,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // If cancelled, restore products to active status
      if (status == OrderStatus.cancelled) {
        final itemsSnapshot = await _firestore
            .collection('cartItems')
            .where('cartId', isEqualTo: order.cartId)
            .get();

        final batch = _firestore.batch();

        for (final doc in itemsSnapshot.docs) {
          final item = CartItemModel.fromFirestore(doc);
          batch.update(
            _firestore.collection('products').doc(item.productId),
            {
              'status': ProductStatus.active.name,
              'updatedAt': Timestamp.fromDate(DateTime.now()),
            },
          );
        }

        await batch.commit();
      }

      return const Right(null);
    } catch (e) {
      return Left(
          ServerFailure('Failed to update order status: ${e.toString()}'));
    }
  }

  // Cancel order
  Future<Either<Failure, void>> cancelOrder({
    required String orderId,
    required String userId,
  }) async {
    return updateOrderStatus(
      orderId: orderId,
      userId: userId,
      status: OrderStatus.cancelled,
    );
  }

  // Mark order as paid
  Future<Either<Failure, void>> markOrderAsPaid({
    required String orderId,
    required String userId,
    String? paymentMethod,
  }) async {
    try {
      // Verify order belongs to user
      final orderDoc = await _firestore.collection('orders').doc(orderId).get();

      if (!orderDoc.exists) {
        return const Left(NotFoundFailure('Order not found'));
      }

      final order = OrderModel.fromFirestore(orderDoc);

      if (order.userId != userId) {
        return const Left(PermissionFailure('Order does not belong to user'));
      }

      final updates = <String, dynamic>{
        'status': OrderStatus.paid.name,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (paymentMethod != null) {
        updates['paymentMethod'] = paymentMethod;
      }

      await _firestore.collection('orders').doc(orderId).update(updates);

      return const Right(null);
    } catch (e) {
      return Left(
          ServerFailure('Failed to mark order as paid: ${e.toString()}'));
    }
  }

  // Get seller orders (products sold by user)
  Future<Either<Failure, List<OrderModel>>> getSellerOrders(
      String sellerId) async {
    try {
      // Get all products owned by seller
      final productsSnapshot = await _firestore
          .collection('products')
          .where('ownerId', isEqualTo: sellerId)
          .where('status', isEqualTo: ProductStatus.sold.name)
          .get();

      final productIds = productsSnapshot.docs.map((doc) => doc.id).toList();

      if (productIds.isEmpty) {
        return const Right([]);
      }

      // Get cart items containing these products
      final cartItemsSnapshot = await _firestore
          .collection('cartItems')
          .where('productId', whereIn: productIds)
          .get();

      final cartIds = cartItemsSnapshot.docs
          .map((doc) => CartItemModel.fromFirestore(doc).cartId)
          .toSet()
          .toList();

      if (cartIds.isEmpty) {
        return const Right([]);
      }

      // Get orders for these carts
      final ordersSnapshot = await _firestore
          .collection('orders')
          .where('cartId', whereIn: cartIds)
          .orderBy('createdAt', descending: true)
          .get();

      final orders = ordersSnapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();

      return Right(orders);
    } catch (e) {
      return Left(
          ServerFailure('Failed to get seller orders: ${e.toString()}'));
    }
  }
}
