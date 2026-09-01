import 'package:flutter/material.dart';

import '../app_styles/ips_colors.dart';
import '../app_styles/ips_spacing.dart';
import '../app_styles/ips_typography.dart';

/// Centralized snackbar presentation so success/error messaging looks
/// consistent everywhere instead of each screen building its own SnackBar.
///
/// Visually this is a floating, light, professional toast (white card,
/// soft shadow, thin semantic-colored rail, a softly-tinted circular icon
/// badge) rather than a dark, default Material bar — error uses a red
/// rail/badge, success uses a teal rail/badge, so the type of message
/// reads at a glance while staying calm and light instead of a heavy
/// solid-color block.
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
      badgeColor: IpsColors.success,
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

/// The toast's visual body: a white card with a thin semantic-colored rail
/// down the leading edge and a softly-tinted circular icon badge that
/// scales in on entry. Fades in while easing down from a small upward
/// offset, giving the toast its own settle-in motion instead of relying
/// only on the default SnackBar slide-up.
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

  // Small upward-offset settle-in — the card eases down into place instead
  // of just appearing, giving it a touch more polish than a plain fade.
  late final Animation<Offset> _slide =
      Tween<Offset>(begin: const Offset(0, -0.12), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
        ),
      );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: Container(
          decoration: BoxDecoration(
            color: IpsColors.surface,
            borderRadius: BorderRadius.circular(IpsRadius.card),
            border: Border.all(color: IpsColors.outline),
            boxShadow: [
              BoxShadow(
                color: IpsColors.primary.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(IpsRadius.card),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 4, color: widget.badgeColor),
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
                                color: widget.badgeColor.withValues(
                                  alpha: 0.12,
                                ),
                              ),
                              child: Icon(
                                widget.icon,
                                size: 17,
                                color: widget.badgeColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: IpsSpacing.md),
                          Expanded(
                            child: Text(
                              widget.message,
                              style: IpsTypography.bodyLarge(
                                color: IpsColors.textPrimary,
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
      ),
    );
  }
}
