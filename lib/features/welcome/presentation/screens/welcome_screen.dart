import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_styles/ips_colors.dart';
import '../../../../core/app_styles/ips_spacing.dart';
import '../../../../core/app_styles/ips_typography.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/widgets/ips_gold_button.dart';
import '../../../../core/widgets/ips_outlined_button.dart';
import '../../../../core/widgets/ips_phone_field.dart';
import '../../../../core/widgets/ips_pressable_scale.dart';
import '../../../../core/widgets/ips_snackbar.dart';
import '../../../../core/widgets/ips_technical_backdrop.dart';
import '../../../../routes/app_routes.dart';
import '../../../login/presentation/cubit/login_cubit.dart';
import '../../../login/presentation/cubit/login_state.dart';
import '../../../otp/domain/otp_context.dart';

/// First and only pre-auth screen, deliberately NOT built as a traditional
/// bordered/rounded card: the shield emblem and brand identity stand alone
/// as an independent lockup directly on [IpsTechnicalBackdrop] (see
/// [_WelcomeIdentityLockup]), and the phone/login interaction sits beneath
/// it as an open "secure access" panel framed only by two thin corner
/// brackets (see [_WelcomeLoginPanel]) rather than an enclosing box — a
/// composition meant to read as a digital-government interface rather than
/// a generic sign-in form. Every element cascades in on one shared
/// [AnimationController] so the reveal stays a single coordinated moment,
/// and the backdrop's own gov-tech node network keeps the whole screen
/// gently alive afterward.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(Injector.instance.authRepository),
      child: const _WelcomeView(),
    );
  }
}

class _WelcomeView extends StatefulWidget {
  const _WelcomeView();

  @override
  State<_WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<_WelcomeView>
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  String? _fieldError;

  /// Single one-shot controller driving the whole entrance cascade: the
  /// logo settles first, then the identity text, then the login panel's
  /// eyebrow/field/actions — each reads its own [Interval] off this one
  /// controller so the whole reveal stays perfectly coordinated.
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..forward();

  @override
  void dispose() {
    _phoneController.dispose();
    _entrance.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    context.read<LoginCubit>().submitPhoneNumber(_phoneController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IpsColors.surfaceMuted,
      // SizedBox.expand forces the Stack to always be exactly screen-sized,
      // matching the OTP screen shell so the backdrop bleeds to the true
      // full screen instead of shrinking to fit scrollable content.
      body: SizedBox.expand(
        child: Stack(
          children: [
            const Positioned.fill(child: IpsTechnicalBackdrop()),
            SafeArea(
              child: BlocConsumer<LoginCubit, LoginState>(
                listener: (context, state) {
                  switch (state) {
                    case LoginOtpRequested(:final localPhoneNumber):
                      setState(() => _fieldError = null);
                      context.push(
                        AppRoutes.otp,
                        extra: OtpRouteArgs(
                          localPhoneNumber: localPhoneNumber,
                          context: OtpContext.login,
                        ),
                      );
                    case LoginFailure(:final message):
                      setState(() => _fieldError = message);
                      IpsSnackbar.showError(context, message);
                    case LoginInitial() || LoginSubmitting():
                      break;
                  }
                },
                builder: (context, state) {
                  final isSubmitting = state is LoginSubmitting;
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: constraints.maxWidth >= 600 ? 24 : 16,
                          vertical: IpsSpacing.xxl,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight:
                                constraints.maxHeight - IpsSpacing.xxl * 2,
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 440),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(height: IpsSpacing.xxl),
                                  _WelcomeIdentityLockup(entrance: _entrance),
                                  const SizedBox(height: IpsSpacing.huge),
                                  _WelcomeLoginPanel(
                                    entrance: _entrance,
                                    phoneController: _phoneController,
                                    isSubmitting: isSubmitting,
                                    fieldError: _fieldError,
                                    onFieldChanged: (_) {
                                      if (_fieldError != null) {
                                        setState(() => _fieldError = null);
                                      }
                                    },
                                    onSubmit: () => _submit(context),
                                    onGuest: isSubmitting
                                        ? null
                                        : () => context.go(AppRoutes.guestHome),
                                  ),
                                  const SizedBox(height: IpsSpacing.xxxl),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
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

/// Independent brand lockup — logo, Arabic identity, English subtitle and a
/// thin gold rule — sitting directly on the animated backdrop with no
/// enclosing card, deliberately separated from the login panel beneath it
/// so the emblem reads as an institutional mark rather than a form header.
/// Reveals via the shared [entrance] controller: the emblem settles first
/// (fade + scale + a slow ambient bob that continues indefinitely), then
/// the Arabic title, then the English subtitle, then the gold rule draws
/// itself in from the center outward.
class _WelcomeIdentityLockup extends StatelessWidget {
  const _WelcomeIdentityLockup({required this.entrance});

  final AnimationController entrance;

  @override
  Widget build(BuildContext context) {
    final logoCurve = CurvedAnimation(
      parent: entrance,
      curve: const Interval(0.0, 0.42, curve: Curves.easeOutCubic),
    );
    final titleCurve = CurvedAnimation(
      parent: entrance,
      curve: const Interval(0.18, 0.55, curve: Curves.easeOutCubic),
    );
    final subtitleCurve = CurvedAnimation(
      parent: entrance,
      curve: const Interval(0.30, 0.65, curve: Curves.easeOutCubic),
    );
    final ruleCurve = CurvedAnimation(
      parent: entrance,
      curve: const Interval(0.38, 0.72, curve: Curves.easeOutCubic),
    );

    return Column(
      children: [
        AnimatedBuilder(
          animation: logoCurve,
          builder: (context, child) =>
              _FloatingLogo(fade: logoCurve.value, child: child!),
          child: const Image(
            image: AssetImage('assets/images/logo.webp'),
            width: 92,
            height: 92,
          ),
        ),
        const SizedBox(height: IpsSpacing.lg),
        AnimatedBuilder(
          animation: titleCurve,
          builder: (context, child) => Opacity(
            opacity: titleCurve.value,
            child: Transform.translate(
              offset: Offset(0, (1 - titleCurve.value) * 14),
              child: child,
            ),
          ),
          child: Text(
            'نقابة المبرمجين العراقيين',
            textAlign: TextAlign.center,
            style: IpsTypography.displaySmall(color: IpsColors.textPrimary)
                .copyWith(fontSize: 25),
          ),
        ),
        const SizedBox(height: IpsSpacing.xs),
        AnimatedBuilder(
          animation: subtitleCurve,
          builder: (context, child) => Opacity(
            opacity: subtitleCurve.value,
            child: Transform.translate(
              offset: Offset(0, (1 - subtitleCurve.value) * 10),
              child: child,
            ),
          ),
          child: Text(
            'Iraqi Programmers Syndicate',
            textAlign: TextAlign.center,
            style: IpsTypography.bodyMedium(color: IpsColors.gold)
                .copyWith(letterSpacing: 2.2, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: IpsSpacing.lg),
        AnimatedBuilder(
          animation: ruleCurve,
          builder: (context, child) => ClipRect(
            child: Align(
              widthFactor: ruleCurve.value.clamp(0.001, 1.0),
              child: child,
            ),
          ),
          child: Container(
            width: 64,
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  IpsColors.gold.withValues(alpha: 0),
                  IpsColors.gold,
                  IpsColors.gold.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The logo settles in via its caller-driven [fade] (opacity + scale) then,
/// once revealed, drifts in a slow, minimal vertical bob on its own
/// perpetual ticker — the "orbital/vertical movement" that keeps the brand
/// mark feeling alive rather than a frozen image, independent of whatever
/// else is happening in the entrance cascade around it.
class _FloatingLogo extends StatefulWidget {
  const _FloatingLogo({required this.fade, required this.child});

  final double fade;
  final Widget child;

  @override
  State<_FloatingLogo> createState() => _FloatingLogoState();
}

class _FloatingLogoState extends State<_FloatingLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bob = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = 0.9 + 0.1 * widget.fade;
    return AnimatedBuilder(
      animation: _bob,
      builder: (context, child) {
        final drift = math.sin(_bob.value * 2 * math.pi) * 4 * widget.fade;
        return Opacity(
          opacity: widget.fade,
          child: Transform.translate(
            offset: Offset(0, drift),
            child: Transform.scale(scale: scale, child: child),
          ),
        );
      },
      child: Container(
        width: 104,
        height: 104,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: IpsColors.gold.withValues(alpha: 0.18),
              blurRadius: 40,
              spreadRadius: -4,
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}

/// The login interaction area, deliberately NOT a bordered/rounded card: a
/// small "secure access" eyebrow label, the phone field, the primary and
/// guest actions, and a pair of thin architectural corner brackets framing
/// the block (echoing the backdrop's own bracket language) instead of an
/// enclosing box. Every child reveals via its own [Interval] on the shared
/// [entrance] controller so the panel cascades in beneath the identity
/// lockup rather than appearing all at once.
class _WelcomeLoginPanel extends StatelessWidget {
  const _WelcomeLoginPanel({
    required this.entrance,
    required this.phoneController,
    required this.isSubmitting,
    required this.fieldError,
    required this.onFieldChanged,
    required this.onSubmit,
    required this.onGuest,
  });

  final AnimationController entrance;
  final TextEditingController phoneController;
  final bool isSubmitting;
  final String? fieldError;
  final ValueChanged<String> onFieldChanged;
  final VoidCallback onSubmit;
  final VoidCallback? onGuest;

  @override
  Widget build(BuildContext context) {
    final bracketCurve = CurvedAnimation(
      parent: entrance,
      curve: const Interval(0.40, 0.80, curve: Curves.easeOutBack),
    );
    final eyebrowCurve = CurvedAnimation(
      parent: entrance,
      curve: const Interval(0.42, 0.72, curve: Curves.easeOutCubic),
    );
    final fieldCurve = CurvedAnimation(
      parent: entrance,
      curve: const Interval(0.50, 0.82, curve: Curves.easeOutCubic),
    );
    final ctaCurve = CurvedAnimation(
      parent: entrance,
      curve: const Interval(0.62, 0.92, curve: Curves.easeOutCubic),
    );
    final guestCurve = CurvedAnimation(
      parent: entrance,
      curve: const Interval(0.72, 1.0, curve: Curves.easeOutCubic),
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: -10,
          right: -10,
          child: AnimatedBuilder(
            animation: bracketCurve,
            builder: (context, _) => _CornerBracket(
              t: bracketCurve.value,
              corner: _BracketCorner.topRight,
            ),
          ),
        ),
        Positioned(
          bottom: -10,
          left: -10,
          child: AnimatedBuilder(
            animation: bracketCurve,
            builder: (context, _) => _CornerBracket(
              t: bracketCurve.value,
              corner: _BracketCorner.bottomLeft,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AnimatedBuilder(
                animation: eyebrowCurve,
                builder: (context, child) => Opacity(
                  opacity: eyebrowCurve.value,
                  child: Transform.translate(
                    offset: Offset(0, (1 - eyebrowCurve.value) * 10),
                    child: child,
                  ),
                ),
                child: const _SecureAccessEyebrow(),
              ),
              const SizedBox(height: IpsSpacing.lg),
              AnimatedBuilder(
                animation: fieldCurve,
                builder: (context, child) => Opacity(
                  opacity: fieldCurve.value,
                  child: Transform.translate(
                    offset: Offset(0, (1 - fieldCurve.value) * 16),
                    child: child,
                  ),
                ),
                child: IpsPhoneField(
                  controller: phoneController,
                  enabled: !isSubmitting,
                  errorText: fieldError,
                  helperText: 'سنرسل رمز تحقق على هذا الرقم',
                  onChanged: onFieldChanged,
                ),
              ),
              const SizedBox(height: IpsSpacing.xxl),
              AnimatedBuilder(
                animation: ctaCurve,
                builder: (context, child) => Opacity(
                  opacity: ctaCurve.value,
                  child: Transform.translate(
                    offset: Offset(0, (1 - ctaCurve.value) * 16),
                    child: child,
                  ),
                ),
                child: IpsPressableScale(
                  child: IpsGoldButton(
                    label: 'تسجيل الدخول',
                    isLoading: isSubmitting,
                    onPressed: onSubmit,
                  ),
                ),
              ),
              const SizedBox(height: IpsSpacing.md),
              AnimatedBuilder(
                animation: guestCurve,
                builder: (context, child) => Opacity(
                  opacity: guestCurve.value,
                  child: Transform.translate(
                    offset: Offset(0, (1 - guestCurve.value) * 12),
                    child: child,
                  ),
                ),
                child: IpsPressableScale(
                  child: IpsOutlinedButton(
                    label: 'الدخول كضيف',
                    onPressed: onGuest,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Small section label — a short bold "تسجيل الدخول" caption with a
/// hairline extending to the trailing edge — replacing a generic section
/// title with something that reads as an institutional/government
/// annotation rather than form UI.
class _SecureAccessEyebrow extends StatelessWidget {
  const _SecureAccessEyebrow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'تسجيل الدخول',
          style: IpsTypography.labelSmall(color: IpsColors.textSecondary)
              .copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.6),
        ),
        const SizedBox(width: IpsSpacing.sm),
        Expanded(child: Container(height: 1, color: IpsColors.outline)),
      ],
    );
  }
}

enum _BracketCorner { topRight, bottomLeft }

/// A tiny architectural corner bracket that snaps into place with an
/// overshoot ease — echoes the backdrop's own corner-frame language,
/// framing the login panel without ever closing it into a full box.
class _CornerBracket extends StatelessWidget {
  const _CornerBracket({required this.t, required this.corner});

  final double t;
  final _BracketCorner corner;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(22, 22),
      painter: _CornerBracketPainter(t: t.clamp(0.0, 1.0), corner: corner),
    );
  }
}

class _CornerBracketPainter extends CustomPainter {
  const _CornerBracketPainter({required this.t, required this.corner});

  final double t;
  final _BracketCorner corner;

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0) return;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..color = IpsColors.gold.withValues(alpha: 0.55 * t);
    final armLength = size.width * t;
    switch (corner) {
      case _BracketCorner.topRight:
        canvas.drawLine(
          Offset(size.width, 0),
          Offset(size.width - armLength, 0),
          paint,
        );
        canvas.drawLine(
          Offset(size.width, 0),
          Offset(size.width, armLength),
          paint,
        );
      case _BracketCorner.bottomLeft:
        canvas.drawLine(
          Offset(0, size.height),
          Offset(armLength, size.height),
          paint,
        );
        canvas.drawLine(
          Offset(0, size.height),
          Offset(0, size.height - armLength),
          paint,
        );
    }
  }

  @override
  bool shouldRepaint(covariant _CornerBracketPainter oldDelegate) =>
      oldDelegate.t != t;
}
