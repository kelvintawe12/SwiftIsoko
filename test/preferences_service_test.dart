import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swapit_marketplace/data/services/preferences_service.dart';

void main() {
  group('PreferencesService Unit Tests', () {
    late PreferencesService preferencesService;

    setUp(() async {
      // Initialize SharedPreferences with mock values
      SharedPreferences.setMockInitialValues({});
      preferencesService = PreferencesService();
    });

    test('getThemeMode returns default value "system" when not set', () async {
      // Act
      final themeMode = await preferencesService.getThemeMode();

      // Assert
      expect(themeMode, 'system');
    });

    test('setThemeMode saves and retrieves theme mode correctly', () async {
      // Arrange
      const expectedTheme = 'dark';

      // Act
      await preferencesService.setThemeMode(expectedTheme);
      final retrievedTheme = await preferencesService.getThemeMode();

      // Assert
      expect(retrievedTheme, expectedTheme);
    });

    test('setThemeMode can change between light, dark, and system', () async {
      // Test light mode
      await preferencesService.setThemeMode('light');
      expect(await preferencesService.getThemeMode(), 'light');

      // Test dark mode
      await preferencesService.setThemeMode('dark');
      expect(await preferencesService.getThemeMode(), 'dark');

      // Test system mode
      await preferencesService.setThemeMode('system');
      expect(await preferencesService.getThemeMode(), 'system');
    });

    test('getLanguage returns default value "en" when not set', () async {
      // Act
      final language = await preferencesService.getLanguage();

      // Assert
      expect(language, 'en');
    });

    test('setLanguage saves and retrieves language correctly', () async {
      // Arrange
      const expectedLanguage = 'fr';

      // Act
      await preferencesService.setLanguage(expectedLanguage);
      final retrievedLanguage = await preferencesService.getLanguage();

      // Assert
      expect(retrievedLanguage, expectedLanguage);
    });

    test('getNotificationsEnabled returns true by default', () async {
      // Act
      final notificationsEnabled =
          await preferencesService.getNotificationsEnabled();

      // Assert
      expect(notificationsEnabled, true);
    });

    test('setNotificationsEnabled saves and retrieves value correctly',
        () async {
      // Act - disable notifications
      await preferencesService.setNotificationsEnabled(false);
      final disabled = await preferencesService.getNotificationsEnabled();

      // Assert
      expect(disabled, false);

      // Act - enable notifications
      await preferencesService.setNotificationsEnabled(true);
      final enabled = await preferencesService.getNotificationsEnabled();

      // Assert
      expect(enabled, true);
    });

    test('getEmailNotificationsEnabled returns true by default', () async {
      // Act
      final emailNotifications =
          await preferencesService.getEmailNotificationsEnabled();

      // Assert
      expect(emailNotifications, true);
    });

    test('setEmailNotificationsEnabled saves and retrieves value correctly',
        () async {
      // Arrange
      const expectedValue = false;

      // Act
      await preferencesService.setEmailNotificationsEnabled(expectedValue);
      final retrievedValue =
          await preferencesService.getEmailNotificationsEnabled();

      // Assert
      expect(retrievedValue, expectedValue);
    });

    test('getPushNotificationsEnabled returns true by default', () async {
      // Act
      final pushNotifications =
          await preferencesService.getPushNotificationsEnabled();

      // Assert
      expect(pushNotifications, true);
    });

    test('setPushNotificationsEnabled saves and retrieves value correctly',
        () async {
      // Arrange
      const expectedValue = false;

      // Act
      await preferencesService.setPushNotificationsEnabled(expectedValue);
      final retrievedValue =
          await preferencesService.getPushNotificationsEnabled();

      // Assert
      expect(retrievedValue, expectedValue);
    });

    test('getSoundEffectsEnabled returns true by default', () async {
      // Act
      final soundEffects = await preferencesService.getSoundEffectsEnabled();

      // Assert
      expect(soundEffects, true);
    });

    test('setSoundEffectsEnabled saves and retrieves value correctly',
        () async {
      // Arrange
      const expectedValue = false;

      // Act
      await preferencesService.setSoundEffectsEnabled(expectedValue);
      final retrievedValue = await preferencesService.getSoundEffectsEnabled();

      // Assert
      expect(retrievedValue, expectedValue);
    });

    test('clearPreferences removes all saved preferences', () async {
      // Arrange - Set various preferences
      await preferencesService.setThemeMode('dark');
      await preferencesService.setLanguage('fr');
      await preferencesService.setNotificationsEnabled(false);
      await preferencesService.setEmailNotificationsEnabled(false);

      // Act - Clear all preferences
      await preferencesService.clearPreferences();

      // Assert - All should return to default values
      expect(await preferencesService.getThemeMode(), 'system');
      expect(await preferencesService.getLanguage(), 'en');
      expect(await preferencesService.getNotificationsEnabled(), true);
      expect(await preferencesService.getEmailNotificationsEnabled(), true);
    });

    test('multiple preference changes are persisted correctly', () async {
      // Arrange & Act - Set multiple preferences
      await preferencesService.setThemeMode('dark');
      await preferencesService.setLanguage('es');
      await preferencesService.setNotificationsEnabled(false);
      await preferencesService.setPushNotificationsEnabled(true);
      await preferencesService.setSoundEffectsEnabled(false);

      // Assert - All values are correctly saved
      expect(await preferencesService.getThemeMode(), 'dark');
      expect(await preferencesService.getLanguage(), 'es');
      expect(await preferencesService.getNotificationsEnabled(), false);
      expect(await preferencesService.getPushNotificationsEnabled(), true);
      expect(await preferencesService.getSoundEffectsEnabled(), false);
    });

    test('preference values persist across multiple retrievals', () async {
      // Arrange
      await preferencesService.setThemeMode('light');

      // Act - Get value multiple times
      final first = await preferencesService.getThemeMode();
      final second = await preferencesService.getThemeMode();
      final third = await preferencesService.getThemeMode();

      // Assert - All retrievals return the same value
      expect(first, 'light');
      expect(second, 'light');
      expect(third, 'light');
    });
  });
}
