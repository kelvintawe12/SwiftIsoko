import 'dart:async';

/// Minimal ProfileService stub used by profile pages.
/// Stores values in-memory. Replace with Firestore-backed service as needed.
class ProfileService {
  static ProfileService? _instance;

  String name = 'Alex Davis';
  String location = 'Kigali, Rwanda';
  String? avatarPath;
  String bio = '';

  ProfileService._();

  static Future<ProfileService> getInstance() async {
    _instance ??= ProfileService._();
    return _instance!;
  }

  // Example setters
  Future<void> updateName(String newName) async {
    name = newName;
  }

  Future<void> updateAvatarPath(String path) async {
    avatarPath = path;
  }

  Future<void> updateBio(String newBio) async {
    bio = newBio;
  }
  
  Future<void> save(String newName, String newLocation, String? newAvatarPath, String? newBio) async {
    name = newName;
    location = newLocation;
    avatarPath = newAvatarPath;
    bio = newBio ?? '';
  }
}
