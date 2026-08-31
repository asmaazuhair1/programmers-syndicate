import 'package:flutter/material.dart';

import '../app_styles/ips_colors.dart';
import '../app_styles/ips_typography.dart';

/// Primary action button shared by every light, pre-auth screen: a solid
/// gold pill with a loading-spinner state, deliberately not reusing
/// [IpsPrimaryButton] since that widget's default theme is tuned for a
/// different surface. Callers own all logic/callbacks; this is
/// presentation only.
class IpsGoldButton extends StatelessWidget {
  const IpsGoldButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: IpsColors.gold,
          disabledBackgroundColor: IpsColors.gold.withValues(alpha: 0.28),
          foregroundColor: IpsColors.textOnPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    IpsColors.textOnPrimary,
                  ),
                ),
              )
            : Text(
                label,
                style: IpsTypography.labelLarge(
                  color: IpsColors.textOnPrimary,
                ),
              ),
      ),
    );
  }
}
