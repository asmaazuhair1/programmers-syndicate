import 'package:flutter/material.dart';

import '../app_styles/ips_colors.dart';
import 'ips_field_label.dart';

/// Read-only text-field-style trigger that opens [showDatePicker], themed
/// consistently with [IpsTextField] via the shared [InputDecorationTheme]: a
/// static label above the field (with an optional red required-marker)
/// rather than Material's floating inline label.
class IpsDateField extends StatelessWidget {
  const IpsDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.hintText,
    this.errorText,
    this.enabled = true,
    this.firstDate,
    this.lastDate,
    this.required = false,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final String? hintText;
  final String? errorText;
  final bool enabled;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool required;

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? DateTime(now.year - 20, now.month, now.day),
      firstDate: firstDate ?? DateTime(now.year - 100),
      lastDate: lastDate ?? now,
    );
    if (picked != null) {
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IpsFieldLabel(label: label, required: required),
        const SizedBox(height: 6),
        TextFormField(
          readOnly: true,
          enabled: enabled,
          controller: TextEditingController(
            text: value != null ? _formatDate(value!) : '',
          ),
          onTap: enabled ? () => _pickDate(context) : null,
          decoration: InputDecoration(
            hintText: hintText,
            errorText: errorText,
            suffixIcon: const Icon(
              Icons.calendar_today_outlined,
              color: IpsColors.textSecondary,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
