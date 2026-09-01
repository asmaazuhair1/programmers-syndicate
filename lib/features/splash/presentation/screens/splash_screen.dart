import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_styles/ips_colors.dart';
import '../../../../core/app_styles/ips_spacing.dart';
import '../../../../core/app_styles/ips_typography.dart';
import '../../../../routes/app_routes.dart';

/// Cold-start screen, redesigned to share OTP's light institutional
/// language instead of the previous dark-navy cinematic one: the same soft
/// white/gray wash, drifting technical grid, architectural corner
/// brackets, rotating gold orbit, floating particles and circuit tracery
/// as the OTP screen's backdrop — reimplemented here as [_SplashBackdrop]
/// (rather than importing OTP's widget directly) so every trace of navy
/// it carries (grid hairlines, corner brackets, radial glow) can be
/// swapped for neutral gray, leaving this screen strictly white/gray/gold
/// with no dark-navy fill or accent anywhere. The shield emblem is
/// presented plainly — fade+scale only, no rotating bezel — matching how
/// OTP's header presents it. Purely presentational — no auth/session
/// check here, that belongs to a future bootstrap step.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  /// How long the splash holds before navigating to Welcome. Extracted as a
  /// constant (rather than inlined in [initState]) so tests can reason
  /// about/await the exact delay.
  static const Duration holdDuration = Duration(milliseconds: 2600);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  /// Single one-shot controller driving the whole entrance sequence: logo
  /// fade/scale, title fade+slide, the center-out divider draw and the
  /// loader fade-in. Everything reads its own [Interval] off this one
  /// controller so the reveal stays a single coordinated moment.
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..forward();

  /// Drives the small rotating arc loader paired with the loading caption.
  late final AnimationController _loader = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  Timer? _navigateTimer;

  @override
  void initState() {
    super.initState();
    _navigateTimer = Timer(SplashScreen.holdDuration, () {
      if (!mounted) return;
      context.go(AppRoutes.welcome);
    });
  }

  @override
  void dispose() {
    _navigateTimer?.cancel();
    _entrance.dispose();
    _loader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emblemOpacity = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );
    final emblemScale = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
      ),
    );
    final titleOpacity = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.3, 0.85, curve: Curves.easeOut),
    );
    final titleSlide =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entrance,
            curve: const Interval(0.3, 0.85, curve: Curves.easeOutCubic),
          ),
        );
    final loaderOpacity = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: IpsColors.surfaceMuted,
        body: Stack(
          children: [
            // Full-bleed light backdrop, outside SafeArea so it reaches the
            // true screen edges.
            const Positioned.fill(child: _SplashBackdrop()),
            // Deliberately NOT wrapped in SafeArea: the status bar (top) and
            // home-indicator (bottom) insets are rarely equal, so centering
            // *inside* SafeArea's reduced height visibly drags the brand
            // block toward the top. Centering against the full Stack/screen
            // height instead gives a true, literal middle; the brand block
            // is comfortably smaller than the screen, so it never actually
            // renders under the notch/home-indicator.
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final logoSize = (constraints.maxWidth * 0.34).clamp(
                    112.0,
                    150.0,
                  );
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: IpsSpacing.xl,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ScaleTransition(
                              scale: emblemScale,
                              child: FadeTransition(
                                opacity: emblemOpacity,
                                child: Image(
                                  image: const AssetImage(
                                    'assets/images/logo.webp',
                                  ),
                                  width: logoSize,
                                  height: logoSize,
                                ),
                              ),
                            ),
                            const SizedBox(height: IpsSpacing.xl),
                            FadeTransition(
                              opacity: titleOpacity,
                              child: SlideTransition(
                                position: titleSlide,
                                child: Column(
                                  children: [
                                    Text(
                                      'نقابة المبرمجين العراقيين',
                                      textAlign: TextAlign.center,
                                      style:
                                          IpsTypography.displaySmall(
                                            color: IpsColors.textPrimary,
                                          ).copyWith(
                                            fontSize: 23,
                                            letterSpacing: -0.2,
                                          ),
                                    ),
                                    const SizedBox(height: IpsSpacing.xs),
                                    Text(
                                      'Iraqi Programmers Syndicate',
                                      textAlign: TextAlign.center,
                                      style: IpsTypography.bodyMedium(
                                        color: IpsColors.gold,
                                      ).copyWith(letterSpacing: 1.4),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: IpsSpacing.huge),
                            FadeTransition(
                              opacity: loaderOpacity,
                              child: Column(
                                children: [
                                  _ArcLoader(animation: _loader),
                                  const SizedBox(height: IpsSpacing.md),
                                  Text(
                                    'جاري التحميل...',
                                    style: IpsTypography.labelSmall(
                                      color: IpsColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single slim gold arc that continuously rotates around its track —
/// replaces a generic spinner or a static dot row with one deliberate,
/// captivating motion paired with the "جاري التحميل..." caption.
class _ArcLoader extends StatelessWidget {
  const _ArcLoader({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return CustomPaint(
          size: const Size(30, 30),
          painter: _ArcLoaderPainter(t: animation.value),
        );
      },
    );
  }
}

class _ArcLoaderPainter extends CustomPainter {
  const _ArcLoaderPainter({required this.t});

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..color = IpsColors.gold.withValues(alpha: 0.16),
    );

    canvas.drawArc(
      rect,
      t * 2 * math.pi,
      math.pi * 0.62,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..color = IpsColors.gold,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcLoaderPainter oldDelegate) =>
      oldDelegate.t != t;
}

/// Full-bleed animated backdrop, built to the same visual language as the
/// OTP screen's — a soft institutional wash, a faint drifting technical
/// grid, a pair of architectural corner frames, a rotating gold "orbit",
/// slow-floating gold particles, and faint circuit tracery — but with
/// every accent that OTP renders in navy repainted in a neutral gray
/// ([IpsColors.textSecondary]) instead, so gold is the only hue besides
/// white/gray anywhere on this screen. One [AnimationController] drives
/// every sub-element so the motion stays cheap and stays in sync.
class _SplashBackdrop extends StatefulWidget {
  const _SplashBackdrop();

  @override
  State<_SplashBackdrop> createState() => _SplashBackdropState();
}

class _SplashBackdropState extends State<_SplashBackdrop>
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
            painter: _SplashBackdropPainter(t: _controller.value),
          );
        },
      ),
    );
  }
}

class _SplashBackdropPainter extends CustomPainter {
  const _SplashBackdropPainter({required this.t});

  /// 0..1, looping.
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    _paintBaseWash(canvas, size);
    _SplashGrid.paint(canvas, size, t);
    _SplashCorners.paint(canvas, size);
    _SplashCircuit.paint(canvas, size);
    _SplashOrbit.paint(canvas, size, t);
    _SplashPulseNode.paint(canvas, size, t);
    _SplashParticles.paint(canvas, size, t);
  }

  /// Base surface: near-white with a faint gold glow (top-right) balanced
  /// by an equally faint neutral-gray glow (bottom-left) — depth without
  /// ever introducing navy into the wash.
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
    final goldGlow = Rect.fromCircle(
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
        ).createShader(goldGlow),
    );
    final grayGlow = Rect.fromCircle(
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
            IpsColors.textSecondary.withValues(alpha: 0.05),
            IpsColors.textSecondary.withValues(alpha: 0.0),
          ],
        ).createShader(grayGlow),
    );
  }

  @override
  bool shouldRepaint(covariant _SplashBackdropPainter oldDelegate) =>
      oldDelegate.t != t;
}

/// Faint drifting blueprint grid — neutral-gray hairlines at very low alpha
/// so it reads as a technical surface rather than decoration, with a hint
/// of gold on every fourth line. Drifts slowly diagonally via [t].
class _SplashGrid {
  const _SplashGrid._();

  static void paint(Canvas canvas, Size size, double t) {
    const spacing = 36.0;
    final drift = t * spacing;

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6
      ..color = IpsColors.textSecondary.withValues(alpha: 0.045);
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

/// Two architectural corner brackets (top-left, bottom-right) — thin
/// neutral-gray L-frames echoing a blueprint/instrument-panel border.
class _SplashCorners {
  const _SplashCorners._();

  static void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = IpsColors.textSecondary.withValues(alpha: 0.16);
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
/// off the top-right corner — a slow, precise "security orbit". The inner
/// counter-rotating arcs are neutral gray rather than navy.
class _SplashOrbit {
  const _SplashOrbit._();

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
      ..color = IpsColors.textSecondary.withValues(alpha: 0.20);
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
/// echoing the gold orbit.
class _SplashPulseNode {
  const _SplashPulseNode._();

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

/// Faint angular circuit tracery with node terminators — neutral-gray
/// lines with gold terminators, reading as blueprint annotation at very
/// low opacity against the light field.
class _SplashCircuit {
  const _SplashCircuit._();

  static void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = IpsColors.textSecondary.withValues(alpha: 0.10);
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
class _SplashParticles {
  const _SplashParticles._();

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
