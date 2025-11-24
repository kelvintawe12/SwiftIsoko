// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'presentation/app.dart';
import 'presentation/pages/splash_screen.dart';
import 'core/constants/colors.dart';

void main() async {
  // makes sure Flutter's engine and widget system are fully
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Configure Firebase for web platform
  // Initialize Firebase only for supported platforms
  // if (!kIsWeb) {
  //   try {
  //     await Firebase.initializeApp();
  //   } catch (e) {
  //     debugPrint('Firebase initialization error: $e');
  //   }
  // }

  runApp(const SwapItApp());
}

class SwapItApp extends StatelessWidget {
  const SwapItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SwapIt',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.poppinsTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.textDark),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
