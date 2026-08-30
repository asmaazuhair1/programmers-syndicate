import 'package:flutter/material.dart';

import '../app_styles/ips_colors.dart';

/// Full-content loading state (not a full-screen overlay) used inside
/// screens while data is being fetched.
class IpsLoadingIndicator extends StatelessWidget {
  const IpsLoadingIndicator({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(IpsColors.primary),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
