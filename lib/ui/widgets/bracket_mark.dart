import 'package:flutter/material.dart';
import 'package:kelima/core/theme/app_theme.dart';

class BracketMark extends StatelessWidget {
  final double size;
  final Color color;
  const BracketMark({super.key, this.size = 28, this.color = AppColors.ink});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _BracketPainter(color: color)),
    );
  }
}

class _BracketPainter extends CustomPainter {
  final Color color;
  _BracketPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.11
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final left = Path()
      ..moveTo(size.width * 0.40, size.height * 0.22)
      ..lineTo(size.width * 0.28, size.height * 0.22)
      ..lineTo(size.width * 0.28, size.height * 0.78)
      ..lineTo(size.width * 0.40, size.height * 0.78);

    final right = Path()
      ..moveTo(size.width * 0.60, size.height * 0.22)
      ..lineTo(size.width * 0.72, size.height * 0.22)
      ..lineTo(size.width * 0.72, size.height * 0.78)
      ..lineTo(size.width * 0.60, size.height * 0.78);

    canvas.drawPath(left, paint);
    canvas.drawPath(right, paint);
  }

  @override
  bool shouldRepaint(covariant _BracketPainter oldDelegate) =>
      oldDelegate.color != color;
}
