import 'dart:math';
import 'package:flutter/material.dart';

class PaperTexture extends StatelessWidget {
  final Widget child;

  const PaperTexture({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PaperGrainPainter(),
      child: child,
    );
  }
}

class _PaperGrainPainter extends CustomPainter {
  // Your requested base color
  final Color baseColor = const Color.fromRGBO(231, 222, 190, 1);
  final Random _random = Random();

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Fill the background with the base color
    final paint = Paint()..color = baseColor;
    canvas.drawRect(Offset.zero & size, paint);

    // 2. Add "Noise" to simulate paper grain
    // We draw thousands of tiny specks
    final noisePaint = Paint()..strokeWidth = 1.0;

    // Density of the grain (higher = more textured)
    // Adjust loop count based on size for performance
    int density = (size.width * size.height * 0.05).toInt(); 

    for (int i = 0; i < density; i++) {
      // Random position
      double x = _random.nextDouble() * size.width;
      double y = _random.nextDouble() * size.height;

      // Randomly choose between slightly lighter or slightly darker specks
      bool isDark = _random.nextBool();
      
      // subtle opacity is key for realistic texture
      noisePaint.color = isDark 
          ? Colors.black.withOpacity(0.03) 
          : Colors.white.withOpacity(0.1);

      canvas.drawPoints(ui.PointMode.points, [Offset(x, y)], noisePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}