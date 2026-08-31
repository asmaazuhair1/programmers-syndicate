import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app_styles/ips_colors.dart';

/// Full-bleed animated backdrop shared by every light, pre-auth screen
/// (Welcome, OTP, Registration): a light institutional surface (white /
/// cool-gray wash, not a dark panel) built from a faint drifting technical
/// grid, a rotating gold security orbit, slow-floating gold particles, and
/// a pair of architectural corner frames. Everything runs off a single
/// [AnimationController] (one ticker, not several) so the motion stays
/// cheap and perfectly in sync.
///
/// Deliberately restrained in composition — nothing reshuffles or jumps,
/// only continuous, low-amplitude motion, so it reads as "alive" behind
/// whatever [IpsSecurityFrame] sits on top of it without ever competing
/// with it for attention.
class IpsTechnicalBackdrop extends StatefulWidget {
  const IpsTechnicalBackdrop({super.key});

  @override
  State<IpsTechnicalBackdrop> createState() => _IpsTechnicalBackdropState();
}

class _IpsTechnicalBackdropState extends State<IpsTechnicalBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 26),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            size: Size.infinite,
            painter: _TechnicalBackdropPainter(t: _controller.value),
          );
        },
      ),
    );
  }
}

class _TechnicalBackdropPainter extends CustomPainter {
  const _TechnicalBackdropPainter({required this.t});

  /// 0..1, looping.
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    _paintBaseWash(canvas, size);
    _TechnicalGrid.paint(canvas, size, t);
    _ArchitecturalCorners.paint(canvas, size);
    _DecorativeCircuit.paint(canvas, size);
    _GoldOrbit.paint(canvas, size, t);
    _SignalPulseNode.paint(canvas, size, t);
    _FloatingParticles.paint(canvas, size, t);
  }

  /// Base surface: near-white with the faintest navy-to-gold radial wash so
  /// the panel doesn't read as flat printer paper. This is what makes the
  /// screen unambiguously LIGHT rather than a re-tinted dark surface.
  void _paintBaseWash(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            IpsColors.surfaceMuted,
            IpsColors.surface,
            IpsColors.surfaceMuted,
          ],
        ).createShader(rect),
    );
    final glow = Rect.fromCircle(
      center: Offset(size.width * 0.82, size.height * 0.10),
      radius: size.width * 0.9,
    );
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment.topRight,
          radius: 1.1,
          colors: [
            IpsColors.gold.withValues(alpha: 0.07),
            IpsColors.gold.withValues(alpha: 0.0),
          ],
        ).createShader(glow),
    );
    final navyGlow = Rect.fromCircle(
      center: Offset(size.width * 0.10, size.height * 0.94),
      radius: size.width * 0.9,
    );
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment.bottomLeft,
          radius: 1.1,
          colors: [
            IpsColors.primary.withValues(alpha: 0.05),
            IpsColors.primary.withValues(alpha: 0.0),
          ],
        ).createShader(navyGlow),
    );
  }

  @override
  bool shouldRepaint(covariant _TechnicalBackdropPainter oldDelegate) =>
      oldDelegate.t != t;
}

/// Faint drifting blueprint grid — deep navy hairlines at very low alpha so
/// it reads as a technical surface rather than decoration, with a hint of
/// gold on every fourth line. Drifts slowly diagonally via [t].
class _TechnicalGrid {
  const _TechnicalGrid._();

  static void paint(Canvas canvas, Size size, double t) {
    const spacing = 36.0;
    final drift = t * spacing;

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6
      ..color = IpsColors.primary.withValues(alpha: 0.045);
    final accentPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7
      ..color = IpsColors.gold.withValues(alpha: 0.09);

    var index = 0;
    for (
      var x = -spacing + (drift % spacing);
      x < size.width + spacing;
      x += spacing
    ) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        index % 4 == 0 ? accentPaint : linePaint,
      );
      index++;
    }
    index = 0;
    for (
      var y = -spacing + (drift % spacing);
      y < size.height + spacing;
      y += spacing
    ) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        index % 4 == 0 ? accentPaint : linePaint,
      );
      index++;
    }
  }
}

/// Two architectural corner brackets (top-left, bottom-right) — thin navy
/// L-frames that echo a blueprint/instrument-panel border, anchoring the
/// screen edges the way [IpsSecurityFrame] anchors the center.
class _ArchitecturalCorners {
  const _ArchitecturalCorners._();

  static void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = IpsColors.primary.withValues(alpha: 0.14);
    const armLength = 46.0;
    const inset = 22.0;

    // Top-left.
    canvas.drawLine(
      const Offset(inset, inset),
      const Offset(inset + armLength, inset),
      paint,
    );
    canvas.drawLine(
      const Offset(inset, inset),
      const Offset(inset, inset + armLength),
      paint,
    );

    // Bottom-right.
    canvas.drawLine(
      Offset(size.width - inset, size.height - inset),
      Offset(size.width - inset - armLength, size.height - inset),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - inset, size.height - inset),
      Offset(size.width - inset, size.height - inset - armLength),
      paint,
    );
  }
}

/// Thin rotating gold ring built from broken arc segments, anchored just
/// off the top-right corner — a slow, precise "security orbit" rather than
/// a full glowing halo. Tuned down in opacity for the light surface.
class _GoldOrbit {
  const _GoldOrbit._();

  static void paint(Canvas canvas, Size size, double t) {
    final center = Offset(size.width * 0.88, size.height * 0.14);
    final radius = math.min(size.width, size.height) * 0.26;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = IpsColors.gold.withValues(alpha: 0.34);

    const segments = 5;
    const gap = 0.18;
    final sweepPer = (2 * math.pi / segments) - gap;
    final rotation = t * 2 * math.pi;
    for (var i = 0; i < segments; i++) {
      final start = rotation + i * (sweepPer + gap);
      canvas.drawArc(rect, start, sweepPer, false, paint);
    }

    final innerRect = Rect.fromCircle(center: center, radius: radius * 0.70);
    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = IpsColors.primary.withValues(alpha: 0.18);
    canvas.drawArc(
      innerRect,
      -rotation * 1.4,
      math.pi * 0.5,
      false,
      innerPaint,
    );
    canvas.drawArc(
      innerRect,
      -rotation * 1.4 + math.pi,
      math.pi * 0.5,
      false,
      innerPaint,
    );
  }
}

/// A small pulsing node in the lower-left — reads as a "signal beacon"
/// echoing the gold orbit, independent of the shield emblem inside the
/// frame.
class _SignalPulseNode {
  const _SignalPulseNode._();

  static void paint(Canvas canvas, Size size, double t) {
    final center = Offset(size.width * 0.12, size.height * 0.86);
    final pulse = 0.5 + 0.5 * math.sin(t * 2 * math.pi);

    canvas.drawCircle(
      center,
      18 + pulse * 6,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = IpsColors.gold.withValues(alpha: 0.10 + pulse * 0.10),
    );
    canvas.drawCircle(
      center,
      3.0,
      Paint()..color = IpsColors.gold.withValues(alpha: 0.55),
    );
  }
}

/// Faint angular circuit tracery with node terminators in deep navy —
/// reads as blueprint annotation at very low opacity against the light
/// field.
class _DecorativeCircuit {
  const _DecorativeCircuit._();

  static void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = IpsColors.primary.withValues(alpha: 0.08);
    final nodePaint = Paint()..color = IpsColors.gold.withValues(alpha: 0.30);

    void trace(List<Offset> points) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (final p in points.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, linePaint);
      canvas.drawCircle(points.last, 2.2, nodePaint);
    }

    trace([
      Offset(0, size.height * 0.28),
      Offset(size.width * 0.13, size.height * 0.28),
      Offset(size.width * 0.13, size.height * 0.22),
      Offset(size.width * 0.23, size.height * 0.22),
    ]);
    trace([
      Offset(size.width, size.height * 0.64),
      Offset(size.width * 0.85, size.height * 0.64),
      Offset(size.width * 0.85, size.height * 0.72),
      Offset(size.width * 0.73, size.height * 0.72),
    ]);
  }
}

/// A handful of tiny gold particles drifting slowly upward and sideways —
/// deliberately sparse and slow so the field reads as "alive" rather than
/// busy.
class _FloatingParticles {
  const _FloatingParticles._();

  static const _seeds = [
    Offset(0.20, 0.90),
    Offset(0.78, 0.78),
    Offset(0.55, 0.94),
    Offset(0.92, 0.36),
    Offset(0.08, 0.46),
    Offset(0.40, 0.06),
  ];

  static void paint(Canvas canvas, Size size, double t) {
    for (var i = 0; i < _seeds.length; i++) {
      final seed = _seeds[i];
      final phase = (t + i / _seeds.length) % 1.0;
      final dy = -phase * size.height * 0.22;
      final dx = math.sin((phase * 2 * math.pi) + i) * 8;
      final opacity = (math.sin(phase * math.pi)).clamp(0.0, 1.0);
      final center = Offset(
        seed.dx * size.width + dx,
        seed.dy * size.height + dy,
      );
      canvas.drawCircle(
        center,
        1.6,
        Paint()..color = IpsColors.gold.withValues(alpha: 0.35 * opacity),
      );
    }
  }
}
