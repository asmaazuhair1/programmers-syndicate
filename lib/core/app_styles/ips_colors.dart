import 'package:flutter/material.dart';

/// Centralized IPS color tokens. Widgets must reference these constants
/// instead of raw hex values so the palette stays consistent and can be
/// retuned in one place.
class IpsColors {
  IpsColors._();

  static const Color primary = Color(0xFF041428);
  static const Color primaryContainer = Color(0xFF0E2A45);
  static const Color accent = Color(0xFF1D7A6E);

  /// Cool, desaturated "brushed steel" ramp used by the Registration
  /// screen's engineered/instrument-panel surfaces — a distinct register
  /// from the navy [primary]/[primaryContainer] pair (which reads more
  /// "institutional letterhead" than "machined hardware"), but close
  /// enough in depth/saturation to sit in the same gradient without
  /// clashing. [graphite] is the base backdrop tone, [graphiteElevated] is
  /// for panel/module frames sitting a step above it, and
  /// [graphiteHighlight] is the lighter edge/hairline tone used for
  /// borders and sheen highlights on those frames.
  static const Color graphite = Color(0xFF161B22);
  static const Color graphiteElevated = Color(0xFF232A33);
  static const Color graphiteHighlight = Color(0xFF3D4753);

  /// Warm orange accent used strictly as a small accent (rules, tiny icons,
  /// decorative lines) on institutional screens (Welcome/Login,
  /// Registration) — never as a fill or a dominant surface color.
  static const Color gold = Color(0xFFF67700);

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
