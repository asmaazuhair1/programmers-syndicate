import 'package:flutter/material.dart';

/// Standard flat app bar used across IPS screens.
class IpsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const IpsAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.elevation,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;

  /// Optional override, left null by default so every existing call site
  /// keeps the theme's default app-bar surface. Used by screens (e.g.
  /// Registration) that render their own decorative background behind a
  /// transparent app bar.
  final Color? backgroundColor;

  /// Optional elevation override, paired with [backgroundColor] for the
  /// same transparent-app-bar-over-custom-background use case.
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: backgroundColor,
      elevation: elevation,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
