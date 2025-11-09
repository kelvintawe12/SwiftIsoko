import 'package:flutter/material.dart';
 
class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout Page')),
      body: Center(child: Text('Checkout Page — Placeholder', style: const TextStyle(fontSize: 18))),
    );
  }
}
