import 'package:flutter/material.dart';

import '../app_styles/ips_colors.dart';
import '../app_styles/ips_spacing.dart';
import '../app_styles/ips_typography.dart';

/// Empty-content state (e.g. no notifications yet). Distinct from
/// [IpsErrorState] — this is not a failure, just nothing to show.
class IpsEmptyState extends StatelessWidget {
  const IpsEmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(IpsSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: IpsColors.textSecondary),
            const SizedBox(height: IpsSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: IpsTypography.bodyLarge(),
            ),
          ],
        ),
      ),
    );
  }
}
