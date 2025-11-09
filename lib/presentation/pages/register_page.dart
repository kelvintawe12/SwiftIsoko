import 'package:flutter/material.dart';
 
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Page')),
      body: Center(child: Text('Register Page — Placeholder', style: const TextStyle(fontSize: 18))),
    );
  }
}
