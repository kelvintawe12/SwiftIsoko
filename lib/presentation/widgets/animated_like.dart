import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

/// A like button that plays a short wavy/ripple animation when toggled on.
class AnimatedLike extends StatefulWidget {
  final bool isLiked;
  final VoidCallback onTap;
  const AnimatedLike({super.key, required this.isLiked, required this.onTap});

  @override
  State<AnimatedLike> createState() => _AnimatedLikeState();
}

class _AnimatedLikeState extends State<AnimatedLike> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
  late final Animation<double> _scale;
  late final List<Animation<double>> _ripples;

  @override
  void initState() {
    super.initState();
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.25).chain(CurveTween(curve: Curves.easeOut)), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)), weight: 60),
    ]).animate(_ctrl);

    // create three staggered ripple animations from 0..1
    _ripples = List.generate(3, (i) {
      final start = 0.0 + i * 0.08;
      final end = 0.65 + i * 0.12;
      return CurvedAnimation(parent: _ctrl, curve: Interval(start, end, curve: Curves.easeOut));
    });
  }

  @override
  void didUpdateWidget(covariant AnimatedLike oldWidget) {
    super.didUpdateWidget(oldWidget);
    // only play the animation when it becomes liked
    if (!oldWidget.isLiked && widget.isLiked) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ripples
            ...List.generate(_ripples.length, (i) {
              return AnimatedBuilder(
                animation: _ctrl,
                builder: (context, child) {
                  final v = _ripples[i].value;
                  final size = 18.0 + v * 36.0; // expand
                  final opacity = (1.0 - v).clamp(0.0, 1.0);
                  return Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Color.fromRGBO(108, 92, 231, (0.6 * opacity).clamp(0.0, 1.0)),
                        width: 2 * (0.6 * opacity),
                      ),
                    ),
                  );
                },
              );
            }).reversed,

            // white circular background like the original
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: const Color.fromRGBO(255,255,255,0.95), shape: BoxShape.circle),
            ),

            // heart icon with scale animation
            AnimatedBuilder(
              animation: _ctrl,
              builder: (context, child) {
                final s = widget.isLiked ? _scale.value : 1.0;
                return Transform.scale(
                  scale: s,
                  child: Icon(
                    widget.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: widget.isLiked ? AppColors.sold : AppColors.textLight,
                    size: 18,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
