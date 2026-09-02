import 'package:flutter/material.dart';

/// Secondary action button in the primary color with an outline, used for
/// e.g. the guest-login entry point inside the login panel.
class IpsOutlinedButton extends StatelessWidget {
  const IpsOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    // Height and radius mirror [IpsGoldButton] so the primary and secondary
    // actions stack as one pair.
    final style = OutlinedButton.styleFrom(
      minimumSize: const Size.fromHeight(54),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
    if (icon == null) {
      return OutlinedButton(
        onPressed: onPressed,
        style: style,
        child: Text(label),
      );
    }
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: style,
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}
