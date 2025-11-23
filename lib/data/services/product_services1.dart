// // PRODUCT SERVICES
// // Import Packages
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:cloudinary_public/cloudinary_public.dart';
// import 'dart:io';

// // Import Model
// import '../models/product.dart';

// // DEFINE CLASS
// class ProductServices {
//   // Innitialise Auth, and Firestore
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   CollectionReference get _productsRef => _firestore.collection('products');

//   // setup for cloudinary
//   final CloudinaryPublic _cloudinary = CloudinaryPublic(
//     'dfpxfdvli',
//     'Bookswap flutter app',
//     cache: false,
//   );

//   /// Upload image to Cloudinary and get URL
//   Future<String> _uploadImage(File ImageFile) async {
//     try {
//       final response = await _cloudinary.uploadFile(
//         CloudinaryFile.fromFile(ImageFile.path, folder: 'product_images'),
//       );
//       return response.secureUrl;
//     } catch (e) {
//       throw Exception('Failed to upload image: $e');
//     }
//   }

//   /// Upload multiple images and return list of URLs
//   Future<List<String>> _uploadImages(List<File> files) async {
//     final urls = <String>[];
//     for (var file in files) {
//       final url = await _uploadImage(file);
//       urls.add(url);
//     }
//     return urls;
//   }

//   /// --------------------------
//   /// ADD PRODUCT
//   /// --------------------------
//   Future<String> createProduct({
//     required String name,
//     required List<File> imageFiles,
//     required String category,
//     required String description,
//     required String condition,
//     required String status,
//     required double price,
//     String currency = 'RWF',
//   }) async {
//     // Get current User
//     final user = _auth.currentUser;
//     if (user == null) throw Exception('User not authenticated');

//     try {
//       // Upload images to Cloudinary
//       final imageUrls = await _uploadImages(imageFiles);

//       // Get user profile for owner name
//       final userDoc = await _firestore.collection('users').doc(user.uid).get();
//       final userName = userDoc.data()?['name'] as String? ?? 'Unknown';

//       final product = Product(
//         id: '', // Firestore will generate
//         name: name,
//         imageUrls: imageUrls,
//         category: category,
//         description: description,
//         condition: condition,
//         status: status,
//         price: price,
//         currency: currency,
//         ownerId: user.uid,
//         ownerName: user.displayName,
//         createdAt: FieldValue.serverTimestamp(),
//         updatedAt: FieldValue.serverTimestamp(),
//       );

//       final docRef = await _productsRef.add(product.toMap());
//       await docRef.update({'id': docRef.id});

//       return docRef.id;
//     } catch (e) {
//       throw Exception('Failed to add product: $e');
//     }
//   }

//   /// --------------------------
//   /// UPDATE PRODUCT
//   /// --------------------------
//   Future<void> updateProduct({
//     required String productId,
//     String? name,
//     List<File>? newImages, // optional new images
//     String? category,
//     String? description,
//     String? condition,
//     String? status,
//     double? price,
//     String? currency,
//   }) async {
//     try {} catch (e) {
//       throw Exception('Failed to update product: $e');
//     }
//   }

//   /// --------------------------
//   /// DELETE PRODUCT
//   /// --------------------------
//   Future<void> deleteProduct(String productId) async {
//     try {
//       await _productsRef.doc(productId).delete();
//     } catch (e) {
//       throw Exception('Failed to delete product: $e');
//     }
//   }

//   /// --------------------------
//   /// GET PRODUCT BY ID
//   /// --------------------------
//   Future<Product?> getProductById(String productId) async {
//     try {
//       final doc = await _productsRef.doc(productId).get();
//       if (!doc.exists) return null;
//       return Product.fromMap(doc.data() as Map<String, dynamic>, doc.id);
//     } catch (e) {
//       throw Exception('Failed to fetch product: $e');
//     }
//   }

//   /// --------------------------
//   /// GET ALL PRODUCTS
//   /// --------------------------
//   Future<List<Product>> getProductsFiltered({
//     String? status,
//     String? condition,
//     String? ownerId,
//   }) async {
//     try {
//       Query query = _productsRef;
//       if (status != null) query = query.where('status', isEqualTo: status);
//       if (condition != null)
//         query = query.where('condition', isEqualTo: condition);
//       if (ownerId != null) query = query.where('ownerId', isEqualTo: ownerId);

//       final snapshot = await query.get();
//       return snapshot.docs
//           .map((doc) =>
//               Product.fromMap(doc.data() as Map<String, dynamic>, doc.id))
//           .toList();
//     } catch (e) {
//       throw Exception('Failed to fetch filtered products: $e');
//     }
//   }
// }
