import 'package:flutter/material.dart';

import 'ips_field_label.dart';

/// Standard IPS dropdown field (governorate, gender, etc.), styled to match
/// [IpsTextField] via the shared [InputDecorationTheme] so it never needs
/// its own bespoke styling.
class IpsDropdownField<T> extends StatelessWidget {
  const IpsDropdownField({
    super.key,
    required this.label,
    required this.items,
    required this.itemLabel,
    required this.value,
    required this.onChanged,
    this.hintText,
    this.errorText,
    this.enabled = true,
    this.required = false,
  });

  final String label;
  final List<T> items;
  final String Function(T) itemLabel;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String? hintText;
  final String? errorText;
  final bool enabled;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IpsFieldLabel(label: label, required: required),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          initialValue: value,
          isExpanded: true,
          onChanged: enabled ? onChanged : null,
          decoration: InputDecoration(hintText: hintText, errorText: errorText),
          items: [
            for (final item in items)
              DropdownMenuItem<T>(value: item, child: Text(itemLabel(item))),
          ],
        ),
      ],
    );
  }
}
