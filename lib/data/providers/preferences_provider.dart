import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/preferences_service.dart';

/// Provider for PreferencesService
final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  return PreferencesService();
});

/// State notifier for theme mode
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final PreferencesService _preferencesService;

  ThemeModeNotifier(this._preferencesService) : super(ThemeMode.system) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final themeModeString = await _preferencesService.getThemeMode();
    state = _themeModeFromString(themeModeString);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _preferencesService.setThemeMode(_themeModeToString(mode));
  }

  ThemeMode _themeModeFromString(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }
}

/// Provider for theme mode
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final preferencesService = ref.watch(preferencesServiceProvider);
  return ThemeModeNotifier(preferencesService);
});

/// State notifier for language
class LanguageNotifier extends StateNotifier<String> {
  final PreferencesService _preferencesService;

  LanguageNotifier(this._preferencesService) : super('en') {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    state = await _preferencesService.getLanguage();
  }

  Future<void> setLanguage(String languageCode) async {
    state = languageCode;
    await _preferencesService.setLanguage(languageCode);
  }
}

/// Provider for language
final languageProvider = StateNotifierProvider<LanguageNotifier, String>((ref) {
  final preferencesService = ref.watch(preferencesServiceProvider);
  return LanguageNotifier(preferencesService);
});

/// State notifier for notifications enabled
class NotificationsEnabledNotifier extends StateNotifier<bool> {
  final PreferencesService _preferencesService;

  NotificationsEnabledNotifier(this._preferencesService) : super(true) {
    _loadNotificationsEnabled();
  }

  Future<void> _loadNotificationsEnabled() async {
    state = await _preferencesService.getNotificationsEnabled();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    state = enabled;
    await _preferencesService.setNotificationsEnabled(enabled);
  }
}

/// Provider for notifications enabled
final notificationsEnabledProvider =
    StateNotifierProvider<NotificationsEnabledNotifier, bool>((ref) {
  final preferencesService = ref.watch(preferencesServiceProvider);
  return NotificationsEnabledNotifier(preferencesService);
});

/// State notifier for email notifications
class EmailNotificationsNotifier extends StateNotifier<bool> {
  final PreferencesService _preferencesService;

  EmailNotificationsNotifier(this._preferencesService) : super(true) {
    _loadEmailNotifications();
  }

  Future<void> _loadEmailNotifications() async {
    state = await _preferencesService.getEmailNotificationsEnabled();
  }

  Future<void> setEmailNotifications(bool enabled) async {
    state = enabled;
    await _preferencesService.setEmailNotificationsEnabled(enabled);
  }
}

/// Provider for email notifications
final emailNotificationsProvider =
    StateNotifierProvider<EmailNotificationsNotifier, bool>((ref) {
  final preferencesService = ref.watch(preferencesServiceProvider);
  return EmailNotificationsNotifier(preferencesService);
});

/// State notifier for push notifications
class PushNotificationsNotifier extends StateNotifier<bool> {
  final PreferencesService _preferencesService;

  PushNotificationsNotifier(this._preferencesService) : super(true) {
    _loadPushNotifications();
  }

  Future<void> _loadPushNotifications() async {
    state = await _preferencesService.getPushNotificationsEnabled();
  }

  Future<void> setPushNotifications(bool enabled) async {
    state = enabled;
    await _preferencesService.setPushNotificationsEnabled(enabled);
  }
}

/// Provider for push notifications
final pushNotificationsProvider =
    StateNotifierProvider<PushNotificationsNotifier, bool>((ref) {
  final preferencesService = ref.watch(preferencesServiceProvider);
  return PushNotificationsNotifier(preferencesService);
});

/// State notifier for sound effects
class SoundEffectsNotifier extends StateNotifier<bool> {
  final PreferencesService _preferencesService;

  SoundEffectsNotifier(this._preferencesService) : super(true) {
    _loadSoundEffects();
  }

  Future<void> _loadSoundEffects() async {
    state = await _preferencesService.getSoundEffectsEnabled();
  }

  Future<void> setSoundEffects(bool enabled) async {
    state = enabled;
    await _preferencesService.setSoundEffectsEnabled(enabled);
  }
}

/// Provider for sound effects
final soundEffectsProvider =
    StateNotifierProvider<SoundEffectsNotifier, bool>((ref) {
  final preferencesService = ref.watch(preferencesServiceProvider);
  return SoundEffectsNotifier(preferencesService);
});
