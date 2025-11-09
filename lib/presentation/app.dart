import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/cart/cart_bloc.dart';
import 'widgets/bottom_nav.dart';
import 'pages/home_page.dart';
import 'pages/cart_page.dart';
import 'pages/sell_item_page.dart';
import 'pages/profile_page.dart';
 

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const HomePage(),
    const SellItemPage(),
    const CartPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CartBloc()..add(ClearCart()),
      child: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNav(currentIndex: _selectedIndex, onTap: (index) => setState(() => _selectedIndex = index)),
      ),
    );
  }
}
