import 'package:flutter/material.dart';

/// BuildTrack's reusable orange-and-charcoal brand mark and wordmark.
class BuildTrackBrand extends StatelessWidget {
  final double iconSize;
  final bool showTagline;
  final bool compact;

  const BuildTrackBrand({
    super.key,
    this.iconSize = 76,
    this.showTagline = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : const Color(0xFF20232A);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: Size(iconSize, iconSize),
          painter: _BuildTrackMarkPainter(),
        ),
        if (!compact) ...[
          const SizedBox(height: 13),
          Text(
            'BuildTrack',
            style: TextStyle(
              color: titleColor,
              fontSize: iconSize * 0.30,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
          if (showTagline) ...[
            const SizedBox(height: 5),
            Text(
              'BUILDING TODAY. TRACKING TOMORROW.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: titleColor.withValues(alpha: 0.65),
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.15,
              ),
            ),
          ],
        ],
      ],
    );
  }
}

class _BuildTrackMarkPainter extends CustomPainter {
  static const orange = Color(0xFFF47A20);
  static const charcoal = Color(0xFF20232A);

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 100;
    final rect = Offset.zero & size;
    final radius = Radius.circular(size.width * 0.24);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, radius),
      Paint()..color = charcoal,
    );

    final p = Paint()
      ..color = orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final structure = Path()
      ..moveTo(22 * scale, 75 * scale)
      ..lineTo(22 * scale, 42 * scale)
      ..lineTo(50 * scale, 22 * scale)
      ..lineTo(78 * scale, 42 * scale)
      ..lineTo(78 * scale, 75 * scale);
    canvas.drawPath(structure, p);

    final tower = Path()
      ..moveTo(39 * scale, 75 * scale)
      ..lineTo(39 * scale, 48 * scale)
      ..lineTo(61 * scale, 48 * scale)
      ..lineTo(61 * scale, 75 * scale);
    canvas.drawPath(tower, p);

    final detail = Paint()
      ..color = Colors.white
      ..strokeWidth = 4 * scale
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(50 * scale, 56 * scale),
      Offset(50 * scale, 67 * scale),
      detail,
    );
    canvas.drawLine(
      Offset(22 * scale, 78 * scale),
      Offset(78 * scale, 78 * scale),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
