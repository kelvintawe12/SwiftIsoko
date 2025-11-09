// lib/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'SwiftIsoko',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 22,
            color: AppColors.primary,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary,
              child: Text('O', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: welcome + small search icon
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'Welcome back,\nOlivia',
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 8, top: 6),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), blurRadius: 6)]),
                  child: const Icon(Icons.search, color: AppColors.primary),
                )
              ],
            ),
            const SizedBox(height: 20),

            // Hero Banner
            // Hero Banner (card style)
            Container(
              height: 190,
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.04), blurRadius: 10)]),
              child: Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Apple', style: TextStyle(color: AppColors.textLight)),
                          const SizedBox(height: 8),
                          const Text('MacBook Pro M2', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          const Text('Experience blazing speed and stunning efficiency with the MacBook Pro.' , style: TextStyle(color: AppColors.textLight, fontSize: 12)),
                          const SizedBox(height: 12),
                          ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Buy Now'))
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: ClipRRect(borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)), child: Image.asset('assets/images/macbook.png', fit: BoxFit.cover, height: double.infinity, errorBuilder: (_,__,___)=>Container(color: Colors.grey[200]))),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Categories
            const Text('Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _categoryChip('Electronics', true),
                  _categoryChip('Clothes', false),
                  _categoryChip('Hair', false),
                  _categoryChip('Shoes', false),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // New Arrivals
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('New arrivals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () {}, child: const Text('View all')),
              ],
            ),
            const SizedBox(height: 12),

            // New arrivals - horizontal list
            SizedBox(
              height: 170,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _newArrivals.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final item = _newArrivals[index];
                  return _SmallCard(title: item['title']!, price: item['price']!, image: item['image']!);
                },
              ),
            ),
            const SizedBox(height: 80), // space for bottom nav
          ],
        ),
      ),

      // Note: Bottom navigation is provided by MainScreen's centralized BottomNav.
    );
  }

  Widget _categoryChip(String label, bool selected) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Chip(
        label: Text(label),
        backgroundColor: selected ? AppColors.primary : Colors.grey[200],
        labelStyle: TextStyle(color: selected ? Colors.white : Colors.black),
      ),
    );
  }
}



// small horizontal card used in new arrivals
class _SmallCard extends StatelessWidget {
  final String title;
  final String price;
  final String image;

  const _SmallCard({required this.title, required this.price, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.04), blurRadius: 8)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(12)), child: Image.asset(image, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_,__,___)=>Container(color: Colors.grey[200]))),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)), const SizedBox(height: 4), Text(price, style: const TextStyle(color: AppColors.textLight, fontSize: 12))])),
                Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.add, color: Colors.white, size: 16)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// sample data for new arrivals
final List<Map<String, String>> _newArrivals = [
  {'title': 'MacBook Air 13in', 'price': '\$1,149.00', 'image': 'assets/images/macbook_air.jpg'},
  {'title': 'Nike Air Max', 'price': '\$74.50', 'image': 'assets/images/nike.jpg'},
  {'title': 'Canon Lens', 'price': '\$350.00', 'image': 'assets/images/lens.png'},
];