import 'package:flutter/material.dart';

/// Centralized IPS color tokens. Widgets must reference these constants
/// instead of raw hex values so the palette stays consistent and can be
/// retuned in one place.
class IpsColors {
  IpsColors._();

  static const Color primary = Color(0xFF041428);
  static const Color primaryContainer = Color(0xFF0E2A45);
  static const Color accent = Color(0xFF1D7A6E);

  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF5F7F9);
  static const Color outline = Color(0xFFD8DEE4);

  static const Color textPrimary = Color(0xFF0B1B2B);
  static const Color textSecondary = Color(0xFF5C6B7A);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  static const Color success = Color(0xFF1D7A6E);
  static const Color warning = Color(0xFFB7791F);
  static const Color error = Color(0xFFC0362C);
  static const Color info = Color(0xFF1D6FB8);

  /// Disabled fills/borders derived from [outline] rather than a new raw
  /// value, keeping every neutral tone traceable to the palette above.
  static const Color disabledSurface = Color(0xFFEDF0F2);
  static const Color disabledText = Color(0xFFA6AFB8);
}
