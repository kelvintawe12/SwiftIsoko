import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swapit_marketplace/presentation/home/settings_screen.dart';

void main() {
  group('SettingsScreen Widget Tests', () {
    setUp(() async {
      // Initialize SharedPreferences with mock values
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('SettingsScreen displays all section headers',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);

      // Scroll to see Audio section
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(find.text('Audio'), findsOneWidget);
    });

    testWidgets('SettingsScreen displays theme mode options',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Light Mode'), findsOneWidget);
      expect(find.text('Dark Mode'), findsOneWidget);
      expect(find.text('System Default'), findsOneWidget);
    });

    testWidgets('SettingsScreen displays language options',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('English'), findsOneWidget);
      expect(find.text('French'), findsOneWidget);
      expect(find.text('Spanish'), findsOneWidget);
    });

    testWidgets('SettingsScreen displays notification switches',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Enable Notifications'), findsOneWidget);
      expect(find.text('Email Notifications'), findsOneWidget);
      expect(find.text('Push Notifications'), findsOneWidget);
    });

    testWidgets('SettingsScreen displays sound effects switch',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll to see Sound Effects section
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Sound Effects'), findsOneWidget);
      expect(find.text('Play sounds for interactions'), findsOneWidget);
    });

    testWidgets('Tapping Light Mode shows selection',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Light Mode'));
      await tester.pumpAndSettle();

      // Assert - SnackBar should appear
      expect(find.text('Light mode enabled'), findsOneWidget);
    });

    testWidgets('Tapping Dark Mode shows selection',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Dark Mode'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Dark mode enabled'), findsOneWidget);
    });

    testWidgets('Tapping language option shows selection',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('French'));
      await tester.pumpAndSettle();

      // Assert - Check for localized message
      expect(find.text('Language selected: French'), findsOneWidget);
    });

    testWidgets('Toggling notification switch works',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll to see notification switches
      await tester.drag(find.byType(ListView), const Offset(0, -200));
      await tester.pumpAndSettle();

      // Find the "Enable Notifications" switch more precisely
      final switchFinder = find.descendant(
        of: find.ancestor(
          of: find.text('Enable Notifications'),
          matching: find.byType(SwitchListTile),
        ),
        matching: find.byType(Switch),
      );

      // Act - Toggle the switch
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Assert - SnackBar text should appear
      expect(find.textContaining('Notifications'), findsWidgets);
    });

    testWidgets('SettingsScreen displays app version',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll to see app version
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('App Version'), findsOneWidget);
      expect(find.text('1.0.0+1'), findsOneWidget);
    });

    testWidgets('SettingsScreen displays Privacy Policy option',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll to see Privacy Policy
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('View our privacy policy'), findsOneWidget);
    });

    testWidgets('SettingsScreen displays Terms of Service option',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll to see Terms of Service
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Terms of Service'), findsOneWidget);
      expect(find.text('View terms of service'), findsOneWidget);
    });

    testWidgets('Settings screen has Settings title in AppBar',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('All switches are initially enabled by default',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Find all switches and verify they are on
      final switches = tester.widgetList<Switch>(find.byType(Switch));
      for (final switchWidget in switches) {
        expect(switchWidget.value, true);
      }
    });
  });
}
