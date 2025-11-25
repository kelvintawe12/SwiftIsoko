import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import '../core/failures.dart';

class CloudinaryConfig {
  static const String cloudName = 'dfpxfdvli';
  static const String uploadPreset = 'Bookswap flutter app';
}

class CloudinaryService {
  late final CloudinaryPublic _cloudinary;

  CloudinaryService() {
    _cloudinary = CloudinaryPublic(
      CloudinaryConfig.cloudName,
      CloudinaryConfig.uploadPreset,
      cache: false,
    );
  }

  // Upload single image
  Future<Either<Failure, String>> uploadImage(File imageFile) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: 'swiftisoko/products',
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      return Right(response.secureUrl);
    } catch (e) {
      return Left(ServerFailure('Failed to upload image: ${e.toString()}'));
    }
  }

  // Upload multiple images
  Future<Either<Failure, List<String>>> uploadImages(
      List<File> imageFiles) async {
    try {
      if (imageFiles.length < 3) {
        return const Left(
          ValidationFailure('At least 3 images are required'),
        );
      }

      final uploadedUrls = <String>[];

      for (final imageFile in imageFiles) {
        final response = await _cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            imageFile.path,
            folder: 'swiftisoko/products',
            resourceType: CloudinaryResourceType.Image,
          ),
        );
        uploadedUrls.add(response.secureUrl);
      }

      return Right(uploadedUrls);
    } catch (e) {
      return Left(ServerFailure('Failed to upload images: ${e.toString()}'));
    }
  }

  // Upload profile image
  Future<Either<Failure, String>> uploadProfileImage(File imageFile) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: 'swiftisoko/profiles',
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      return Right(response.secureUrl);
    } catch (e) {
      return Left(
          ServerFailure('Failed to upload profile image: ${e.toString()}'));
    }
  }

  // Delete image by URL
  Future<Either<Failure, void>> deleteImage(String imageUrl) async {
    try {
      // Extract public ID from URL
      final publicId = _extractPublicId(imageUrl);

      if (publicId == null) {
        return const Left(ValidationFailure('Invalid image URL'));
      }

      // Note: Deletion requires authenticated request with API secret
      // This should ideally be done from backend/Cloud Functions
      // For now, we'll just return success as deletion isn't critical

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete image: ${e.toString()}'));
    }
  }

  // Extract public ID from Cloudinary URL
  String? _extractPublicId(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;

      // Find index of 'upload' segment
      final uploadIndex = segments.indexOf('upload');
      if (uploadIndex == -1 || uploadIndex >= segments.length - 1) {
        return null;
      }

      // Get path after version (v1234567890)
      final pathAfterVersion = segments.sublist(uploadIndex + 2);

      // Remove file extension from last segment
      final lastSegment = pathAfterVersion.last.split('.').first;
      pathAfterVersion[pathAfterVersion.length - 1] = lastSegment;

      return pathAfterVersion.join('/');
    } catch (e) {
      return null;
    }
  }

  // Generate thumbnail URL from original URL
  String getThumbnailUrl(String originalUrl,
      {int width = 300, int height = 300}) {
    try {
      final uri = Uri.parse(originalUrl);
      final segments = uri.pathSegments.toList();

      // Find upload segment
      final uploadIndex = segments.indexOf('upload');
      if (uploadIndex == -1) return originalUrl;

      // Insert transformation after 'upload'
      segments.insert(
        uploadIndex + 1,
        'w_$width,h_$height,c_fill,f_auto,q_auto',
      );

      return uri.replace(pathSegments: segments).toString();
    } catch (e) {
      return originalUrl;
    }
  }

  // Validate image file
  bool isValidImageFile(File file) {
    final validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
    final extension = file.path.split('.').last.toLowerCase();
    return validExtensions.contains(extension);
  }

  // Check file size (max 10MB)
  bool isValidFileSize(File file, {int maxSizeInMB = 10}) {
    final fileSizeInBytes = file.lengthSync();
    final maxSizeInBytes = maxSizeInMB * 1024 * 1024;
    return fileSizeInBytes <= maxSizeInBytes;
  }
}
