import 'package:flutter/material.dart';
 
class ThankyouPage extends StatelessWidget {
  const ThankyouPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thank you Page')),
      body: Center(child: Text('Thank you Page — Placeholder', style: const TextStyle(fontSize: 18))),
    );
  }
}
