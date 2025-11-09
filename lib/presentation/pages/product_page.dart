import 'package:flutter/material.dart';
import '../widgets/animated_like.dart';
import '../../data/likes_service.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});
  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  bool _liked = false;
  final String _id = 'product_page_sample';

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    final svc = await LikesService.getInstance();
    final v = await svc.isLiked(_id);
    if (mounted) setState(() => _liked = v);
  }

  void _toggle() async {
    final svc = await LikesService.getInstance();
    final v = await svc.toggleLiked(_id);
    if (mounted) setState(() => _liked = v);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Page'), actions: [Padding(padding: const EdgeInsets.only(right:12), child: AnimatedLike(isLiked: _liked, onTap: _toggle))]),
      body: Center(child: Text('Product Page — Placeholder', style: const TextStyle(fontSize: 18))),
    );
  }
}
