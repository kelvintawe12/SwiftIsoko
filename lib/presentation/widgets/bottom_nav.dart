import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;
  const BottomNav({super.key, this.currentIndex = 0, this.onTap});

  @override
  Widget build(BuildContext context) {
    Color activeColor(int idx) => idx == currentIndex ? Colors.white : Colors.white70;

    return SizedBox(
      height: 76,
      child: Container(
        height: 56,
        color: AppColors.primary,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(onPressed: () => onTap?.call(0), icon: Icon(Icons.home, color: activeColor(0))),
            IconButton(onPressed: () => onTap?.call(1), icon: Icon(Icons.menu, color: activeColor(1))),
            // center plus inline and same alignment
            GestureDetector(
              onTap: () => onTap?.call(1),
              child: Container(
                width: 44,
                height: 40,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                alignment: Alignment.center,
                child: Icon(Icons.add, color: AppColors.primary, size: 24),
              ),
            ),
            IconButton(onPressed: () => onTap?.call(2), icon: Icon(Icons.shopping_cart, color: activeColor(2))),
            IconButton(onPressed: () => onTap?.call(3), icon: Icon(Icons.person, color: activeColor(3))),
          ],
        ),
      ),
    );
  }
}
