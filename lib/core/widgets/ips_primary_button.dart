import 'package:flutter/material.dart';

import '../app_styles/ips_colors.dart';

/// Primary call-to-action button. Shows an inline spinner in place of the
/// label while [isLoading] is true, at the same size, so tapping submit
/// never shifts the layout underneath it.
class IpsPrimaryButton extends StatelessWidget {
  const IpsPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final canPress = enabled && !isLoading && onPressed != null;
    return ElevatedButton(
      onPressed: canPress ? onPressed : null,
      child: isLoading
          ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                valueColor: AlwaysStoppedAnimation<Color>(IpsColors.textOnPrimary),
              ),
            )
          : Text(label),
    );
  }
}
