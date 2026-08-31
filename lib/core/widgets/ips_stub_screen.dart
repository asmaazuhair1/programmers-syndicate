import 'package:flutter/material.dart';

import '../app_styles/ips_colors.dart';
import '../app_styles/ips_spacing.dart';
import 'ips_app_bar.dart';

/// Placeholder screen for flows scoped to a later sub-project
/// (registration, forgot-password, main shell) so navigation never
/// dead-ends while those features are being built.
class IpsStubScreen extends StatelessWidget {
  const IpsStubScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: IpsAppBar(title: title),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(IpsSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.construction_outlined,
                size: 40,
                color: IpsColors.textSecondary,
              ),
              const SizedBox(height: IpsSpacing.md),
              Text(
                'قيد التطوير',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: IpsSpacing.sm),
              Text(
                'هذه الميزة قيد التطوير حالياً وستكون متاحة قريباً',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
