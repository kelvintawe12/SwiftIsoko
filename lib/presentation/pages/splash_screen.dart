import 'package:flutter/material.dart';
 
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Splash Screen')),
      body: Center(child: Text('Splash Screen — Placeholder', style: const TextStyle(fontSize: 18))),
    );
  }
}
