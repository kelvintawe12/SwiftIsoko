import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'presentation/app.dart';
import 'core/constants/colors.dart';

void main() {
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
      home: const MainScreen(),
    );
  }
}
