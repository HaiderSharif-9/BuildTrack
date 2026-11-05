import 'dart:math' as math;
import 'package:flutter/material.dart';

/// BuildTrack's reusable charcoal-and-gold construction mark and wordmark.
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
          size: Size(iconSize, iconSize * 0.8),
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
  static const charcoal = Color(0xFF17181B);
  static const gold = Color(0xFFF7B82F);

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width / 800, size.height / 640);
    final dx = (size.width - 800 * scale) / 2;
    final dy = (size.height - 640 * scale) / 2;
    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale);

    final structurePaint = Paint()
      ..color = charcoal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 48
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final structure = Path()
      ..moveTo(224, 490)
      ..lineTo(224, 250)
      ..lineTo(416, 96)
      ..lineTo(608, 250)
      ..lineTo(608, 490);
    canvas.drawPath(structure, structurePaint);

    final sideMarks = Path()
      ..moveTo(96, 490)
      ..lineTo(96, 354)
      ..lineTo(148, 354)
      ..moveTo(528, 490)
      ..lineTo(528, 308)
      ..moveTo(680, 490)
      ..lineTo(680, 340);
    canvas.drawPath(sideMarks, structurePaint);

    final doorway = Path()
      ..moveTo(352, 490)
      ..lineTo(352, 336)
      ..arcToPoint(
        const Offset(480, 336),
        radius: const Radius.circular(64),
        clockwise: false,
      )
      ..lineTo(480, 490)
      ..close();
    canvas.drawPath(doorway, Paint()..color = gold);

    final ground = Path()
      ..moveTo(24, 576)
      ..quadraticBezierTo(400, 448, 776, 576)
      ..close();
    canvas.drawPath(ground, Paint()..color = gold);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
