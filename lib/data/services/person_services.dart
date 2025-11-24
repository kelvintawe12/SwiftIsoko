// We are going to update user profiles

// Import all packages
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'dart:io';

class UserService {
  // Innitialise Firebase and firestore
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // setup for cloudinary
  final CloudinaryPublic _cloudinary = CloudinaryPublic(
    'dfpxfdvli',
    'Bookswap flutter app',
    cache: false,
  );

  /// Upload image to Cloudinary and get URL
  // ignore: non_constant_identifier_names
  Future<String> _uploadImageToCloudinary(File ImageFile) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(ImageFile.path, folder: 'user_profiles'),
      );
      return response.secureUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// UPDATE EXISTING USER
  Future<void> updateuser({
    required String userId,
    String? name,
    String? phoneNumber,
    File? profileImageFile,
    String? bio,
    String? location,
    double? ratingAverage,
    int? numRatings,
  }) async {
    try {
      // Get current User
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Upload new profile image if provided
      String? uploadedProfileUrl;

      if (profileImageFile != null) {
        uploadedProfileUrl = await _uploadImageToCloudinary(profileImageFile);

        // Update Firebase Auth profile image
        await user.updatePhotoURL(uploadedProfileUrl);
      }

      // Build Firestore update data
      final Map<String, dynamic> updateData = {};

      if (name != null) {
        updateData['name'] = name;
        await user.updateDisplayName(name); // Also update Firebase Auth
      }

      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (bio != null) updateData['bio'] = bio;
      if (location != null) updateData['location'] = location;
      if (ratingAverage != null) updateData['ratingAverage'] = ratingAverage;
      if (numRatings != null) updateData['numRatings'] = numRatings;
      if (uploadedProfileUrl != null) {
        updateData['profileImageUrl'] = uploadedProfileUrl;
      }

      // Update Firestore only if there are fields to update
      if (updateData.isNotEmpty) {
        await _firestore.collection('users').doc(userId).update(updateData);
      }
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }
}
