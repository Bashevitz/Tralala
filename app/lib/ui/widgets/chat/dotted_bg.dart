import 'package:flutter/material.dart';

class DottedBackground extends StatelessWidget {
  const DottedBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: DottedPainter(),
        );
      },
    );
  }
}

class DottedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.blue.withOpacity(0.25)
          ..style = PaintingStyle.fill;

    const spacing = 20.0; // Space between dots
    const dotRadius = 1.5; // Size of each dot
    const startX = 10.0; // Fixed starting X position
    const startY = 10.0; // Fixed starting Y position

    for (double i = startX; i < size.width; i += spacing) {
      for (double j = startY; j < size.height; j += spacing) {
        canvas.drawCircle(Offset(i, j), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
