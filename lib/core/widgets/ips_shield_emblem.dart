import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app_styles/ips_colors.dart';

/// The official IPS seal, reproduced as vector art (not an image asset) so
/// it renders crisply at any size and stays perfectly in sync with the
/// app's color tokens: a double navy ring border, "نقابة المبرمجين
/// العراقيين" arced across the top, a gold shield with a twin-tower "U"
/// motif + "2025" badge centered, and a navy ribbon banner reading "IRAQI
/// PROGRAMMERS SYNDICATE" curved along the bottom. Shared by
/// Welcome/OTP/Splash so the mark is pixel-identical wherever it appears.
class IpsShieldEmblem extends StatelessWidget {
  const IpsShieldEmblem({super.key, this.size = 128});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(size: Size(size, size), painter: _SealPainter()),
    );
  }
}

class _SealPainter extends CustomPainter {
  const _SealPainter();

  static const _bronze = Color(0xFF8A6316);
  static const _cream = Color(0xFFF4E4BC);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.width / 2;

    _paintRings(canvas, center, r);
    _paintTopCalligraphy(canvas, center, r);
    _paintRibbon(canvas, center, r);
    _paintShield(canvas, center, r);
  }

  void _paintRings(Canvas canvas, Offset center, double r) {
    canvas.drawCircle(center, r, Paint()..color = Colors.white);
    canvas.drawCircle(
      center,
      r - 2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.05
        ..color = IpsColors.primary,
    );
    canvas.drawCircle(
      center,
      r - r * 0.12,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = IpsColors.primary.withValues(alpha: 0.55),
    );
  }

  /// Places [segments] (whole words for Arabic so joining forms stay
  /// intact, or single characters for Latin) along the circle of [radius]
  /// centered on [baseTheta] (radians, standard math convention with a
  /// y-down canvas: -pi/2 = top, pi/2 = bottom). [rotationOffset] controls
  /// whether glyph "up" points outward (top arc) or toward the reader
  /// (bottom ribbon).
  void _paintArc(
    Canvas canvas,
    List<String> segments,
    Offset center,
    double radius,
    double baseTheta,
    double rotationOffset,
    TextStyle style,
    TextDirection direction,
  ) {
    final painters = segments
        .map(
          (s) => TextPainter(
            text: TextSpan(text: s, style: style),
            textDirection: direction,
          )..layout(),
        )
        .toList();
    final totalAngle = painters.fold<double>(
      0,
      (sum, tp) => sum + tp.width / radius,
    );

    var theta = baseTheta - totalAngle / 2;
    for (final tp in painters) {
      final halfAngle = (tp.width / radius) / 2;
      theta += halfAngle;
      final pos =
          center + Offset(radius * math.cos(theta), radius * math.sin(theta));
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(theta + rotationOffset);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
      theta += halfAngle;
    }
  }

  void _paintTopCalligraphy(Canvas canvas, Offset center, double r) {
    _paintArc(
      canvas,
      const ['نقابة', 'المبرمجين', 'العراقيين'],
      center,
      r * 0.72,
      -math.pi / 2,
      math.pi / 2,
      TextStyle(
        color: IpsColors.primary,
        fontFamily: 'IBMPlexSansArabic',
        fontWeight: FontWeight.w700,
        fontSize: r * 0.155,
      ),
      TextDirection.rtl,
    );
  }

  void _paintRibbon(Canvas canvas, Offset center, double r) {
    final ribbonRadius = r * 0.70;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: ribbonRadius),
      math.pi * 0.18,
      math.pi * 0.64,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.30
        ..strokeCap = StrokeCap.round
        ..color = IpsColors.primary,
    );

    // Reversed: at this baseTheta/rotationOffset combination (bottom arc),
    // iterating characters forward places them right-to-left, so the
    // source string must be pre-reversed to read correctly left-to-right.
    _paintArc(
      canvas,
      'IRAQI PROGRAMMERS SYNDICATE'.split('').reversed.toList(),
      center,
      ribbonRadius,
      math.pi / 2,
      -math.pi / 2,
      TextStyle(
        color: Colors.white,
        fontFamily: 'IBMPlexSansArabic',
        fontWeight: FontWeight.w700,
        fontSize: r * 0.095,
        letterSpacing: 0.2,
      ),
      TextDirection.ltr,
    );
  }

  void _paintShield(Canvas canvas, Offset center, double r) {
    final w = r * 1.02;
    final h = w * 1.12;
    final left = center.dx - w / 2;
    final top = center.dy - h / 2 - r * 0.02;

    final path = Path()
      ..moveTo(left + w * 0.5, top)
      ..lineTo(left + w, top + h * 0.16)
      ..lineTo(left + w, top + h * 0.55)
      ..cubicTo(
        left + w,
        top + h * 0.82,
        left + w * 0.74,
        top + h * 0.94,
        left + w * 0.5,
        top + h,
      )
      ..cubicTo(
        left + w * 0.26,
        top + h * 0.94,
        left,
        top + h * 0.82,
        left,
        top + h * 0.55,
      )
      ..lineTo(left, top + h * 0.16)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [IpsColors.gold, _bronze],
        ).createShader(Rect.fromLTWH(left, top, w, h)),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = IpsColors.primary.withValues(alpha: 0.45),
    );

    canvas.save();
    canvas.clipPath(path);
    final towerPaint = Paint()..color = _cream;
    _paintTower(
      canvas,
      left + w * 0.14,
      top + h * 0.18,
      w * 0.22,
      h * 0.52,
      towerPaint,
    );
    _paintTower(
      canvas,
      left + w * 0.64,
      top + h * 0.18,
      w * 0.22,
      h * 0.52,
      towerPaint,
    );

    final weaveTop = top + h * 0.52;
    final weaveBottom = top + h * 0.82;
    final weaveLeft = left + w * 0.30;
    final weaveRight = left + w * 0.70;
    final weavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = _cream.withValues(alpha: 0.85);
    final span = weaveBottom - weaveTop;
    for (var x = weaveLeft - span; x <= weaveRight + span; x += w * 0.045) {
      canvas.drawLine(
        Offset(x, weaveTop),
        Offset(x + span, weaveBottom),
        weavePaint,
      );
      canvas.drawLine(
        Offset(x + span, weaveTop),
        Offset(x, weaveBottom),
        weavePaint,
      );
    }
    canvas.restore();

    final badgeCenter = Offset(center.dx, top + h * 0.885);
    final badgeRect = Rect.fromCenter(
      center: badgeCenter,
      width: w * 0.5,
      height: h * 0.12,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(badgeRect, Radius.circular(badgeRect.height / 2)),
      Paint()..color = IpsColors.primary,
    );
    final badgeText = TextPainter(
      text: TextSpan(
        text: '2025',
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'IBMPlexSansArabic',
          fontWeight: FontWeight.w700,
          fontSize: h * 0.095,
          letterSpacing: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    badgeText.paint(
      canvas,
      badgeCenter - Offset(badgeText.width / 2, badgeText.height / 2),
    );
  }

  void _paintTower(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    Paint paint,
  ) {
    final crenelTop = y;
    final shaftTop = y + h * 0.16;
    final crenelWidth = w / 3;
    final path = Path()..moveTo(x, y + h);
    path.lineTo(x, shaftTop);
    var cx = x;
    for (var i = 0; i < 3; i++) {
      final midX = cx + crenelWidth / 2;
      final nextX = cx + crenelWidth;
      if (i.isEven) {
        path.lineTo(cx, crenelTop);
        path.lineTo(midX, crenelTop);
        path.lineTo(midX, shaftTop);
        path.lineTo(nextX, shaftTop);
      } else {
        path.lineTo(midX, shaftTop);
        path.lineTo(midX, crenelTop);
        path.lineTo(nextX, crenelTop);
        path.lineTo(nextX, shaftTop);
      }
      cx = nextX;
    }
    path.lineTo(x + w, shaftTop);
    path.lineTo(x + w, y + h);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SealPainter oldDelegate) => false;
}
