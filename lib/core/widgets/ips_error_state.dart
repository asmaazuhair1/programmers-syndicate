import 'package:flutter/material.dart';

import '../app_styles/ips_colors.dart';
import '../app_styles/ips_spacing.dart';
import '../app_styles/ips_typography.dart';

/// Retry-capable error state for network/API failures. Used both as a
/// full-content state and, via [compact], inline within a section.
class IpsErrorState extends StatelessWidget {
  const IpsErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.compact = false,
  });

  final String message;
  final VoidCallback? onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.wifi_off_rounded,
          size: 40,
          color: IpsColors.textSecondary,
        ),
        const SizedBox(height: IpsSpacing.md),
        Text(
          message,
          textAlign: TextAlign.center,
          style: IpsTypography.bodyLarge(),
        ),
        if (onRetry != null) ...[
          const SizedBox(height: IpsSpacing.lg),
          OutlinedButton(
            onPressed: onRetry,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ],
    );

    if (compact) return content;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(IpsSpacing.xxl),
        child: content,
      ),
    );
  }
}
