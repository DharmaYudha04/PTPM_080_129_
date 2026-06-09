import 'dart:math';

import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_colors.dart';

class GyroCubeVisualizer extends StatelessWidget {
  const GyroCubeVisualizer({required this.x, required this.y, super.key});

  final double x;
  final double y;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: CustomPaint(
        painter: _CubePainter(x, y),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _CubePainter extends CustomPainter {
  _CubePainter(this.rx, this.ry);

  final double rx;
  final double ry;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accentSecondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final center = Offset(size.width / 2, size.height / 2);
    const half = 40.0;
    final shift = Offset(sin(ry) * 20, cos(rx) * 16);
    final front = Rect.fromCenter(
      center: center,
      width: half * 2,
      height: half * 2,
    );
    final back = front.shift(shift);
    canvas.drawRect(front, paint);
    canvas.drawRect(back, paint);
    canvas.drawLine(front.topLeft, back.topLeft, paint);
    canvas.drawLine(front.topRight, back.topRight, paint);
    canvas.drawLine(front.bottomLeft, back.bottomLeft, paint);
    canvas.drawLine(front.bottomRight, back.bottomRight, paint);
  }

  @override
  bool shouldRepaint(covariant _CubePainter oldDelegate) =>
      oldDelegate.rx != rx || oldDelegate.ry != ry;
}
