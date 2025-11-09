import 'package:flutter/material.dart';
 
class ProductPage extends StatelessWidget {
  const ProductPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Page')),
      body: Center(child: Text('Product Page — Placeholder', style: const TextStyle(fontSize: 18))),
    );
  }
}
