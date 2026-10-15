import 'package:flutter/material.dart';
import '../config/theme.dart';

class ArborGraphic extends StatelessWidget {
  const ArborGraphic({
    super.key,
    this.color = Gr0veColors.grover,
    this.width = 240,
    this.height = 200,
    this.opacity = 0.55,
  });

  final Color color;
  final double width;
  final double height;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _ArborSidePainter(color: color, opacity: opacity),
      ),
    );
  }
}

class _ArborSidePainter extends CustomPainter {
  const _ArborSidePainter({required this.color, required this.opacity});

  final Color color;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    const double origW = 269.0;
    const double origH = 226.0;

    final double scale = size.width / origW;

    canvas.save();
    canvas.scale(scale);

    canvas.clipRect(const Rect.fromLTWH(0, 0, origW, origH));

    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path1 = Path();
    path1.moveTo(156, 15);
    path1.lineTo(268, 15);
    path1.cubicTo(290.593, 15, 309, 33.3956, 309, 56.2002);
    path1.lineTo(309, 224.8);
    path1.cubicTo(309, 247.604, 290.593, 266, 268, 266);
    path1.lineTo(156, 266);
    path1.cubicTo(133.407, 266, 115, 247.604, 115, 224.8);
    path1.lineTo(115, 56.2002);
    path1.cubicTo(115, 33.3956, 133.407, 15, 156, 15);
    path1.close();

    final path2 = Path();
    path2.moveTo(56, 101);
    path2.lineTo(168, 101);
    path2.cubicTo(190.593, 101, 209, 119.396, 209, 142.2);
    path2.lineTo(209, 310.8);
    path2.cubicTo(209, 333.604, 190.593, 352, 168, 352);
    path2.lineTo(56, 352);
    path2.cubicTo(33.4067, 352, 15, 333.604, 15, 310.8);
    path2.lineTo(15, 142.2);
    path2.cubicTo(15, 119.396, 33.4067, 101, 56, 101);
    path2.close();

    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ArborSidePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.opacity != opacity;
  }
}
