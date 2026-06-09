import 'dart:math';

import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_colors.dart';

class QuizTimerArc extends StatelessWidget {
  const QuizTimerArc({required this.progress, super.key});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: CustomPaint(painter: _TimerPainter(progress)),
    );
  }
}

class _TimerPainter extends CustomPainter {
  _TimerPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..color = Color.lerp(
            AppColors.destructive,
            AppColors.accentTertiary,
            progress,
          ) ??
          AppColors.accentTertiary
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect.deflate(8), -pi / 2, 2 * pi * progress, false, paint);
  }

  @override
  bool shouldRepaint(covariant _TimerPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
