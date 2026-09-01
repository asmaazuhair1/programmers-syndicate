import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_styles/ips_colors.dart';
import '../app_styles/ips_spacing.dart';
import '../app_styles/ips_typography.dart';
import 'ips_animated_field_shell.dart';
import 'ips_field_label.dart';

/// Phone number field with a fixed, non-editable "+964" chip. The chip and
/// the digits the user types are always rendered LTR even though the field
/// sits inside an RTL layout, matching the phone-number formatting
/// requirement. Shared by Login and Registration so the phone UI is never
/// duplicated. Wrapped in [IpsAnimatedFieldShell] so it gains the same
/// branded gold glow/underline on focus as every other IPS field.
class IpsPhoneField extends StatefulWidget {
  const IpsPhoneField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.errorText,
    this.enabled = true,
    this.focusNode,
    this.suffixIcon,
    this.helperText,
    this.required = false,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final bool enabled;

  /// Optional external focus node so callers can react to focus changes
  /// (e.g. an animated glow around the field) without this widget needing
  /// to know about that behavior itself.
  final FocusNode? focusNode;

  /// Optional trailing decoration (e.g. a small accent phone icon). Left
  /// null by default so existing call sites are unaffected.
  final Widget? suffixIcon;

  /// Optional helper copy shown below the field when there's no error
  /// (e.g. "we'll text a verification code to this number").
  final String? helperText;

  /// Whether to show a red required-marker next to the label.
  final bool required;

  @override
  State<IpsPhoneField> createState() => _IpsPhoneFieldState();
}

class _IpsPhoneFieldState extends State<IpsPhoneField> {
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
        IpsFieldLabel(label: 'رقم الهاتف', required: widget.required),
        const SizedBox(height: 6),
        IpsAnimatedFieldShell(
          focusNode: _focusNode,
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            onChanged: widget.onChanged,
            keyboardType: TextInputType.phone,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.left,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
            style: IpsTypography.ltrDigits(),
            decoration: InputDecoration(
              hintText: '7XXXXXXXXX',
              errorText: widget.errorText,
              helperText: widget.errorText == null ? widget.helperText : null,
              suffixIcon: widget.suffixIcon,
              prefixIcon: Padding(
                // Symmetric so the flag's distance from the field's outer
                // edge matches the divider's distance from the digits on
                // the other side — a one-sided inset made the flag look
                // like it was hugging the border.
                padding: const EdgeInsets.symmetric(horizontal: IpsSpacing.xs),
                child: Align(
                  alignment: Alignment.center,
                  widthFactor: 1,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🇮🇶', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        '+964',
                        style: IpsTypography.ltrDigits(
                          fontWeight: FontWeight.w600,
                          color: IpsColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: IpsSpacing.sm),
                      Container(width: 1, height: 22, color: IpsColors.outline),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
