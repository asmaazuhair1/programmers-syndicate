import 'package:flutter/material.dart';

import 'ips_colors.dart';

/// IPS typography scale, built on IBM Plex Sans Arabic. All text styles are
/// defined here so screens never construct ad-hoc [TextStyle]s.
///
/// Deliberately bundled as local font assets (see pubspec.yaml `fonts:`)
/// rather than fetched at runtime via the `google_fonts` package: fetching
/// over the network on first use meant the very first frame — including the
/// splash screen — couldn't paint until fonts.gstatic.com responded, which
/// left the web preloader in web/index.html stuck forever on any
/// slow/offline/blocked connection. Bundling removes that dependency
/// entirely so cold start is instant and fully offline-safe.
class IpsTypography {
  IpsTypography._();

  static const String _fontFamily = 'IBMPlexSansArabic';

  static TextStyle _base({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle displaySmall({Color color = IpsColors.textPrimary}) =>
      _base(fontSize: 28, fontWeight: FontWeight.w700, color: color, height: 1.3);

  static TextStyle titleLarge({Color color = IpsColors.textPrimary}) =>
      _base(fontSize: 20, fontWeight: FontWeight.w700, color: color, height: 1.3);

  static TextStyle titleMedium({Color color = IpsColors.textPrimary}) =>
      _base(fontSize: 16, fontWeight: FontWeight.w600, color: color, height: 1.35);

  static TextStyle bodyLarge({Color color = IpsColors.textPrimary}) =>
      _base(fontSize: 16, fontWeight: FontWeight.w400, color: color, height: 1.5);

  static TextStyle bodyMedium({Color color = IpsColors.textSecondary}) =>
      _base(fontSize: 14, fontWeight: FontWeight.w400, color: color, height: 1.5);

  static TextStyle labelLarge({Color color = IpsColors.textOnPrimary}) =>
      _base(fontSize: 15, fontWeight: FontWeight.w600, color: color, letterSpacing: 0.1);

  static TextStyle labelSmall({Color color = IpsColors.textSecondary}) =>
      _base(fontSize: 12, fontWeight: FontWeight.w500, color: color);

  /// Numeric content (phone numbers, OTP digits, dates) that must render
  /// LTR and stay visually stable inside an RTL layout, e.g. the +964
  /// prefix or notification timestamps. Reuses the same bundled
  /// [_fontFamily] (IBM Plex Sans Arabic ships full Latin + digit glyphs)
  /// rather than a second Google Fonts family, keeping the whole app on one
  /// locally-bundled font.
  static TextStyle ltrDigits({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w500,
    Color color = IpsColors.textPrimary,
  }) {
    return _base(fontSize: fontSize, fontWeight: fontWeight, color: color);
  }
}
