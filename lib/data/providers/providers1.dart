// // Import Model entities
// import '../models/product.dart';
// import '../models/person.dart';
// import '../models/person_rating_model.dart';
// import '../models/cart.dart';
// import '../models/cart_item.dart';
// import '../models/order.dart';
// import '../models/message.dart';
// import '../models/chat.dart';

// // For state management
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// // For Firebase Authentication
// import 'package:firebase_auth/firebase_auth.dart';

// // For Firebase firestore
// import 'package:cloud_firestore/cloud_firestore.dart';

// // Import Firebase CRUD Operations
// import '../services/auth_services.dart';
// import '../services/person_services.dart';

// /// Service providers
// // Creates one instance of authservice and makes it available everywhere
// final authServiceProvider = Provider<AuthService>((ref) => AuthService());
// final userServiceProvider = Provider<UserService>((ref) => UserService());

// // Listens to Firebase login/logout events in real-time
// final authStateProvider = StreamProvider<User?>((ref) {
//   return FirebaseAuth.instance.authStateChanges();
// });

// // Current User Profile Provider
// final currentUserProfile = StreamProvider<Person?>((ref) {
//   final authState = ref.watch(authStateProvider);
//   return authState.when(
//     data: (user) {
//       if (user == null) Stream.value(null);
//       return FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .snapshots()
//           .map((doc) => doc.exists ? Person.fromMap(doc) : null);
//     },
//     loading: () => Stream.value(null),
//     error: (_, __) => Stream.value(null),
//   );
// });

// // All available products and ensure they are tied to riverpod
// final myProductsProvider = StreamProvider<List<Product>>((ref) {
//   final authState = ref.watch(authStateProvider);

//   return authState.when(
//     data: (Product) {
//       if (Product == null) return Stream.value([]);
//       return FirebaseFirestore.instance
//           .collection('products')
//           .where('ownerId', isEqualTo: User.uid)
//           .orderBy('createdAt', descending: true)
//           .snapshots()
//           .map((snapshot) {
//         return snapshot.docs.map((doc) => Product.fromMap(doc)).toList();
//       });
//     },
//     loading: () => Stream.value([]),
//     error: (_, __) => Stream.value([]),
//   );
// });

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../services/auth_services1.dart';

// /// Provides a singleton instance of AuthService
// final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// /// Provides the current Firebase user as a Stream
// final authStateProvider = StreamProvider.autoDispose((ref) {
//   final authService = ref.watch(authServiceProvider);
//   return authService.authStateChanges;
// });
