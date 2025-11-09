import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  static const _kName = 'profile_name_v1';
  static const _kLocation = 'profile_location_v1';
  static const _kAvatar = 'profile_avatar_v1';
  static const _kBio = 'profile_bio_v1';

  final SharedPreferences _prefs;
  ProfileService._(this._prefs);

  static Future<ProfileService> getInstance() async {
    final prefs = await SharedPreferences.getInstance();
    return ProfileService._(prefs);
  }

  String get name => _prefs.getString(_kName) ?? 'Alex Davis';
  String get location => _prefs.getString(_kLocation) ?? 'Kigali, Rwanda';
  String? get avatarPath => _prefs.getString(_kAvatar);
  String get bio => _prefs.getString(_kBio) ?? '';

  Future<void> save(String name, String location, String? avatarPath, String? bio) async {
    await _prefs.setString(_kName, name);
    await _prefs.setString(_kLocation, location);
    if (avatarPath == null) {
      await _prefs.remove(_kAvatar);
    } else {
      await _prefs.setString(_kAvatar, avatarPath);
    }
    if (bio == null) {
      await _prefs.remove(_kBio);
    } else {
      await _prefs.setString(_kBio, bio);
    }
  }
}
