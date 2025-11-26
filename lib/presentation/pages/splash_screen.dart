import 'dart:math';
import 'package:flutter/material.dart';
import 'package:swapit_marketplace/presentation/auth/signup_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _rotAnim;
  late final AnimationController _introCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _textScaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _scaleAnim = Tween<double>(begin: 0.96, end: 1.04).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _rotAnim = Tween<double>(begin: -0.02, end: 0.02).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

    // intro controller: one-shot fade/slide for title and button
    _introCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _introCtrl, curve: Curves.easeOut));

    // subtle text scale pulse (continuous)
    _textScaleAnim = Tween<double>(begin: 0.99, end: 1.01).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _ctrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        _ctrl.reverse();
      } else if (s == AnimationStatus.dismissed) {
        _ctrl.forward();
      }
    });
    _ctrl.forward();
    // start intro animation once
    _introCtrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _introCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF8B7BE8),
              Color(0xFF6C63E8),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const Spacer(flex: 2),
                // Animated logo section
                SizedBox(
                  height: 400,
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _ctrl,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotAnim.value,
                          child: Transform.scale(
                            scale: _scaleAnim.value,
                            child: child,
                          ),
                        );
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // subtle concentric background circles (reuse painter)
                          SizedBox(
                            width: 300,
                            height: 300,
                            child: CustomPaint(
                              painter: ConcentricCirclesPainter(),
                            ),
                          ),
                          Image.asset(
                            'assets/images/round.png',
                            width: 260,
                            height: 260,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                // Title text with subtle continuous pulse and intro fade
                AnimatedBuilder(
                  animation: Listenable.merge([_ctrl, _introCtrl]),
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnim.value,
                      child: Transform.scale(
                        scale: _textScaleAnim.value,
                        child: child,
                      ),
                    );
                  },
                  child: AnimatedBuilder(
                    animation: _ctrl,
                    builder: (context, _) {
                      return ShaderMask(
                        blendMode: BlendMode.srcATop,
                        shaderCallback: (bounds) {
                          final width = bounds.width;
                          final dx = (sin(_ctrl.value * 2 * pi) * 0.5 + 0.5) * width;
                          return LinearGradient(
                            colors: [
                              Colors.white.withAlpha((0.95 * 255).round()),
                              Colors.white.withAlpha((0.35 * 255).round()),
                              Colors.white.withAlpha((0.95 * 255).round()),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ).createShader(Rect.fromLTWH(dx - width, 0, width * 2, bounds.height));
                        },
                        child: Text(
                          'Join SwiftIsoko for an\nunforgettable experience',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Spacer(),
                // Get Started button: always visible, small intro slide
                AnimatedBuilder(
                  animation: _introCtrl,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - _fadeAnim.value)),
                      child: child,
                    );
                  },
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const SignUpScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF6C63E8),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ConcentricCirclesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Paint for concentric circles
    final circlePaint = Paint()
      ..color = const Color.fromRGBO(255, 255, 255, 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw multiple concentric circles for depth
    canvas.drawCircle(center, 75, circlePaint);
    canvas.drawCircle(center, 110, circlePaint);
    canvas.drawCircle(center, 150, circlePaint);
    canvas.drawCircle(center, 190, circlePaint);

    // Draw curved connecting lines from center to avatars
    final linePaint = Paint()
      ..color = const Color.fromRGBO(255, 255, 255, 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw connecting curves to avatar positions
    final angles = [-2.5, -0.6, 3.3, 4.0, 5.2];
    const double baseRadius = 150.0;

    for (final angle in angles) {
      final x = baseRadius * cos(angle);
      final y = baseRadius * sin(angle);
      final avatarPos = Offset(center.dx + x, center.dy + y);

      // Draw curve from center area to avatar
      final path = Path();
      path.moveTo(center.dx + 60 * cos(angle), center.dy + 60 * sin(angle));
      path.quadraticBezierTo(
        center.dx + (baseRadius * 0.6) * cos(angle),
        center.dy + (baseRadius * 0.6) * sin(angle),
        avatarPos.dx,
        avatarPos.dy,
      );
      canvas.drawPath(path, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6C63E8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.40;

    // Draw the "Q" shape - outer circle
    canvas.drawCircle(center, radius, paint);

    // Draw the "Q" tail - diagonal line extending from bottom right
    final angle = pi / 4; // 45 degrees
    final tailStart = Offset(
      center.dx + radius * 0.50 * cos(angle),
      center.dy + radius * 0.50 * sin(angle),
    );
    final tailEnd = Offset(
      center.dx + radius * 1.0 * cos(angle),
      center.dy + radius * 1.0 * sin(angle),
    );
    canvas.drawLine(tailStart, tailEnd, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
