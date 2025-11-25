import 'dart:async';

/// Minimal in-memory LikesService stub used by demo pages and widgets.
/// Replace with a persistent implementation if needed.
class LikesService {
  static LikesService? _instance;
  final Set<String> _liked = <String>{};

  LikesService._();

  static Future<LikesService> getInstance() async {
    _instance ??= LikesService._();
    return _instance!;
  }

  /// Returns whether the id is liked.
  Future<bool> isLiked(String id) async {
    return _liked.contains(id);
  }

  /// Toggle liked state; returns new state.
  Future<bool> toggleLiked(String id) async {
    if (_liked.contains(id)) {
      _liked.remove(id);
      return false;
    }
    _liked.add(id);
    return true;
  }

  /// Synchronous snapshot of liked ids.
  Set<String> getLikedSet() => Set<String>.from(_liked);
}
