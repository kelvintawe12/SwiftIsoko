import 'package:shared_preferences/shared_preferences.dart';

/// Simple persistent likes service using SharedPreferences.
class LikesService {
  static const _kKey = 'liked_items_v1';
  static LikesService? _instance;
  final SharedPreferences _prefs;

  LikesService._(this._prefs);

  static Future<LikesService> getInstance() async {
    if (_instance != null) return _instance!;
    final prefs = await SharedPreferences.getInstance();
    _instance = LikesService._(prefs);
    return _instance!;
  }

  /// Returns the set of liked ids (as a Set of strings).
  Set<String> getLikedSet() {
    final list = _prefs.getStringList(_kKey) ?? <String>[];
    return list.toSet();
  }

  Future<bool> isLiked(String id) async {
    final set = getLikedSet();
    return set.contains(id);
  }

  Future<bool> toggleLiked(String id) async {
    final set = getLikedSet();
    final added = set.add(id);
    if (!added) set.remove(id);
    await _prefs.setStringList(_kKey, set.toList());
    return set.contains(id);
  }

  Future<void> setLiked(String id, bool liked) async {
    final set = getLikedSet();
    if (liked) set.add(id); else set.remove(id);
    await _prefs.setStringList(_kKey, set.toList());
  }
}
