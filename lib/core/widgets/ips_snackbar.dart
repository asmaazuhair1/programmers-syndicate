import 'package:flutter/material.dart';

import '../app_styles/ips_colors.dart';
import '../app_styles/ips_spacing.dart';
import '../app_styles/ips_typography.dart';

/// Centralized snackbar presentation so success/error messaging looks
/// consistent everywhere instead of each screen building its own SnackBar.
///
/// Visually this is a floating, brand-styled toast (rounded card, gold
/// accent rail, circular icon badge with a small scale-in entrance) rather
/// than a default Material bar — error uses the deep-navy surface with a
/// red icon badge, success uses the same navy surface with a gold badge,
/// so both read as the same institutional identity instead of generic
/// red/green alerts.
class IpsSnackbar {
  IpsSnackbar._();

  static void showError(BuildContext context, String message) {
    _show(
      context,
      message,
      badgeColor: IpsColors.error,
      icon: Icons.priority_high_rounded,
    );
  }

  static void showSuccess(BuildContext context, String message) {
    _show(
      context,
      message,
      badgeColor: IpsColors.gold,
      icon: Icons.check_rounded,
    );
  }

  static void _show(
    BuildContext context,
    String message, {
    required Color badgeColor,
    required IconData icon,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.symmetric(
          horizontal: IpsSpacing.lg,
          vertical: IpsSpacing.lg,
        ),
        duration: const Duration(seconds: 4),
        content: _IpsSnackbarContent(
          message: message,
          badgeColor: badgeColor,
          icon: icon,
        ),
      ),
    );
  }
}

/// The toast's visual body: a deep-navy card with a thin gold rail down the
/// leading edge and a circular icon badge that scales/fades in on entry,
/// giving the toast its own small motion moment instead of relying only on
/// the default SnackBar slide-up.
class _IpsSnackbarContent extends StatefulWidget {
  const _IpsSnackbarContent({
    required this.message,
    required this.badgeColor,
    required this.icon,
  });

  final String message;
  final Color badgeColor;
  final IconData icon;

  @override
  State<_IpsSnackbarContent> createState() => _IpsSnackbarContentState();
}

class _IpsSnackbarContentState extends State<_IpsSnackbarContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  )..forward();

  late final Animation<double> _badgeScale = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.15, 1.0, curve: Curves.elasticOut),
  );

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(IpsRadius.card),
        child: Container(
          decoration: const BoxDecoration(color: IpsColors.primary),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 4, color: IpsColors.gold),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: IpsSpacing.md,
                      vertical: IpsSpacing.md,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ScaleTransition(
                          scale: _badgeScale,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.badgeColor,
                            ),
                            child: Icon(
                              widget.icon,
                              size: 17,
                              color: IpsColors.textOnPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: IpsSpacing.md),
                        Expanded(
                          child: Text(
                            widget.message,
                            style: IpsTypography.bodyLarge(
                              color: IpsColors.textOnPrimary,
                            ).copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
