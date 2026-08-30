import 'package:flutter/material.dart';

/// Standard IPS text field with built-in label/error rendering. Wraps
/// [TextFormField] so every field in the app (phone number, future KYC
/// forms, etc.) shares the same visual and validation-state treatment.
class IpsTextField extends StatelessWidget {
  const IpsTextField({
    super.key,
    required this.label,
    this.controller,
    this.hintText,
    this.errorText,
    this.keyboardType,
    this.textDirection,
    this.enabled = true,
    this.prefix,
    this.onChanged,
    this.autofillHints,
    this.textInputAction,
  });

  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextDirection? textDirection;
  final bool enabled;
  final Widget? prefix;
  final ValueChanged<String>? onChanged;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      textDirection: textDirection,
      onChanged: onChanged,
      autofillHints: autofillHints,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        errorText: errorText,
        prefixIcon: prefix,
      ),
    );
  }
}
