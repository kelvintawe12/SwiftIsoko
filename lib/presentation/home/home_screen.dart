import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/colors.dart';
import '../../data/models/product.dart';
import '../../data/providers/providers.dart';
import '../../data/utils/validators.dart';
import 'add_product_screen.dart';
import 'product_detail_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
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

  // search controls
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _showSearch = false;
  String _searchQuery = '';

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
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  List<ProductModel> _applyFilters(List<ProductModel> all) {
    return all.where((p) {
      if (_selectedCategory != 'All' && p.category.toLowerCase() != _selectedCategory.toLowerCase()) return false;
      if (_minPrice != null && p.price < _minPrice!) return false;
      if (_maxPrice != null && p.price > _maxPrice!) return false;
      if (_searchQuery.isNotEmpty && !p.name.toLowerCase().contains(_searchQuery.toLowerCase())) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);
    final productsAsync = ref.watch(productsStreamProvider);
    final categories = ref.watch(productCategoriesProvider);

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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: currentUserAsync.when(
              data: (u) => CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary,
                backgroundImage: u?.profileImageUrl != null ? NetworkImage(u!.profileImageUrl!) : null,
                child: u?.profileImageUrl == null ? Text(u != null ? Formatters.getInitials(u.name) : 'U', style: const TextStyle(color: Colors.white)) : null,
              ),
              loading: () => const CircleAvatar(radius: 18, backgroundColor: AppColors.primary),
              error: (_, __) => const CircleAvatar(radius: 18, backgroundColor: AppColors.primary),
            ),
          ),
        ],
      ),
      body: productsAsync.when(
        data: (productList) {
          final filtered = _applyFilters(productList);
          final allPrices = productList.map((p) => p.price).where((p) => p > 0).toList();
          final maxFound = allPrices.isNotEmpty ? allPrices.reduce((a, b) => a > b ? a : b) : 2000.0;
          final maxPossible = (maxFound <= 0 ? 2000.0 : maxFound).ceilToDouble();

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: currentUserAsync.when(
                        data: (user) => Text(
                          user != null ? 'Welcome back,\n${user.name.split(' ').first}' : 'Welcome',
                          style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold, height: 1.1),
                        ),
                        loading: () => Text('Welcome', style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold, height: 1.1)),
                        error: (_, __) => Text('Welcome', style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold, height: 1.1)),
                      ),
                    ),
                    MouseRegion(
                      onEnter: (_) => setState(() => _showSearch = true),
                      onExit: (_) {
                        if (!_searchFocus.hasFocus) setState(() => _showSearch = false);
                      },
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _showSearch = true);
                          _searchFocus.requestFocus();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: _showSearch ? 220 : 44,
                          height: 44,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: const Color.fromRGBO(0, 0, 0, 0.06), blurRadius: 6)]),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          alignment: Alignment.centerLeft,
                          child: _showSearch
                              ? Row(children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _searchController,
                                      focusNode: _searchFocus,
                                      decoration: const InputDecoration(border: InputBorder.none, hintText: 'Search...'),
                                      onSubmitted: (v) => setState(() => _searchQuery = v),
                                    ),
                                  ),
                                  IconButton(onPressed: () => setState(() { _searchController.clear(); _searchQuery = ''; _showSearch = false; }), icon: const Icon(Icons.close, size: 18)),
                                ])
                              : const Icon(Icons.search, color: AppColors.primary),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20),

                // Banner - show first 6 products as slideshow (fallback to static slides)
                SizedBox(
                  height: 190,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Builder(builder: (context) {
                      final slides = productList.take(6).toList();

                      if (slides.isEmpty) {
                        // fallback to static images
                        return Stack(
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
                                    Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [const Color.fromRGBO(0, 0, 0, 0.18), Colors.transparent], begin: Alignment.bottomLeft, end: Alignment.topRight))),
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
                            Positioned(
                              right: 12,
                              bottom: 12,
                              child: Column(
                                children: List.generate(_bannerSlides.length, (i) {
                                  final active = i == _currentBanner;
                                  return Container(margin: const EdgeInsets.symmetric(vertical: 4), width: 8, height: active ? 28 : 8, decoration: BoxDecoration(color: active ? const Color.fromRGBO(255,255,255,0.95) : const Color.fromRGBO(255,255,255,0.5), borderRadius: BorderRadius.circular(6)));
                                }),
                              ),
                            ),
                          ],
                        );
                      }

                      // Use real products for slides
                      return Stack(
                        children: [
                          PageView.builder(
                            controller: _bannerController,
                            itemCount: slides.length,
                            onPageChanged: (i) => setState(() => _currentBanner = i),
                            itemBuilder: (context, index) {
                              final p = slides[index];
                              final image = p.imageUrls.isNotEmpty ? p.imageUrls.first : null;
                              return Stack(
                                fit: StackFit.expand,
                                children: [
                                  if (image != null)
                                    CachedNetworkImage(
                                      imageUrl: image,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => Container(color: Colors.grey[200]),
                                      errorWidget: (_, __, ___) => Container(color: Colors.grey[200]),
                                    )
                                  else
                                    Container(color: Colors.grey[200]),
                                  Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [const Color.fromRGBO(0, 0, 0, 0.18), Colors.transparent], begin: Alignment.bottomLeft, end: Alignment.topRight))),
                                  Positioned(
                                    left: 16,
                                    bottom: 18,
                                    right: 120,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (p.ownerName != null)
                                          Text(p.ownerName!, style: const TextStyle(color: Colors.white, fontSize: 12)),
                                        const SizedBox(height: 6),
                                        Text(p.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 10),
                                        ElevatedButton(
                                          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p))),
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primary),
                                          child: const Text('View'),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          Positioned(
                            right: 12,
                            bottom: 12,
                            child: Column(
                              children: List.generate(slides.length, (i) {
                                final active = i == _currentBanner;
                                return Container(margin: const EdgeInsets.symmetric(vertical: 4), width: 8, height: active ? 28 : 8, decoration: BoxDecoration(color: active ? const Color.fromRGBO(255,255,255,0.95) : const Color.fromRGBO(255,255,255,0.5), borderRadius: BorderRadius.circular(6)));
                              }),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 24),

                // Categories
                const Text('Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    _categoryChip('All', _selectedCategory == 'All'),
                    for (final c in categories) _categoryChip(c, _selectedCategory.toLowerCase() == c.toLowerCase()),
                  ]),
                ),
                const SizedBox(height: 24),

                // New Arrivals header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('New arrivals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Row(children: [
                      IconButton(onPressed: () => _showFilterSheet(context, productList, maxPossible), icon: const Icon(Icons.filter_list, color: AppColors.textLight)),
                      TextButton(onPressed: () {}, child: const Text('View all')),
                    ])
                  ],
                ),
                const SizedBox(height: 12),

                // New arrivals - horizontal list
                SizedBox(
                  height: 170,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final p = filtered[index];
                      return _SmallCard(
                        product: p,
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p))),
                        onSaveToggle: () async {
                          final userId = ref.read(currentUserIdProvider);
                          if (userId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please sign in to save items')));
                            return;
                          }
                          final notifier = ref.read(savedIdsNotifierProvider(userId).notifier);
                          await notifier.toggleSave(p.id);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error loading products: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddProductScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Sell'),
      ),
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

  void _showFilterSheet(BuildContext context, List<ProductModel> productList, double maxPossible) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setStateSheet) {
          final double minPossible = 0.0;
          RangeValues current = RangeValues(_minPrice ?? minPossible, _maxPrice ?? maxPossible);
          if (current.start < minPossible) current = RangeValues(minPossible, current.end);
          if (current.end > maxPossible) current = RangeValues(current.start, maxPossible);

          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF7F3FF),
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
                    TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text('Cancel', style: TextStyle(color: AppColors.primary))),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () { Navigator.of(ctx).pop(); },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
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

class _SmallCard extends ConsumerWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final Future<void> Function()? onSaveToggle;

  const _SmallCard({required this.product, required this.onTap, this.onSaveToggle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);
    final savedAsync = userId != null ? ref.watch(savedIdsNotifierProvider(userId)) : const AsyncValue.data(<String>[]);
    final isSaved = savedAsync.asData?.value.contains(product.id) ?? false;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: product.imageUrls.isNotEmpty
                      ? CachedNetworkImage(imageUrl: product.imageUrls.first, width: double.infinity, fit: BoxFit.cover, placeholder: (c, u) => Container(color: Colors.grey[200]), errorWidget: (c, u, e) => Container(color: Colors.grey[200], child: const Icon(Icons.broken_image)))
                      : Container(color: Colors.grey[200], child: const Icon(Icons.image)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(Formatters.formatCurrency(product.price, currency: product.currency)),
                        IconButton(
                          icon: isSaved ? const Icon(Icons.bookmark) : const Icon(Icons.bookmark_border),
                          color: isSaved ? AppColors.primary : null,
                          onPressed: onSaveToggle,
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
