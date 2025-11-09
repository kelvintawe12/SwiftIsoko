import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 0; // 0: My Listings, 1: Purchases, 2: Saved

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            }),
        title: const Text('Profile', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 36, backgroundColor: AppColors.primary, child: Text('AD', style: TextStyle(fontSize: 20, color: Colors.white))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Alex Davis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 6),
                    Row(children: [Icon(Icons.location_on, size: 14, color: AppColors.textLight), SizedBox(width: 6), Text('Kigali, Rwanda', style: TextStyle(color: AppColors.textLight))]),
                    SizedBox(height: 6),
                    Text('Member since March 2025', style: TextStyle(color: AppColors.textLight, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6), boxShadow: [BoxShadow(color: const Color.fromRGBO(0,0,0,0.02), blurRadius: 4)]), child: const Text('Verified', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600))),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: const Color.fromRGBO(0,0,0,0.02), blurRadius: 6)]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(children: const [Icon(Icons.star, color: Colors.amber), SizedBox(height: 6), Text('4.9', style: TextStyle(fontWeight: FontWeight.bold)), SizedBox(height: 4), Text('Rating', style: TextStyle(fontSize: 12, color: AppColors.textLight))]),
                Column(children: const [Text('23', style: TextStyle(fontWeight: FontWeight.bold)), SizedBox(height: 4), Text('Items Sold', style: TextStyle(fontSize: 12, color: AppColors.textLight))]),
                Column(children: const [Text('12', style: TextStyle(fontWeight: FontWeight.bold)), SizedBox(height: 4), Text('Items Bought', style: TextStyle(fontSize: 12, color: AppColors.textLight))]),
                Column(children: const [Text('95%', style: TextStyle(fontWeight: FontWeight.bold)), SizedBox(height: 4), Text('Response Rate', style: TextStyle(fontSize: 12, color: AppColors.textLight))]),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(onTap: () => setState(() => _selectedIndex = 0), child: _buildTab(context, 'My Listings', isActive: _selectedIndex == 0)),
                GestureDetector(onTap: () => setState(() => _selectedIndex = 1), child: _buildTab(context, 'Purchases', isActive: _selectedIndex == 1)),
                GestureDetector(onTap: () => setState(() => _selectedIndex = 2), child: _buildTab(context, 'Saved', isActive: _selectedIndex == 2)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // content for selected tab
          if (_selectedIndex == 0) ..._myListingsSection(),
          if (_selectedIndex == 1) ..._purchasesSection(),
          if (_selectedIndex == 2) ..._savedSection(),
        ],
      ),
    );
  }

  List<Widget> _myListingsSection() {
    return [
      _listingTile('MacBook Pro 14"', '\$1,200', 'assets/images/macbook.png', views: 45, likes: 0, status: 'Active'),
      const SizedBox(height: 10),
      _listingTile('Gaming Chair', '\$180', 'assets/images/chair.png', views: 23, likes: 5, status: 'Sold'),
      const SizedBox(height: 10),
      _listingTile('Canon Camera Lens', '\$350', 'assets/images/lens.png', views: 31, likes: 12, status: 'Active'),
    ];
  }

  List<Widget> _purchasesSection() {
    // sample purchases list — use similar tile but with purchase-specific status
    return [
      _listingTile('Used MacBook Pro 13"', '\$900', 'assets/images/macbook.png', views: 0, likes: 0, status: 'Delivered'),
      const SizedBox(height: 10),
      _listingTile('Office Chair', '\$120', 'assets/images/chair.png', views: 0, likes: 0, status: 'In Transit'),
      const SizedBox(height: 10),
      _listingTile('Camera Lens (50mm)', '\$300', 'assets/images/lens.png', views: 0, likes: 0, status: 'Cancelled'),
    ];
  }

  List<Widget> _savedSection() {
    // saved items: compact view with a heart badge
    return [
      _savedTile('MacBook Pro 14"', '\$1,200', 'assets/images/macbook.png'),
      const SizedBox(height: 10),
      _savedTile('Gaming Chair', '\$180', 'assets/images/chair.png'),
      const SizedBox(height: 10),
      _savedTile('Canon Camera Lens', '\$350', 'assets/images/lens.png'),
    ];
  }

  Widget _buildTab(BuildContext context, String label, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: isActive ? BoxDecoration(color: AppColors.primary.withAlpha(20), borderRadius: BorderRadius.circular(8)) : null,
      child: Text(label, style: TextStyle(color: isActive ? AppColors.primary : AppColors.textLight, fontWeight: isActive ? FontWeight.w600 : FontWeight.w500)),
    );
  }

  Widget _listingTile(String title, String price, String asset, {int views = 0, int likes = 0, String status = 'Active'}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: const Color.fromRGBO(0,0,0,0.02), blurRadius: 6)]),
      child: Row(
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(8), child: SizedBox(width: 68, height: 68, child: Image.asset(asset, fit: BoxFit.cover))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 6), Text('$price${views > 0 ? ' • $views views' : ''}', style: const TextStyle(color: AppColors.textLight, fontSize: 12))])),
          const SizedBox(width: 8),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: status == 'Sold' ? AppColors.sold.withAlpha(20) : status == 'Delivered' ? AppColors.success.withAlpha(20) : AppColors.primary.withAlpha(10), borderRadius: BorderRadius.circular(8)), child: Text(status, style: TextStyle(color: status == 'Sold' ? AppColors.sold : status == 'Delivered' ? AppColors.success : AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12))),
        ],
      ),
    );
  }

  Widget _savedTile(String title, String price, String asset) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: const Color.fromRGBO(0,0,0,0.02), blurRadius: 6)]),
      child: Row(
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(8), child: SizedBox(width: 64, height: 64, child: Image.asset(asset, fit: BoxFit.cover))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 6), Text(price, style: const TextStyle(color: AppColors.textLight, fontSize: 12))])),
          const Icon(Icons.favorite, color: AppColors.danger),
        ],
      ),
    );
  }
}
