import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swapit_marketplace/data/models/cart.dart';
import 'package:swapit_marketplace/data/models/cart_item.dart';
import 'package:swapit_marketplace/data/models/chat.dart';
import 'package:swapit_marketplace/data/models/message.dart';
import 'package:swapit_marketplace/data/models/order.dart';
import 'package:swapit_marketplace/data/models/person.dart';
import 'package:swapit_marketplace/data/models/person_rating_model.dart';
import 'package:swapit_marketplace/data/models/product.dart';
import 'package:swapit_marketplace/data/models/reviews.dart';
import 'package:swapit_marketplace/data/services/auth_services.dart';
import 'package:swapit_marketplace/data/services/cart_services.dart';
import 'package:swapit_marketplace/data/services/cloudinary_services.dart';
import 'package:swapit_marketplace/data/services/order_services.dart';
import 'package:swapit_marketplace/data/services/review_and_chat_services.dart';
import 'package:swapit_marketplace/data/services/favorite_services.dart';
import '../services/user_services.dart';
import '../services/product_services.dart';

// Service Providers
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final userServiceProvider = Provider<UserService>((ref) => UserService());
final productServiceProvider =
    Provider<ProductService>((ref) => ProductService());
final cartServiceProvider = Provider<CartService>((ref) => CartService());
final orderServiceProvider = Provider<OrderService>((ref) => OrderService());
final reviewServiceProvider = Provider<ReviewService>((ref) => ReviewService());
final chatServiceProvider = Provider<ChatService>((ref) => ChatService());
final favoriteServiceProvider = Provider<FavoriteService>((ref) => FavoriteService());
final cloudinaryServiceProvider =
    Provider<CloudinaryService>((ref) => CloudinaryService());

// Saved / Favorites Providers
// savedProductIdsProvider: reads `savedProductIds` field from user document
final savedProductIdsProvider = FutureProvider.family<List<String>, String>((ref, userId) async {
  final userService = ref.watch(userServiceProvider);
  final result = await userService.getSavedProductIds(userId);
  return result.fold((_) => <String>[], (ids) => ids);
});

// favorites subcollection stream: returns list of productIds
final favoritesSubcollectionProvider = StreamProvider.family<List<String>, String>((ref, userId) {
  final favService = ref.watch(favoriteServiceProvider);
  return favService.getFavoritesProductIdsStream(userId);
});

// Resolve saved product ids to actual ProductModel list (user doc)
final savedProductsProvider = FutureProvider.family.autoDispose<List<ProductModel>, String>((ref, userId) async {
  final ids = await ref.watch(savedProductIdsProvider(userId).future);
  if (ids.isEmpty) return [];
  final productService = ref.watch(productServiceProvider);
  final results = await Future.wait(ids.map((id) => productService.getProductById(id)));
  final products = <ProductModel>[];
  for (final r in results) {
    r.fold((_) {}, (p) => products.add(p));
  }
  return products;
});

// Resolve favorites subcollection ids to actual ProductModel list
final favoritesSubcollectionProductsProvider = FutureProvider.family.autoDispose<List<ProductModel>, String>((ref, userId) async {
  final ids = await ref.watch(favoritesSubcollectionProvider(userId).future);
  if (ids.isEmpty) return [];
  final productService = ref.watch(productServiceProvider);
  final results = await Future.wait(ids.map((id) => productService.getProductById(id)));
  final products = <ProductModel>[];
  for (final r in results) {
    r.fold((_) {}, (p) => products.add(p));
  }
  return products;
});

// Saved IDs Notifier - manages user's savedProductIds field (quick option)
class SavedIdsNotifier extends StateNotifier<AsyncValue<List<String>>> {
  final Ref ref;
  final String userId;

  SavedIdsNotifier(this.ref, this.userId) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    final userService = ref.read(userServiceProvider);
    final res = await userService.getSavedProductIds(userId);
    state = res.fold((_) => const AsyncValue.data(<String>[]), (ids) => AsyncValue.data(ids));
  }

  bool isSaved(String productId) {
    return state.asData?.value.contains(productId) ?? false;
  }

  Future<void> toggleSave(String productId) async {
    final userService = ref.read(userServiceProvider);
    final currentlySaved = isSaved(productId);
    // Optimistically update UI
    final currentList = List<String>.from(state.asData?.value ?? []);
    final updated = currentlySaved ? (currentList..remove(productId)) : (currentList..add(productId));
    state = AsyncValue.data(List<String>.from(updated));

    final result = currentlySaved
        ? await userService.removeSavedProductId(userId, productId)
        : await userService.addSavedProductId(userId, productId);

    result.fold((failure) async {
      // revert on failure
      await _load();
    }, (_) {
      // nothing else; state already updated
    });
  }
}

final savedIdsNotifierProvider = StateNotifierProvider.family<SavedIdsNotifier, AsyncValue<List<String>>, String>((ref, userId) {
  return SavedIdsNotifier(ref, userId);
});

// Auth State Provider
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Current User Provider
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) {
      if (user == null) {
        return Stream.value(null);
      }
      final userService = ref.watch(userServiceProvider);
      return userService.getUserStream(user.uid);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

// Current User ID Provider
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(
    data: (user) => user?.uid,
    orElse: () => null,
  );
});

// User Products Provider
final userProductsProvider = StreamProvider.family<List<ProductModel>, String>(
  (ref, userId) {
    final productService = ref.watch(productServiceProvider);
    // Use no-order variant to avoid composite index requirements on Firestore.
    return productService.getUserProductsNoOrder(userId);
  },
);

// Products Stream Provider
final productsStreamProvider =
    StreamProvider.autoDispose<List<ProductModel>>((ref) {
  final productService = ref.watch(productServiceProvider);
  return productService.getProductsStream(
    status: ProductStatus.active,
    limit: 50,
  );
});

// Hero Products (first 6) for top slideshow
final heroProductsProvider = StreamProvider.autoDispose<List<ProductModel>>((ref) {
  final productService = ref.watch(productServiceProvider);
  return productService.getProductsStream(status: ProductStatus.active, limit: 6);
});

// Products by Category Provider
final productsByCategoryProvider = StreamProvider.family
    .autoDispose<List<ProductModel>, String>((ref, category) {
  final productService = ref.watch(productServiceProvider);
  return productService.getProductsStream(
    category: category,
    status: ProductStatus.active,
    limit: 50,
  );
});

// Single Product Provider
final productProvider = FutureProvider.family.autoDispose<ProductModel, String>(
  (ref, productId) async {
    final productService = ref.watch(productServiceProvider);
    final result = await productService.getProductById(productId);

    return result.fold(
      (failure) => throw Exception(failure.message),
      (product) => product,
    );
  },
);

// Current User Cart Provider
final currentUserCartProvider =
    FutureProvider.autoDispose<CartModel?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) {
    return null;
  }

  final cartService = ref.watch(cartServiceProvider);
  final result = await cartService.getOrCreateCart(userId);

  return result.fold(
    (failure) => null,
    (cart) => cart,
  );
});

// Cart Items Provider
final cartItemsProvider = StreamProvider.family
    .autoDispose<List<CartItemModel>, String>((ref, cartId) {
  final cartService = ref.watch(cartServiceProvider);
  return cartService.getCartItems(cartId);
});

// Cart Total Provider
final cartTotalProvider = FutureProvider.family.autoDispose<double, String>(
  (ref, cartId) async {
    final cartService = ref.watch(cartServiceProvider);
    final result = await cartService.getCartTotal(cartId);

    return result.fold(
      (failure) => 0.0,
      (total) => total,
    );
  },
);

// User Orders Provider
final userOrdersProvider = StreamProvider.autoDispose<List<OrderModel>>((ref) {
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) {
    return Stream.value([]);
  }

  final orderService = ref.watch(orderServiceProvider);
  // Use no-order variant and perform client-side sorting where needed to avoid
  // Firestore composite index requirements.
  return orderService.getUserOrdersNoOrder(userId);
});

// Single Order Provider
final orderProvider = FutureProvider.family.autoDispose<OrderModel, String>(
  (ref, orderId) async {
    final orderService = ref.watch(orderServiceProvider);
    final result = await orderService.getOrderById(orderId);

    return result.fold(
      (failure) => throw Exception(failure.message),
      (order) => order,
    );
  },
);

// Product Reviews Provider
final productReviewsProvider = StreamProvider.family
    .autoDispose<List<ReviewModel>, String>((ref, productId) {
  final reviewService = ref.watch(reviewServiceProvider);
  return reviewService.getProductReviews(productId);
});

// User Ratings Provider
final userRatingsProvider = StreamProvider.family
    .autoDispose<List<UserRatingModel>, String>((ref, userId) {
  final reviewService = ref.watch(reviewServiceProvider);
  return reviewService.getUserRatings(userId);
});

// User Chats Provider
final userChatsProvider = StreamProvider.autoDispose<List<ChatModel>>((ref) {
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) {
    return Stream.value([]);
  }

  final chatService = ref.watch(chatServiceProvider);
  return chatService.getUserChats(userId);
});

// Chat Messages Provider
final chatMessagesProvider = StreamProvider.family
    .autoDispose<List<MessageModel>, String>((ref, chatId) {
  final chatService = ref.watch(chatServiceProvider);
  return chatService.getChatMessages(chatId);
});

// Search Query State Provider
final searchQueryProvider = StateProvider<String>((ref) => '');

// Selected Category Provider
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// Product Categories Provider
final productCategoriesProvider = Provider<List<String>>((ref) {
  return [
    'Fashion',
    'Furniture',
    'Accessories',
    'Sports',
    'Books',
    'Toys',
    'Beauty',
    'Electronics',
    'Others',
  ];
});
