import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app.dart';
import '../pages/splash_screen.dart';

/// Auth wrapper that persists auth state across app restarts
/// Listens to Firebase auth state changes and routes accordingly
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63E8)),
              ),
            ),
          );
        }

        // If user is logged in, go to main screen
        if (snapshot.hasData && snapshot.data != null) {
          return const MainScreen();
        }

        // If not logged in, show splash/login screen
        return const SplashScreen();
      },
    );
  }
}
