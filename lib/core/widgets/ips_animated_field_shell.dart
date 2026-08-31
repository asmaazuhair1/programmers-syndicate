import 'package:flutter/material.dart';

/// Wraps any IPS form field so its focus state is observable in one place.
///
/// This used to also paint an extra gold glow (`BoxShadow`) and a growing
/// underline bar below the field. That duplicated the gold `focusedBorder`
/// already defined once, centrally, in the app's `InputDecorationTheme`
/// (see `ips_theme.dart`) — so every text/phone field in the app rendered
/// two overlapping gold focus indicators, plus the underline row silently
/// added extra height/margin under every field. The shell now stays a
/// transparent pass-through: the theme's border animation is the single
/// source of focus feedback.
class IpsAnimatedFieldShell extends StatefulWidget {
  const IpsAnimatedFieldShell({
    super.key,
    required this.focusNode,
    required this.child,
  });

  final FocusNode focusNode;
  final Widget child;

  @override
  State<IpsAnimatedFieldShell> createState() => _IpsAnimatedFieldShellState();
}

class _IpsAnimatedFieldShellState extends State<IpsAnimatedFieldShell> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
