import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/app_styles/ips_colors.dart';
import '../../../../core/app_styles/ips_spacing.dart';
import '../../../../core/app_styles/ips_typography.dart';

/// Phone number field with a fixed, non-editable "+964" chip. The chip and
/// the digits the user types are always rendered LTR even though the field
/// sits inside an RTL layout, matching the phone-number formatting
/// requirement.
class PhoneInputField extends StatelessWidget {
  const PhoneInputField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.errorText,
    this.enabled = true,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      onChanged: onChanged,
      keyboardType: TextInputType.phone,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(11),
      ],
      style: IpsTypography.ltrDigits(),
      decoration: InputDecoration(
        labelText: 'رقم الهاتف',
        hintText: '7XX XXX XXXX',
        errorText: errorText,
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: IpsSpacing.sm),
          child: Align(
            alignment: Alignment.center,
            widthFactor: 1,
            child: Text(
              '+964',
              style: IpsTypography.ltrDigits(
                fontWeight: FontWeight.w600,
                color: IpsColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
