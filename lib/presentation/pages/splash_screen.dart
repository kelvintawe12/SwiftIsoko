import 'dart:math';
import 'package:flutter/material.dart';
import 'register_page.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

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
                // Logo and circular avatars section
                SizedBox(
                  height: 400,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Concentric circles
                      CustomPaint(
                        size: const Size(400, 400),
                        painter: ConcentricCirclesPainter(),
                      ),
                      // Center logo
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: CustomPaint(
                            size: const Size(90, 90),
                            painter: LogoPainter(),
                          ),
                        ),
                      ),
                      // Avatar positions (5 avatars around the circle)
                      ..._buildAvatars(),
                    ],
                  ),
                ),
                const Spacer(),
                // Title text
                const Text(
                  'Join SwiftIsoko for an\nunforgettable experience',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
                const Spacer(),
                // Get Started button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
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
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAvatars() {
    // Calculate positions based on circle radius for better placement
    const double baseRadius = 150.0;

    final avatarData = [
      // Top left
      {
        'angle': -2.5,
        'radius': baseRadius * 1.0,
        'image': 'assets/images/avatar.png'
      },
      // Top right
      {
        'angle': -0.6,
        'radius': baseRadius * 1.0,
        'image': 'assets/images/avatar.png'
      },
      // Left middle
      {
        'angle': 3.3,
        'radius': baseRadius * 0.95,
        'image': 'assets/images/avatar.png'
      },
      // Bottom left
      {
        'angle': 4.0,
        'radius': baseRadius * 1.05,
        'image': 'assets/images/avatar.png'
      },
      // Bottom right
      {
        'angle': 5.2,
        'radius': baseRadius * 1.0,
        'image': 'assets/images/avatar.png'
      },
    ];

    return avatarData.map((data) {
      final angle = data['angle'] as double;
      final radius = data['radius'] as double;

      // Calculate x and y positions based on angle
      final x = radius * cos(angle);
      final y = radius * sin(angle);

      return Positioned(
        left: 200 + x - 35, // Center of stack (200) + offset - half avatar size
        top: 200 + y - 35,
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              data['image'] as String,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFF6C63E8).withOpacity(0.3),
                  child: Icon(
                    Icons.person,
                    color: Colors.white.withOpacity(0.8),
                    size: 35,
                  ),
                );
              },
            ),
          ),
        ),
      );
    }).toList();
  }
}

class ConcentricCirclesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Paint for concentric circles
    final circlePaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw multiple concentric circles for depth
    canvas.drawCircle(center, 75, circlePaint);
    canvas.drawCircle(center, 110, circlePaint);
    canvas.drawCircle(center, 150, circlePaint);
    canvas.drawCircle(center, 190, circlePaint);

    // Draw curved connecting lines from center to avatars
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
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
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.38;

    // Draw the "Q" shape - outer circle
    canvas.drawCircle(center, radius, paint);

    // Draw the "Q" tail - diagonal line extending from bottom right
    final angle = pi / 4; // 45 degrees
    final tailStart = Offset(
      center.dx + radius * 0.55 * cos(angle),
      center.dy + radius * 0.55 * sin(angle),
    );
    final tailEnd = Offset(
      center.dx + radius * 0.95 * cos(angle),
      center.dy + radius * 0.95 * sin(angle),
    );
    canvas.drawLine(tailStart, tailEnd, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
