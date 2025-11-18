import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../widgets/animated_like.dart';
import '../../data/likes_service.dart';
import '../../data/profile_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 0; // 0: My Listings, 1: Purchases, 2: Saved
  String _name = 'Alex Davis';
  String _location = 'Kigali, Rwanda';
  String? _avatarPath;
  String _bio = '';

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final svc = await ProfileService.getInstance();
    if (!mounted) return;
    setState(() {
      _name = svc.name;
      _location = svc.location;
      _avatarPath = svc.avatarPath;
      _bio = svc.bio;
    });
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(RegExp(r'\s+'));
    final initials = parts.where((p) => p.isNotEmpty).take(2).map((p) => p[0]).join();
    return initials.isEmpty ? 'U' : initials.toUpperCase();
  }

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
          },
        ),
        title: const Text('Profile', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            onPressed: () => _showEditProfileDialog(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(36),
                      color: AppColors.primary,
                    ),
                    child: ClipOval(
                      child: _avatarPath == null
                          ? Center(
                              child: Text(
                                _getInitials(_name),
                                style: const TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                            )
                          : Image.file(
                              File(_avatarPath!),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppColors.primary,
                                  child: Center(
                                    child: Text(
                                      _getInitials(_name),
                                      style: const TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 14, color: AppColors.textLight),
                            const SizedBox(width: 6),
                            Text(
                              _location,
                              style: const TextStyle(color: AppColors.textLight),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Member since March 2025',
                          style: const TextStyle(
                              color: AppColors.textLight, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Edit avatar button
              Positioned(
                left: 56,
                top: 48,
                child: GestureDetector(
                  onTap: () => _showEditProfileDialog(context),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromRGBO(0, 0, 0, 0.08),
                          blurRadius: 6,
                        )
                      ],
                    ),
                    child: const Icon(Icons.edit, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromRGBO(0, 0, 0, 0.02),
                  blurRadius: 6,
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statItem(Icons.star, '4.9', 'Rating'),
                _statItem(Icons.inventory_2, '23', 'Items Sold'),
                _statItem(Icons.shopping_bag, '12', 'Items Bought'),
                _statItem(Icons.timeline, '95%', 'Response Rate'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F8F0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle,
                      color: Color(0xFF1FBF6F), size: 16),
                  const SizedBox(width: 8),
                  const Text(
                    'Verified Seller',
                    style: TextStyle(
                        color: Color(0xFF1FBF6F), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTab(0, Icons.inventory_2, 'My Listings'),
                _buildTab(1, Icons.receipt_long, 'Purchases'),
                _buildTab(2, Icons.bookmark, 'Saved'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Content
          if (_selectedIndex == 0) ..._myListingsSection(),
          if (_selectedIndex == 1) ..._purchasesSection(),
          if (_selectedIndex == 2) ..._savedSection(),
        ],
      ),
    );
  }

  Widget _buildTab(int index, IconData icon, String label) {
    final isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: _buildIconTab(context, icon, label, isActive: isActive),
    );
  }

  List<Widget> _myListingsSection() {
    return [
      _listingTile('MacBook Pro 14"', '\$1,200', 'assets/images/macbook.png',
          views: 45, likes: 0, status: 'Active'),
      const SizedBox(height: 10),
      _listingTile('Gaming Chair', '\$180', 'assets/images/chair.png',
          views: 23, likes: 5, status: 'Sold'),
      const SizedBox(height: 10),
      _listingTile('Canon Camera Lens', '\$350', 'assets/images/lens.png',
          views: 31, likes: 12, status: 'Active'),
    ];
  }

  List<Widget> _purchasesSection() {
    return [
      _listingTile('Used MacBook Pro 13"', '\$900', 'assets/images/macbook.png',
          views: 0, likes: 0, status: 'Delivered'),
      const SizedBox(height: 10),
      _listingTile('Office Chair', '\$120', 'assets/images/chair.png',
          views: 0, likes: 0, status: 'In Transit'),
      const SizedBox(height: 10),
      _listingTile('Camera Lens (50mm)', '\$300', 'assets/images/lens.png',
          views: 0, likes: 0, status: 'Cancelled'),
    ];
  }

  List<Widget> _savedSection() {
    return [
      _savedTile('MacBook Pro 14"', '\$1,200', 'assets/images/macbook.png'),
      const SizedBox(height: 10),
      _savedTile('Gaming Chair', '\$180', 'assets/images/chair.png'),
      const SizedBox(height: 10),
      _savedTile('Canon Camera Lens', '\$350', 'assets/images/lens.png'),
    ];
  }

  Widget _buildIconTab(BuildContext context, IconData icon, String label,
      {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        boxShadow: isActive
            ? [BoxShadow(color: const Color.fromRGBO(0, 0, 0, 0.04), blurRadius: 6)]
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary.withAlpha(20)
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: isActive ? AppColors.primary : AppColors.textLight,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppColors.primary : AppColors.textLight,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon,
            color: icon == Icons.star ? Colors.amber : AppColors.textLight),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Sold':
      case 'Cancelled':
        return AppColors.sold;
      case 'Delivered':
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }

  Widget _listingTile(String title, String price, String asset,
      {int views = 0, int likes = 0, String status = 'Active'}) {
    final statusColor = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: const Color.fromRGBO(0, 0, 0, 0.02), blurRadius: 6)
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 68,
              height: 68,
              child: Image.asset(asset, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(price,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                if (views > 0 || likes > 0)
                  Row(
                    children: [
                      const Icon(Icons.remove_red_eye,
                          size: 14, color: AppColors.textLight),
                      const SizedBox(width: 6),
                      Text('$views',
                          style: const TextStyle(
                              color: AppColors.textLight, fontSize: 12)),
                      const SizedBox(width: 12),
                      const Icon(Icons.favorite_border,
                          size: 14, color: AppColors.textLight),
                      const SizedBox(width: 6),
                      Text('$likes',
                          style: const TextStyle(
                              color: AppColors.textLight, fontSize: 12)),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _savedTile(String title, String price, String asset) {
    return Container(
      key: ValueKey(title), // For FutureBuilder rebuilds
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: const Color.fromRGBO(0, 0, 0, 0.02), blurRadius: 6)
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 64,
              height: 64,
              child: Image.asset(asset, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(price,
                    style: const TextStyle(
                        color: AppColors.textLight, fontSize: 12)),
              ],
            ),
          ),
          FutureBuilder<LikesService>(
            future: LikesService.getInstance(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox(width: 36, height: 36);
              }
              final svc = snapshot.data!;
              final isLiked = svc.getLikedSet().contains(title);
              return AnimatedLike(
                isLiked: isLiked,
                onTap: () async {
                  await svc.toggleLiked(title);
                  setState(() {});
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final nameCtrl = TextEditingController(text: _name);
    final locationCtrl = TextEditingController(text: _location);
    final bioCtrl = TextEditingController(text: _bio);
    String? pickedPath = _avatarPath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            Future<void> pickAvatar() async {
              final picked = await _picker.pickImage(
                source: ImageSource.gallery,
                imageQuality: 80,
              );
              if (picked != null) {
                setStateSheet(() => pickedPath = picked.path);
              }
            }

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 18,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 18,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Edit profile',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: AppColors.primary,
                          child: pickedPath == null
                              ? Text(
                                  _getInitials(nameCtrl.text),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 24),
                                )
                              : ClipOval(
                                  child: Image.file(
                                    File(pickedPath!),
                                    width: 72,
                                    height: 72,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Text(
                                      _getInitials(nameCtrl.text),
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 24),
                                    ),
                                  ),
                                ),
                        ),
                        Positioned(
                          right: -4,
                          bottom: -4,
                          child: GestureDetector(
                            onTap: pickAvatar,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(8),
                              child: const Icon(Icons.camera_alt,
                                  size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Full name'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: locationCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Location'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: bioCtrl,
                    decoration:
                        const InputDecoration(labelText: 'About you'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final svc = await ProfileService.getInstance();
                          await svc.save(
                            nameCtrl.text.trim(),
                            locationCtrl.text.trim(),
                            pickedPath,
                            bioCtrl.text.trim().isEmpty
                                ? null
                                : bioCtrl.text.trim(),
                          );
                          await _loadProfile();
                          if (!ctx.mounted) return;
                          Navigator.of(ctx).pop();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Profile updated')),
                          );
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    // Dispose controllers when done
    Future.delayed(const Duration(seconds: 5), () {
      nameCtrl.dispose();
      locationCtrl.dispose();
      bioCtrl.dispose();
    });
  }
}