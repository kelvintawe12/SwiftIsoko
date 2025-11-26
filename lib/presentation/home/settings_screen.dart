import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/app_localizations.dart';
import '../../data/providers/preferences_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final language = ref.watch(languageProvider);
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);
    final emailNotifications = ref.watch(emailNotificationsProvider);
    final pushNotifications = ref.watch(pushNotificationsProvider);
    final soundEffects = ref.watch(soundEffectsProvider);

    // Create localization instance based on selected language
    final localizations = AppLocalizations(language);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          localizations.settings,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance Section
          _buildSectionHeader(localizations.appearance),
          _buildCard(
            context: context,
            child: Column(
              children: [
                _buildThemeOption(
                  context,
                  ref,
                  localizations,
                  title: localizations.lightMode,
                  icon: Icons.light_mode,
                  isSelected: themeMode == ThemeMode.light,
                  onTap: () {
                    ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(ThemeMode.light);
                    _showSnackBar(context, localizations.lightModeEnabled);
                  },
                ),
                const Divider(height: 1),
                _buildThemeOption(
                  context,
                  ref,
                  localizations,
                  title: localizations.darkMode,
                  icon: Icons.dark_mode,
                  isSelected: themeMode == ThemeMode.dark,
                  onTap: () {
                    ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(ThemeMode.dark);
                    _showSnackBar(context, localizations.darkModeEnabled);
                  },
                ),
                const Divider(height: 1),
                _buildThemeOption(
                  context,
                  ref,
                  localizations,
                  title: localizations.systemDefault,
                  icon: Icons.settings_suggest,
                  isSelected: themeMode == ThemeMode.system,
                  onTap: () {
                    ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(ThemeMode.system);
                    _showSnackBar(context, localizations.usingSystemTheme);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Language Section
          _buildSectionHeader(localizations.language),
          _buildCard(
            context: context,
            child: Column(
              children: [
                _buildLanguageOption(
                  context,
                  ref,
                  localizations,
                  title: localizations.english,
                  languageCode: 'en',
                  flag: '🇺🇸',
                  isSelected: language == 'en',
                ),
                const Divider(height: 1),
                _buildLanguageOption(
                  context,
                  ref,
                  localizations,
                  title: localizations.french,
                  languageCode: 'fr',
                  flag: '🇫🇷',
                  isSelected: language == 'fr',
                ),
                const Divider(height: 1),
                _buildLanguageOption(
                  context,
                  ref,
                  localizations,
                  title: localizations.spanish,
                  languageCode: 'es',
                  flag: '🇪🇸',
                  isSelected: language == 'es',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Notifications Section
          _buildSectionHeader(localizations.notifications),
          _buildCard(
            context: context,
            child: Column(
              children: [
                _buildSwitchTile(
                  context,
                  ref,
                  localizations,
                  title: localizations.enableNotifications,
                  subtitle: localizations.receiveAppNotifications,
                  icon: Icons.notifications,
                  value: notificationsEnabled,
                  onChanged: (value) {
                    ref
                        .read(notificationsEnabledProvider.notifier)
                        .setNotificationsEnabled(value);
                    _showSnackBar(
                      context,
                      value
                          ? localizations.notificationsEnabled
                          : localizations.notificationsDisabled,
                    );
                  },
                ),
                const Divider(height: 1),
                _buildSwitchTile(
                  context,
                  ref,
                  localizations,
                  title: localizations.emailNotifications,
                  subtitle: localizations.receiveUpdatesViaEmail,
                  icon: Icons.email,
                  value: emailNotifications,
                  onChanged: (value) {
                    ref
                        .read(emailNotificationsProvider.notifier)
                        .setEmailNotifications(value);
                    _showSnackBar(
                      context,
                      value
                          ? localizations.emailNotificationsEnabled
                          : localizations.emailNotificationsDisabled,
                    );
                  },
                ),
                const Divider(height: 1),
                _buildSwitchTile(
                  context,
                  ref,
                  localizations,
                  title: localizations.pushNotifications,
                  subtitle: localizations.receivePushNotifications,
                  icon: Icons.notifications_active,
                  value: pushNotifications,
                  onChanged: (value) {
                    ref
                        .read(pushNotificationsProvider.notifier)
                        .setPushNotifications(value);
                    _showSnackBar(
                      context,
                      value
                          ? localizations.pushNotificationsEnabled
                          : localizations.pushNotificationsDisabled,
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Audio Section
          _buildSectionHeader(localizations.audio),
          _buildCard(
            context: context,
            child: _buildSwitchTile(
              context,
              ref,
              localizations,
              title: localizations.soundEffects,
              subtitle: localizations.playSoundsForInteractions,
              icon: Icons.volume_up,
              value: soundEffects,
              onChanged: (value) {
                ref.read(soundEffectsProvider.notifier).setSoundEffects(value);
                _showSnackBar(
                  context,
                  value
                      ? localizations.soundEffectsEnabled
                      : localizations.soundEffectsDisabled,
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Info Section
          _buildCard(
            context: context,
            child: Column(
              children: [
                _buildInfoTile(
                  localizations,
                  icon: Icons.info_outline,
                  title: localizations.appVersion,
                  subtitle: '1.0.0+1',
                ),
                const Divider(height: 1),
                _buildInfoTile(
                  localizations,
                  icon: Icons.privacy_tip_outlined,
                  title: localizations.privacyPolicy,
                  subtitle: localizations.viewOurPrivacyPolicy,
                  onTap: () {
                    _showSnackBar(
                        context, localizations.privacyPolicyComingSoon);
                  },
                ),
                const Divider(height: 1),
                _buildInfoTile(
                  localizations,
                  icon: Icons.description_outlined,
                  title: localizations.termsOfService,
                  subtitle: localizations.viewTermsOfService,
                  onTap: () {
                    _showSnackBar(
                        context, localizations.termsOfServiceComingSoon);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textLight,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child, required BuildContext context}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade700
              : Colors.grey.shade200,
        ),
      ),
      child: child,
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations localizations, {
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? AppColors.primary : null,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : null,
      onTap: onTap,
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations localizations, {
    required String title,
    required String languageCode,
    required String flag,
    required bool isSelected,
  }) {
    return ListTile(
      leading: Text(
        flag,
        style: const TextStyle(fontSize: 28),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? AppColors.primary : null,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : null,
      onTap: () {
        ref.read(languageProvider.notifier).setLanguage(languageCode);
        _showSnackBar(context, '${localizations.languageSelected}: $title');
      },
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations localizations, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppColors.textLight),
      ),
      value: value,
      activeTrackColor: AppColors.primary.withAlpha(128), // 50% opacity
      activeThumbColor: AppColors.primary,
      onChanged: onChanged,
    );
  }

  Widget _buildInfoTile(
    AppLocalizations localizations, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textLight),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppColors.textLight),
      ),
      trailing:
          onTap != null ? const Icon(Icons.arrow_forward_ios, size: 16) : null,
      onTap: onTap,
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
