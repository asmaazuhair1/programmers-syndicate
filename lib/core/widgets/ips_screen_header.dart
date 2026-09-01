import 'package:flutter/material.dart';

import '../app_styles/ips_colors.dart';
import '../app_styles/ips_spacing.dart';
import '../app_styles/ips_typography.dart';

/// Entrance block shared by every light, pre-auth screen: the shield
/// emblem, title and description, fading + scaling in together on first
/// build. Purely presentational — [title]/[description] come straight from
/// the caller's own copy, unchanged.
class IpsScreenHeader extends StatefulWidget {
  const IpsScreenHeader({
    super.key,
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  State<IpsScreenHeader> createState() => _IpsScreenHeaderState();
}

class _IpsScreenHeaderState extends State<IpsScreenHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _fade = curve;
    _scale = Tween<double>(begin: 0.92, end: 1.0).animate(curve);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fade.value,
          child: Transform.scale(scale: _scale.value, child: child),
        );
      },
      child: Column(
        children: [
          const Center(
            child: Image(
              image: AssetImage('assets/images/logo.webp'),
              width: 92,
              height: 92,
            ),
          ),
          const SizedBox(height: IpsSpacing.xl),
          Text(
            widget.title,
            style: IpsTypography.displaySmall(color: IpsColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: IpsSpacing.sm),
          Text(
            widget.description,
            style: IpsTypography.bodyLarge(color: IpsColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
