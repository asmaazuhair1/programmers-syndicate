import 'package:flutter/material.dart';

import 'ips_animated_field_shell.dart';
import 'ips_field_label.dart';

/// Standard IPS text field with built-in label/error rendering. Wraps
/// [TextFormField] so every field in the app (phone number, future KYC
/// forms, etc.) shares the same visual and validation-state treatment: a
/// static label above the field (with an optional red required-marker)
/// rather than Material's floating inline label, plus the shared branded
/// focus glow/underline from [IpsAnimatedFieldShell].
class IpsTextField extends StatefulWidget {
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
    this.required = false,
    this.focusNode,
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
  final bool required;

  /// Optional external focus node. When omitted, an internal one is
  /// created/disposed so the field's branded focus animation always works
  /// even for call sites that don't need to observe focus themselves.
  final FocusNode? focusNode;

  @override
  State<IpsTextField> createState() => _IpsTextFieldState();
}

class _IpsTextFieldState extends State<IpsTextField> {
  FocusNode? _internalFocusNode;

  FocusNode get _focusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  @override
  void dispose() {
    _internalFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IpsFieldLabel(label: widget.label, required: widget.required),
        const SizedBox(height: 6),
        IpsAnimatedFieldShell(
          focusNode: _focusNode,
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            keyboardType: widget.keyboardType,
            textDirection: widget.textDirection,
            onChanged: widget.onChanged,
            autofillHints: widget.autofillHints,
            textInputAction: widget.textInputAction,
            decoration: InputDecoration(
              hintText: widget.hintText,
              errorText: widget.errorText,
              prefixIcon: widget.prefix,
            ),
          ),
        ),
      ],
    );
  }
}
