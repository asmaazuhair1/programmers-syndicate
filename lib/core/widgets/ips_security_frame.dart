import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../app_styles/ips_colors.dart';
import '../app_styles/ips_spacing.dart';

/// The central visual anchor shared by every light, pre-auth screen: a
/// frosted-glass "security frame" that headers, fields, and actions all sit
/// inside. Distinct from a plain card via a one-shot completion flash that
/// sweeps the border when [isComplete] flips true, plus a soft layered
/// drop shadow so it visibly lifts off the animated [IpsTechnicalBackdrop]
/// instead of sitting flush with it.
///
/// [child] is built exactly once and never rebuilt by the ambient/entrance
/// animations (kept as an [AnimatedBuilder.child]), so live [TextField]s
/// inside never lose focus or get rebuilt on every animation tick.
class IpsSecurityFrame extends StatefulWidget {
  const IpsSecurityFrame({
    super.key,
    required this.child,
    this.isComplete = false,
  });

  final Widget child;

  /// Set true to trigger the one-shot completion flash (e.g. OTP's 6th
  /// digit landing). Screens with no such event simply never set this.
  final bool isComplete;

  @override
  State<IpsSecurityFrame> createState() => _IpsSecurityFrameState();
}

class _IpsSecurityFrameState extends State<IpsSecurityFrame>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _ambient;
  late final AnimationController _completion;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..forward();
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    _completion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void didUpdateWidget(covariant IpsSecurityFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isComplete && !oldWidget.isComplete) {
      _completion.forward(from: 0);
    } else if (!widget.isComplete && oldWidget.isComplete) {
      _completion.value = 0;
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    _ambient.dispose();
    _completion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entranceCurve = CurvedAnimation(
      parent: _entrance,
      curve: Curves.easeOutCubic,
    );

    return AnimatedBuilder(
      animation: entranceCurve,
      builder: (context, child) {
        return Opacity(
          opacity: entranceCurve.value,
          child: Transform.translate(
            offset: Offset(0, (1 - entranceCurve.value) * 22),
            child: Transform.scale(
              scale: 0.95 + 0.05 * entranceCurve.value,
              child: child,
            ),
          ),
        );
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_ambient, _completion]),
        builder: (context, child) {
          final pulse = 0.5 + 0.5 * math.sin(_ambient.value * 2 * math.pi);
          final completionT = Curves.easeOutCubic.transform(_completion.value);
          return Transform.scale(
            scale: 1 + completionT * (1 - completionT) * 0.06,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(IpsRadius.card),
                boxShadow: [
                  BoxShadow(
                    color: IpsColors.primary.withValues(alpha: 0.14),
                    blurRadius: 44,
                    offset: const Offset(0, 20),
                  ),
                  BoxShadow(
                    color: IpsColors.gold.withValues(
                      alpha: 0.10 + pulse * 0.05,
                    ),
                    blurRadius: 56,
                    spreadRadius: -12,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(IpsRadius.card),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: CustomPaint(
                    foregroundPainter: _FrameBorderPainter(
                      ambientT: _ambient.value,
                      completionT: _completion.value,
                      pulse: pulse,
                    ),
                    child: child,
                  ),
                ),
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: IpsColors.surface.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(IpsRadius.card),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.65),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(26, 38, 26, 30),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Paints on top of the frame's content: a faint full-perimeter hairline,
/// and — only while [completionT] is animating — a full-perimeter gold
/// flash that sweeps in and back out.
class _FrameBorderPainter extends CustomPainter {
  const _FrameBorderPainter({
    required this.ambientT,
    required this.completionT,
    required this.pulse,
  });

  final double ambientT;
  final double completionT;
  final double pulse;

  static const _radius = Radius.circular(IpsRadius.card);

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, _radius);

    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..color = IpsColors.gold.withValues(alpha: 0.22),
    );

    final flash = math.sin(completionT.clamp(0.0, 1.0) * math.pi);
    if (flash > 0.01) {
      canvas.drawRRect(
        rrect.deflate(1.4),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.4
          ..color = IpsColors.gold.withValues(alpha: 0.55 * flash),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FrameBorderPainter oldDelegate) =>
      oldDelegate.ambientT != ambientT ||
      oldDelegate.completionT != completionT ||
      oldDelegate.pulse != pulse;
}
