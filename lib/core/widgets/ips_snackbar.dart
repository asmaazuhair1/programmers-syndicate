import 'package:flutter/material.dart';

import '../app_styles/ips_colors.dart';
import '../app_styles/ips_spacing.dart';

/// Centralized snackbar presentation so success/error messaging looks
/// consistent everywhere instead of each screen building its own SnackBar.
class IpsSnackbar {
  IpsSnackbar._();

  static void showError(BuildContext context, String message) {
    _show(context, message, color: IpsColors.error, icon: Icons.error_outline);
  }

  static void showSuccess(BuildContext context, String message) {
    _show(context, message, color: IpsColors.success, icon: Icons.check_circle_outline);
  }

  static void _show(
    BuildContext context,
    String message, {
    required Color color,
    required IconData icon,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Row(
          children: [
            Icon(icon, color: IpsColors.textOnPrimary, size: 20),
            const SizedBox(width: IpsSpacing.sm),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}
