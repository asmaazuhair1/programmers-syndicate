import 'package:flutter/material.dart';

import '../app_styles/ips_colors.dart';
import '../app_styles/ips_typography.dart';

/// Static label rendered above a field (rather than Material's floating
/// inline label), optionally suffixed with a red required-marker. Shared by
/// every IPS field widget so labels look identical across the app.
class IpsFieldLabel extends StatelessWidget {
  const IpsFieldLabel({super.key, required this.label, this.required = false});

  final String label;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: label,
        style: IpsTypography.labelSmall(color: IpsColors.textPrimary),
        children: required
            ? [
                TextSpan(
                  text: ' *',
                  style: IpsTypography.labelSmall(color: IpsColors.error),
                ),
              ]
            : null,
      ),
    );
  }
}
