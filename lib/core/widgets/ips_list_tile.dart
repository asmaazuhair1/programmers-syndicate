import 'package:flutter/material.dart';

import '../app_styles/ips_colors.dart';
import '../app_styles/ips_spacing.dart';

/// Flat, divider-separated list row — the "not cards" pattern used for
/// notifications and other simple lists. This sub-project only wires the
/// component itself; notification-specific behavior (unread dot, etc.)
/// lands with the Notifications sub-project.
class IpsListTile extends StatelessWidget {
  const IpsListTile({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: IpsSpacing.lg,
          vertical: IpsSpacing.md,
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: IpsSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodyLarge),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: IpsSpacing.sm),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Thin divider matching the flat list-row spec.
class IpsListDivider extends StatelessWidget {
  const IpsListDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: IpsColors.outline);
  }
}
