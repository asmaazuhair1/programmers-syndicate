import 'package:flutter/material.dart';

import 'ips_colors.dart';
import 'ips_spacing.dart';
import 'ips_typography.dart';

/// Builds the single Material [ThemeData] used by the IPS flavors. Keeping
/// this as one function (rather than scattering `Theme.of(context)`
/// overrides through screens) is what lets buttons/fields/app bars pick up
/// consistent styling automatically.
class IpsTheme {
  IpsTheme._();

  static ThemeData get light {
    final colorScheme = const ColorScheme.light(
      primary: IpsColors.primary,
      primaryContainer: IpsColors.primaryContainer,
      secondary: IpsColors.accent,
      surface: IpsColors.surface,
      error: IpsColors.error,
      onPrimary: IpsColors.textOnPrimary,
      onSecondary: IpsColors.textOnPrimary,
      onSurface: IpsColors.textPrimary,
      onError: IpsColors.textOnPrimary,
      outline: IpsColors.outline,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: IpsColors.surface,
      fontFamily: IpsTypography.bodyLarge().fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: IpsColors.surface,
        foregroundColor: IpsColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: IpsTypography.titleLarge(),
        iconTheme: const IconThemeData(color: IpsColors.textPrimary),
      ),
      dividerTheme: const DividerThemeData(
        color: IpsColors.outline,
        thickness: 1,
        space: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: IpsColors.primary,
          foregroundColor: IpsColors.textOnPrimary,
          disabledBackgroundColor: IpsColors.disabledSurface,
          disabledForegroundColor: IpsColors.disabledText,
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          textStyle: IpsTypography.labelLarge(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(IpsRadius.field),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: IpsColors.primary,
          disabledForegroundColor: IpsColors.disabledText,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: IpsColors.primary, width: 1.2),
          textStyle: IpsTypography.labelLarge(color: IpsColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(IpsRadius.field),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: IpsColors.primary,
          textStyle: IpsTypography.bodyMedium(color: IpsColors.primary),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: IpsColors.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: IpsSpacing.lg,
          vertical: IpsSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(IpsRadius.field),
          borderSide: const BorderSide(color: IpsColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(IpsRadius.field),
          borderSide: const BorderSide(color: IpsColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(IpsRadius.field),
          borderSide: const BorderSide(color: IpsColors.gold, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(IpsRadius.field),
          borderSide: const BorderSide(color: IpsColors.error, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(IpsRadius.field),
          borderSide: const BorderSide(color: IpsColors.error, width: 1.5),
        ),
        labelStyle: IpsTypography.bodyMedium(),
        hintStyle: IpsTypography.bodyMedium(color: IpsColors.disabledText),
        errorStyle: IpsTypography.labelSmall(color: IpsColors.error),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: IpsColors.textPrimary,
        contentTextStyle: IpsTypography.bodyLarge(color: IpsColors.textOnPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(IpsRadius.field),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: IpsColors.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(IpsRadius.dialog),
        ),
        titleTextStyle: IpsTypography.titleLarge(),
        contentTextStyle: IpsTypography.bodyLarge(),
      ),
      textTheme: TextTheme(
        displaySmall: IpsTypography.displaySmall(),
        titleLarge: IpsTypography.titleLarge(),
        titleMedium: IpsTypography.titleMedium(),
        bodyLarge: IpsTypography.bodyLarge(),
        bodyMedium: IpsTypography.bodyMedium(),
        labelLarge: IpsTypography.labelLarge(color: IpsColors.textPrimary),
        labelSmall: IpsTypography.labelSmall(),
      ),
    );
  }
}
