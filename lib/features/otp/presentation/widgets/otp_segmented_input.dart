import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/app_styles/ips_colors.dart';
import '../../../../core/app_styles/ips_spacing.dart';
import '../../../../core/app_styles/ips_typography.dart';

/// A 6-digit segmented OTP input built from linked single-character fields.
/// Rendered LTR (digit order is always left-to-right) regardless of the
/// surrounding RTL layout, and auto-advances focus as each digit is typed.
class OtpSegmentedInput extends StatefulWidget {
  const OtpSegmentedInput({
    super.key,
    required this.length,
    required this.onChanged,
    required this.onCompleted,
    this.hasError = false,
    this.enabled = true,
  });

  final int length;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onCompleted;
  final bool hasError;
  final bool enabled;

  @override
  State<OtpSegmentedInput> createState() => _OtpSegmentedInputState();
}

class _OtpSegmentedInputState extends State<OtpSegmentedInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _handleChange(int index, String value) {
    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    final code = _controllers.map((c) => c.text).join();
    widget.onChanged(code);
    if (code.length == widget.length) {
      FocusScope.of(context).unfocus();
      widget.onCompleted(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(widget.length, (index) {
          return SizedBox(
            width: 44,
            height: 52,
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              enabled: widget.enabled,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              style: IpsTypography.ltrDigits(fontSize: 20, fontWeight: FontWeight.w700),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(vertical: IpsSpacing.sm),
                filled: true,
                fillColor: IpsColors.surfaceMuted,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: widget.hasError ? IpsColors.error : IpsColors.outline,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: widget.hasError ? IpsColors.error : IpsColors.outline,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: widget.hasError ? IpsColors.error : IpsColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
              onChanged: (value) => _handleChange(index, value),
            ),
          );
        }),
      ),
    );
  }
}
