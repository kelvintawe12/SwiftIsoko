import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedCategory = 'All';
  double? _minPrice;
  double? _maxPrice;
  final PageController _bannerController = PageController();
  Timer? _bannerTimer;
  int _currentBanner = 0;
  final List<Map<String, String>> _bannerSlides = [
    {'title': 'MacBook Pro M2', 'subtitle': 'Apple', 'image': 'assets/images/macbook.png'},
    {'title': 'iPhone 15 Pro', 'subtitle': 'Apple', 'image': 'assets/images/iphone.jpg'},
    {'title': 'Nike Air Max', 'subtitle': 'Nike', 'image': 'assets/images/nike.jpg'},
  ];

  @override
  void initState() {
    super.initState();
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_currentBanner + 1) % _bannerSlides.length;
      _bannerController.animateToPage(next, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
      setState(() => _currentBanner = next);
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredArrivals {
    return _newArrivals.where((item) {
      final cat = item['category'] as String? ?? '';
      final price = item['priceValue'] as double? ?? 0.0;
      if (_selectedCategory != 'All' && cat != _selectedCategory) return false;
      if (_minPrice != null && price < _minPrice!) return false;
      if (_maxPrice != null && price > _maxPrice!) return false;
      return true;
    }).toList();
  }

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
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
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

            // Hero Banner — slideshow carousel
            SizedBox(
              height: 190,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _bannerController,
                      itemCount: _bannerSlides.length,
                      onPageChanged: (i) => setState(() => _currentBanner = i),
                      itemBuilder: (context, index) {
                        final slide = _bannerSlides[index];
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(slide['image']!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey[200])),
                            Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Color.fromRGBO(0, 0, 0, 0.18), Colors.transparent], begin: Alignment.bottomLeft, end: Alignment.topRight))),
                            Positioned(
                              left: 16,
                              bottom: 18,
                              right: 120,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(slide['subtitle']!, style: const TextStyle(color: Colors.white, fontSize: 12)),
                                  const SizedBox(height: 6),
                                  Text(slide['title']!, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 10),
                                  ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primary), child: const Text('Buy Now'))
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    // indicators
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: Column(
                        children: List.generate(_bannerSlides.length, (i) {
                          final active = i == _currentBanner;
                          return Container(margin: const EdgeInsets.symmetric(vertical: 4), width: 8, height: active ? 28 : 8, decoration: BoxDecoration(color: active ? Color.fromRGBO(255,255,255,0.95) : Color.fromRGBO(255,255,255,0.5), borderRadius: BorderRadius.circular(6)));
                        }),
                      ),
                    ),
                  ],
                ),
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
                  _categoryChip('All', _selectedCategory == 'All'),
                  _categoryChip('Electronics', _selectedCategory == 'Electronics'),
                  _categoryChip('Clothes', _selectedCategory == 'Clothes'),
                  _categoryChip('Hair', _selectedCategory == 'Hair'),
                  _categoryChip('Shoes', _selectedCategory == 'Shoes'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // New Arrivals
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('New arrivals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Row(children: [
                  IconButton(onPressed: () => _showFilterSheet(context), icon: const Icon(Icons.filter_list, color: AppColors.textLight)),
                  TextButton(onPressed: () {}, child: const Text('View all')),
                ]),
              ],
            ),
            const SizedBox(height: 12),

            // New arrivals - horizontal list
            SizedBox(
              height: 170,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _filteredArrivals.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final item = _filteredArrivals[index];
                  return _SmallCard(title: item['title'] as String, price: item['price'] as String, image: item['image'] as String);
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
      child: GestureDetector(
        onTap: () => setState(() => _selectedCategory = label),
        child: Chip(
          label: Text(label),
          backgroundColor: selected ? AppColors.primary : Colors.grey[200],
          labelStyle: TextStyle(color: selected ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setStateSheet) {
          // Determine slider range from data (be defensive against nulls)
          final allPrices = _newArrivals.map((e) => (e['priceValue'] as double?) ?? 0.0).where((p) => p > 0).toList();
          final double maxFound = allPrices.isNotEmpty ? allPrices.reduce((a, b) => a > b ? a : b) : 2000.0;
          final double maxPossible = (maxFound <= 0 ? 2000.0 : maxFound).ceilToDouble();
          final double minPossible = 0.0;

          RangeValues current = RangeValues(_minPrice ?? minPossible, _maxPrice ?? maxPossible);
          // ensure valid bounds
          if (current.start < minPossible) current = RangeValues(minPossible, current.end);
          if (current.end > maxPossible) current = RangeValues(current.start, maxPossible);

          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF7F3FF), // pale purple background to match design
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: EdgeInsets.only(left: 20, right: 20, top: 18, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: Text('Filter', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 16))),
                const SizedBox(height: 18),
                Text('Price range', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                StatefulBuilder(builder: (context2, setStateInner) {
                  RangeValues localRange = current;
                  return Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('\$${localRange.start.toInt()}', style: TextStyle(color: AppColors.textLight)),
                        Text('\$${localRange.end.toInt()}', style: TextStyle(color: AppColors.textLight)),
                      ]),
                      RangeSlider(
                        values: localRange,
                        min: minPossible,
                        max: maxPossible,
                        divisions: 20,
                        activeColor: AppColors.primary,
                        onChanged: (r) => setStateInner(() => localRange = r),
                        onChangeEnd: (r) => setStateSheet(() { _minPrice = r.start; _maxPrice = r.end; }),
                      ),
                      const SizedBox(height: 8),
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        TextButton(onPressed: () { setStateSheet(() { _minPrice = null; _maxPrice = null; }); Navigator.of(ctx).pop(); }, child: Text('Reset', style: TextStyle(color: AppColors.primary))),
                      ])
                    ],
                  );
                }),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text('Cancel', style: TextStyle(color: AppColors.primary)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        // keep values already written to _minPrice/_maxPrice by onChangeEnd; close sheet
                        Navigator.of(ctx).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: const Text('Apply'),
                    ),
                  ],
                )
              ],
            ),
          );
        });
      }
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
final List<Map<String, dynamic>> _newArrivals = [
  {'title': 'MacBook Air 13in', 'price': '\$1,149.00', 'priceValue': 1149.00, 'image': 'assets/images/macbook_air.jpg', 'category': 'Electronics'},
  {'title': 'Nike Air Max', 'price': '\$74.50', 'priceValue': 74.50, 'image': 'assets/images/nike.jpg', 'category': 'Clothes'},
  {'title': 'Canon Lens', 'price': '\$350.00', 'priceValue': 350.00, 'image': 'assets/images/lens.png', 'category': 'Electronics'},
];