import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:swapit_marketplace/data/providers/providers.dart';
import 'package:swapit_marketplace/data/services/product_services.dart';
import '../core/failures.dart';
import 'package:swapit_marketplace/data/services/auth_services.dart';
import 'package:swapit_marketplace/data/services/cart_services.dart';
import 'package:swapit_marketplace/data/services/cloudinary_services.dart';
import 'package:swapit_marketplace/data/services/order_services.dart';

import '../models/order.dart';
import '../models/product.dart';
import '../services/user_services.dart';

// Auth State Notifier
class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AsyncValue.data(null));

  Future<Either<Failure, void>> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    state = const AsyncValue.loading();

    final result = await _authService.signUpWithEmail(
      email: email,
      password: password,
      name: name,
    );

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return Left(failure);
      },
      (userCredential) {
        state = const AsyncValue.data(null);
        return const Right(null);
      },
    );
  }

  Future<Either<Failure, void>> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    final result = await _authService.signInWithEmail(
      email: email,
      password: password,
    );

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return Left(failure);
      },
      (userCredential) {
        state = const AsyncValue.data(null);
        return const Right(null);
      },
    );
  }

  Future<Either<Failure, void>> signInWithGoogle() async {
    state = const AsyncValue.loading();

    final result = await _authService.signInWithGoogle();

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return Left(failure);
      },
      (userCredential) {
        state = const AsyncValue.data(null);
        return const Right(null);
      },
    );
  }

  Future<Either<Failure, void>> signOut() async {
    state = const AsyncValue.loading();

    final result = await _authService.signOut();

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return Left(failure);
      },
      (_) {
        state = const AsyncValue.data(null);
        return const Right(null);
      },
    );
  }

  Future<Either<Failure, void>> resetPassword(String email) async {
    return _authService.resetPassword(email);
  }

  Future<Either<Failure, void>> resendVerificationEmail() async {
    return _authService.resendVerificationEmail();
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

// Product Creation Notifier
class ProductCreationNotifier extends StateNotifier<AsyncValue<ProductModel?>> {
  final ProductService _productService;
  final CloudinaryService _cloudinaryService;

  ProductCreationNotifier(this._productService, this._cloudinaryService)
      : super(const AsyncValue.data(null));

  Future<Either<Failure, ProductModel>> createProduct({
    required String name,
    required List<File> images,
    required String category,
    required String description,
    required ProductCondition condition,
    required double price,
    required String currency,
    required String ownerId,
    required String ownerName,
  }) async {
    state = const AsyncValue.loading();

    // Upload images to Cloudinary
    final uploadResult = await _cloudinaryService.uploadImages(images);

    return uploadResult.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return Left(failure);
      },
      (imageUrls) async {
        // Create product
        final result = await _productService.createProduct(
          name: name,
          imageUrls: imageUrls,
          category: category,
          description: description,
          condition: condition,
          price: price,
          currency: currency,
          ownerId: ownerId,
          ownerName: ownerName,
        );

        return result.fold(
          (failure) {
            state = AsyncValue.error(failure.message, StackTrace.current);
            return Left(failure);
          },
          (product) {
            state = AsyncValue.data(product as ProductModel?);
            return Right(product);
          },
        );
      },
    );
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final productCreationNotifierProvider =
    StateNotifierProvider<ProductCreationNotifier, AsyncValue<ProductModel?>>(
        (ref) {
  final productService = ref.watch(productServiceProvider);
  final cloudinaryService = ref.watch(cloudinaryServiceProvider);
  return ProductCreationNotifier(productService, cloudinaryService);
});

// Cart Notifier
class CartNotifier extends StateNotifier<AsyncValue<void>> {
  final CartService _cartService;
  final Ref _ref;

  CartNotifier(this._cartService, this._ref)
      : super(const AsyncValue.data(null));

  Future<Either<Failure, void>> addToCart({
    required String userId,
    required String productId,
    required String productName,
    required double price,
  }) async {
    state = const AsyncValue.loading();

    final result = await _cartService.addItemToCart(
      userId: userId,
      productId: productId,
      productName: productName,
      price: price,
    );

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return Left(failure);
      },
      (_) {
        state = const AsyncValue.data(null);
        // Invalidate cart to refresh
        _ref.invalidate(currentUserCartProvider);
        return const Right(null);
      },
    );
  }

  Future<Either<Failure, void>> removeFromCart({
    required String cartItemId,
    required String productId,
  }) async {
    state = const AsyncValue.loading();

    final result = await _cartService.removeItemFromCart(
      cartItemId: cartItemId,
      productId: productId,
    );

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return Left(failure);
      },
      (_) {
        state = const AsyncValue.data(null);
        _ref.invalidate(currentUserCartProvider);
        return const Right(null);
      },
    );
  }

  Future<Either<Failure, void>> updateQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    final result = await _cartService.updateItemQuantity(
      cartItemId: cartItemId,
      quantity: quantity,
    );

    result.fold(
      (_) {},
      (_) => _ref.invalidate(currentUserCartProvider),
    );

    return result;
  }

  Future<Either<Failure, void>> clearCart(String cartId) async {
    state = const AsyncValue.loading();

    final result = await _cartService.clearCart(cartId);

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return Left(failure);
      },
      (_) {
        state = const AsyncValue.data(null);
        _ref.invalidate(currentUserCartProvider);
        return const Right(null);
      },
    );
  }
}

final cartNotifierProvider =
    StateNotifierProvider<CartNotifier, AsyncValue<void>>((ref) {
  final cartService = ref.watch(cartServiceProvider);
  return CartNotifier(cartService, ref);
});

// Order Notifier
class OrderNotifier extends StateNotifier<AsyncValue<OrderModel?>> {
  final OrderService _orderService;
  final Ref _ref;

  OrderNotifier(this._orderService, this._ref)
      : super(const AsyncValue.data(null));

  Future<Either<Failure, OrderModel>> createOrder({
    required String userId,
    required String cartId,
    required ShippingAddress shippingAddress,
    String? paymentMethod,
  }) async {
    state = const AsyncValue.loading();

    final result = await _orderService.createOrder(
      userId: userId,
      cartId: cartId,
      shippingAddress: shippingAddress,
      paymentMethod: paymentMethod,
    );

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return Left(failure);
      },
      (order) {
        state = AsyncValue.data(order as OrderModel?);
        // Invalidate cart and orders
        _ref.invalidate(currentUserCartProvider);
        _ref.invalidate(userOrdersProvider);
        return Right(order);
      },
    );
  }

  Future<Either<Failure, void>> cancelOrder({
    required String orderId,
    required String userId,
  }) async {
    final result = await _orderService.cancelOrder(
      orderId: orderId,
      userId: userId,
    );

    result.fold(
      (_) {},
      (_) => _ref.invalidate(userOrdersProvider),
    );

    return result;
  }

  Future<Either<Failure, void>> markAsPaid({
    required String orderId,
    required String userId,
    String? paymentMethod,
  }) async {
    final result = await _orderService.markOrderAsPaid(
      orderId: orderId,
      userId: userId,
      paymentMethod: paymentMethod,
    );

    result.fold(
      (_) {},
      (_) => _ref.invalidate(userOrdersProvider),
    );

    return result;
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final orderNotifierProvider =
    StateNotifierProvider<OrderNotifier, AsyncValue<OrderModel?>>((ref) {
  final orderService = ref.watch(orderServiceProvider);
  return OrderNotifier(orderService, ref);
});

// // Profile Update Notifier
// class ProfileUpdateNotifier extends StateNotifier<AsyncValue<void>> {
//   final UserService _userService;
//   final CloudinaryService _cloudinaryService;

//   ProfileUpdateNotifier(this._userService, this._cloudinaryService)
//       : super(const AsyncValue.data(null));

//   Future<Either<Failure, void>> updateProfile({
//     required String uid,
//     String? name,
//     String? phoneNumber,
//     File? profileImage,
//     String? bio,
//     String? location,
//   }) async {
//     state = const AsyncValue.loading();

//     String? profileImageUrl;

//     // Upload profile image if provided
//     if (profileImage != null) {
//       final uploadResult = await _cloudinaryService.uploadProfileImage(profileImage);

//       final urlResult = uploadResult.fold(
//         (failure) => Left(failure),
//         (url) {
//           profileImageUrl = url;
//           return const Right(null);
//         },
//       );

//       if (urlResult.isLeft()) {
//         state = AsyncValue.error(
//           (urlResult as Left).value.message,
//           StackTrace.current,
//         );
//         return Left((urlResult as Left<Failure, void>).value);
//       }
//     }

//     final result = await _userService.updateUserProfile(
//       uid: uid,
//       name: name,
//       phoneNumber: phoneNumber,
//       profileImageUrl: profileImageUrl,
//       bio: bio,
//       location: location,
//     );

//     return result.fold(
//       (failure) {
//         state = AsyncValue.error(failure.message, StackTrace.current);
//         return Left(failure);
//       },
//       (_) {
//         state = const AsyncValue.data(null);
//         return const Right(null);
//       },
//     );
// }

// final profileUpdateNotifierProvider = StateNotifierProvider<
//     ProfileUpdateNotifier,
//     AsyncValue<void>
// >((ref) {
//   final userService = ref.watch(userServiceProvider);
//   final cloudinaryService = ref.watch(cloudinaryServiceProvider);
//   return ProfileUpdateNotifier(userService, cloudinaryService);
// });

// Profile Update Notifier
class ProfileUpdateNotifier extends StateNotifier<AsyncValue<void>> {
  final UserService _userService;
  final CloudinaryService _cloudinaryService;

  ProfileUpdateNotifier(this._userService, this._cloudinaryService)
      : super(const AsyncValue.data(null));

  Future<Either<Failure, void>> updateProfile({
    required String uid,
    String? name,
    String? phoneNumber,
    File? profileImage,
    String? bio,
    String? location,
  }) async {
    state = const AsyncValue.loading();

    String? profileImageUrl;

    // Upload profile image if provided
    if (profileImage != null) {
      final uploadResult =
          await _cloudinaryService.uploadProfileImage(profileImage);

      // ❗ Correctly handle fold result
      final urlResult = uploadResult.fold<Either<Failure, void>>(
        (failure) => Left(failure),
        (url) {
          profileImageUrl = url;
          return const Right(null);
        },
      );

      if (urlResult.isLeft()) {
        final failure = (urlResult as Left<Failure, void>).value;

        state = AsyncValue.error(failure.message, StackTrace.current);
        return Left(failure);
      }
    }

    final result = await _userService.updateUserProfile(
      uid: uid,
      name: name,
      phoneNumber: phoneNumber,
      profileImageUrl: profileImageUrl,
      bio: bio,
      location: location,
    );

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return Left(failure);
      },
      (_) {
        state = const AsyncValue.data(null);
        return const Right(null);
      },
    );
  }
}

final profileUpdateNotifierProvider =
    StateNotifierProvider<ProfileUpdateNotifier, AsyncValue<void>>((ref) {
  final userService = ref.watch(userServiceProvider);
  final cloudinaryService = ref.watch(cloudinaryServiceProvider);
  return ProfileUpdateNotifier(userService, cloudinaryService);
});
