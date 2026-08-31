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
    _focusNodes = List.generate(
      widget.length,
      (_) => FocusNode()..addListener(() => setState(() {})),
    );
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
    // A full-length value lands here either from a genuine clipboard paste
    // or from the IME reporting the whole composed string; either way,
    // treat it as one pasted code and distribute it across all boxes.
    if (value.length >= widget.length) {
      _distributePaste(value);
      return;
    }

    // Typing a second digit into an already-filled box (without clearing
    // it first) appends rather than replaces; keep only the digit just
    // typed so the box always shows a single character.
    final digit = value.length > 1 ? value.substring(value.length - 1) : value;
    if (digit != value) {
      _controllers[index].text = digit;
      _controllers[index].selection = TextSelection.collapsed(
        offset: digit.length,
      );
    }

    if (digit.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (digit.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    final code = _controllers.map((c) => c.text).join();
    widget.onChanged(code);
    if (code.length == widget.length) {
      FocusScope.of(context).unfocus();
      widget.onCompleted(code);
    }
  }

  void _distributePaste(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    final code = digits.length > widget.length
        ? digits.substring(0, widget.length)
        : digits;
    for (var i = 0; i < widget.length; i++) {
      final char = i < code.length ? code[i] : '';
      _controllers[i].text = char;
      _controllers[i].selection = TextSelection.collapsed(offset: char.length);
    }

    if (code.length >= widget.length) {
      FocusScope.of(context).unfocus();
    } else {
      _focusNodes[code.length].requestFocus();
    }

    widget.onChanged(code);
    if (code.length == widget.length) {
      widget.onCompleted(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      // LayoutBuilder + a clamped box size (instead of a fixed 48px width)
      // so the 6 boxes shrink to fit narrow screens (e.g. 320px) rather
      // than overflowing the row — the security frame's own horizontal
      // padding eats into the space available to this row, so a fixed
      // width that was fine full-bleed can still overflow inside the
      // frame.
      child: LayoutBuilder(
        builder: (context, constraints) {
          final boxSize = (constraints.maxWidth / widget.length - 6).clamp(
            36.0,
            48.0,
          );
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(widget.length, (index) {
              final focused = _focusNodes[index].hasFocus;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                width: boxSize,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: focused && !widget.hasError
                      ? [
                          BoxShadow(
                            color: IpsColors.gold.withValues(alpha: 0.30),
                            blurRadius: 14,
                            spreadRadius: 1,
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: IpsColors.primary.withValues(alpha: 0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  enabled: widget.enabled,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  style: IpsTypography.ltrDigits(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: IpsColors.textPrimary,
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: IpsSpacing.sm,
                    ),
                    filled: true,
                    fillColor: IpsColors.surface.withValues(alpha: 0.9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: widget.hasError
                            ? IpsColors.error
                            : IpsColors.outline,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: widget.hasError
                            ? IpsColors.error
                            : IpsColors.outline,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: widget.hasError
                            ? IpsColors.error
                            : IpsColors.gold,
                        width: 1.8,
                      ),
                    ),
                  ),
                  onChanged: (value) => _handleChange(index, value),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
