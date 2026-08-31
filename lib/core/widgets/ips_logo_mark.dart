import 'package:flutter/material.dart';

import '../app_styles/ips_colors.dart';
import '../app_styles/ips_spacing.dart';
import '../app_styles/ips_typography.dart';

/// Original IPS in-app brand mark: a geometric monogram ("ن.م") in a
/// rounded-square tile, paired with the Arabic name. No external logo
/// asset is required — this is deliberately simple and institutional
/// rather than decorative, matching the "quiet, professional" direction.
class IpsLogoMark extends StatelessWidget {
  const IpsLogoMark({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 40.0 : 56.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: IpsColors.primary,
            borderRadius: BorderRadius.circular(size * 0.28),
          ),
          child: Text(
            'ن.م',
            style: IpsTypography.titleLarge(color: IpsColors.textOnPrimary)
                .copyWith(fontSize: compact ? 16 : 20),
          ),
        ),
        if (!compact) ...[
          const SizedBox(width: IpsSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'نقابة المبرمجين العراقيين',
                style: IpsTypography.titleMedium(),
              ),
              Text(
                'Iraqi Programmers Syndicate',
                style: IpsTypography.labelSmall(),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
