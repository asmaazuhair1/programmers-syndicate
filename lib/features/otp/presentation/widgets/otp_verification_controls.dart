import 'package:flutter/material.dart';

import '../../../../core/app_styles/ips_colors.dart';
import '../../../../core/app_styles/ips_typography.dart';

/// Small circular countdown ring around the remaining-seconds number,
/// replacing the old plain text-only countdown. Purely visual — the actual
/// countdown value/logic stays in [OtpCubit]/[OtpState].
class CountdownIndicator extends StatelessWidget {
  const CountdownIndicator({
    super.key,
    required this.secondsRemaining,
    required this.totalSeconds,
  });

  final int secondsRemaining;
  final int totalSeconds;

  @override
  Widget build(BuildContext context) {
    final progress = totalSeconds == 0 ? 0.0 : secondsRemaining / totalSeconds;
    return SizedBox(
      width: 22,
      height: 22,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress.clamp(0, 1),
            strokeWidth: 2,
            backgroundColor: IpsColors.primary.withValues(alpha: 0.10),
            valueColor: const AlwaysStoppedAnimation<Color>(IpsColors.gold),
          ),
        ],
      ),
    );
  }
}

/// Resend row: countdown ring + "خلال Xثانية" while locked, swapping to an
/// interactive gold "إعادة إرسال الرمز" once resend is allowed. All data
/// ([canResend]/[secondsRemaining]/[isResending]) comes straight from
/// [OtpState]; [onResend] calls straight into [OtpCubit.resendCode].
class ResendButton extends StatelessWidget {
  const ResendButton({
    super.key,
    required this.canResend,
    required this.isResending,
    required this.secondsRemaining,
    required this.totalSeconds,
    required this.onResend,
  });

  final bool canResend;
  final bool isResending;
  final int secondsRemaining;
  final int totalSeconds;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    if (canResend) {
      return TextButton(
        onPressed: isResending ? null : onResend,
        style: TextButton.styleFrom(foregroundColor: IpsColors.gold),
        child: Text(
          isResending ? 'جاري إعادة الإرسال...' : 'إعادة إرسال الرمز',
          style: IpsTypography.labelLarge(
            color: isResending
                ? IpsColors.textSecondary.withValues(alpha: 0.6)
                : IpsColors.gold,
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Flexible so the sentence wraps/shrinks instead of overflowing:
        // as a plain Text.rich, Row hands it unbounded main-axis
        // constraints (ignoring the 480px content cap), so at narrower
        // widths it overflowed past the row's right edge.
        Flexible(
          child: Text.rich(
            TextSpan(
              style: IpsTypography.bodyMedium(color: IpsColors.textSecondary),
              children: [
                const TextSpan(text: 'يمكنك إعادة إرسال الرمز خلال '),
                TextSpan(
                  text: '$secondsRemaining',
                  style: IpsTypography.bodyMedium(color: IpsColors.gold)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const TextSpan(text: ' ثانية'),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: 8),
        CountdownIndicator(
          secondsRemaining: secondsRemaining,
          totalSeconds: totalSeconds,
        ),
      ],
    );
  }
}
