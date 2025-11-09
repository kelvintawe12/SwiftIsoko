import 'package:flutter/material.dart';
 

class BrowsePage extends StatelessWidget {
  const BrowsePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Browse Page')),
      body: Center(child: Text('Browse Page — Placeholder', style: const TextStyle(fontSize: 18))),
    );
  }
}
