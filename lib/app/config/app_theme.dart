import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';

mixin AppTheme {
  // Primary brand color used across login page
  static const Color brandBlue = Color.fromARGB(255, 10, 48, 85);
  static final Color textColorPrimary = _shadeBrandBlue(0.08);
  static final Color textColorSecondary = _tintBrandBlue(0.22);
  static final Color textColorMuted = _tintBrandBlue(0.35);

  static Color _tintBrandBlue(double amount) {
    return Color.alphaBlend(Colors.white.withValues(alpha: amount), brandBlue);
  }

  static Color _shadeBrandBlue(double amount) {
    return Color.alphaBlend(Colors.black.withValues(alpha: amount), brandBlue);
  }

  static const TextStyle errorMessage = TextStyle(color: Colors.red);
  static const TextStyle errorMessageEmphasis = TextStyle(
    color: Colors.red,
    fontWeight: FontWeight.w600,
  );

  // Text styles
  static final TextStyle brandNameLarge = GoogleFonts.poppins(
    fontSize: 25,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  ).copyWith(height: 0.9);

  static final TextStyle brandNameExtraLarge = GoogleFonts.poppins(
    fontSize: 34,
    fontWeight: FontWeight.w800,
    color: Colors.white,
  ).copyWith(height: 0.9);

  static final TextStyle brandNameSmall = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  ).copyWith(height: 0.9);

  static final TextStyle cardHeading = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: textColorPrimary,
  );
  static final TextStyle cardSubHeading = GoogleFonts.poppins(
    fontSize: 19,
    fontWeight: FontWeight.w600,
    color: textColorSecondary,
  );

  static final TextStyle orangeBarText = GoogleFonts.poppins(
    fontSize: 20,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle orangeBarTextNormal = GoogleFonts.poppins(
    fontSize: 20,
    color: Colors.white,
  );

  static final TextStyle listTileTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textColorPrimary,
  );

  static TextStyle? bodyMediumMuted(BuildContext context) {
    return Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: textColorSecondary);
  }

  static TextStyle? bodySmallMuted(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall?.copyWith(
      color: textColorMuted,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle? bodySmallLabel(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall?.copyWith(
      color: textColorSecondary,
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle? titleMediumBrand(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: brandBlue,
    );
  }

  static TextStyle? bodyMediumEmphasis(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: textColorPrimary,
    );
  }

  static TextStyle? titleMediumEmphasis(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: textColorPrimary,
    );
  }

  static TextStyle? bodySmallError(BuildContext context) {
    return Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: Colors.redAccent);
  }

  // Input decoration for form fields
  static const InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    labelStyle: TextStyle(
      color: brandBlue,
      fontSize: 20,
      fontWeight: FontWeight.w300,
    ),
    // border: OutlineInputBorder(),
  );

  static InputDecoration underlineDecoration({
    required String label,
    String? errorText,
  }) {
    final Color baseBorder = Colors.grey.shade400;

    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelStyle: TextStyle(
        color: textColorSecondary,
        fontWeight: FontWeight.w600,
      ),
      errorText: errorText,
      contentPadding: const EdgeInsets.only(top: 8, bottom: 12),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: baseBorder, width: 1.2),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: brandBlue, width: 1.5),
      ),
      errorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.4),
      ),
      focusedErrorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.red.shade500, width: 1.5),
      ),
    );
  }

  static InputDecoration outlinedDecoration({
    required String label,
    Widget? suffixIcon,
    Color? labelColor,
    String? errorText,
  }) {
    final Color baseBorder = Colors.grey.shade400;

    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      labelStyle: TextStyle(
        color: labelColor ?? textColorSecondary,
        fontWeight: FontWeight.w500,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      suffixIcon: suffixIcon,
      errorText: errorText,
      errorStyle: TextStyle(color: Colors.red.shade600),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: baseBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: baseBorder, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: brandBlue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.4),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade500, width: 1.5),
      ),
    );
  }

  static InputDecoration filterDecoration() {
    final Color baseBorder = Colors.grey.shade400;

    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: baseBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: baseBorder, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: brandBlue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.4),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade500, width: 1.5),
      ),
    );
  }

  static InputDecoration verificationCodeDigitDecoration() {
    final Color baseBorder = Colors.grey.shade400;

    return InputDecoration(
      counterText: '',
      contentPadding: EdgeInsets.zero,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: baseBorder, width: 1.3),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: brandBlue, width: 1.5),
      ),
    );
  }

  // Card/Container decoration used in forms
  static final BoxDecoration cardDecoration = BoxDecoration(
    // color: Colors.white,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static const BoxDecoration tableCardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(16)),
    boxShadow: [
      BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
    ],
  );

  static const BorderRadius buttonBorderRadius = BorderRadius.all(
    Radius.circular(8),
  );

  static const RoundedRectangleBorder buttonShape = RoundedRectangleBorder(
    borderRadius: buttonBorderRadius,
  );

  static ButtonStyle tableActionButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: brandBlue,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      shape: buttonShape,
    );
  }

  static ButtonStyle dialogOutlinedButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: textColorSecondary,
      side: BorderSide(color: Colors.grey.shade300),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    );
  }

  static ButtonStyle dialogPrimaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: brandBlue,
      foregroundColor: Colors.white,
      disabledBackgroundColor: Colors.grey.shade300,
      disabledForegroundColor: Colors.grey.shade500,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    );
  }

  static ButtonStyle brandTextButtonStyle() {
    return TextButton.styleFrom(
      foregroundColor: brandBlue,
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    );
  }

  static ButtonStyle navTextButtonStyle() {
    return TextButton.styleFrom(
      foregroundColor: AppTheme.brandBlue,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      minimumSize: const Size(0, 0),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  static MarkdownStyleSheet termsMarkdownStyleSheet(TextTheme textTheme) {
    return MarkdownStyleSheet(
      p: textTheme.bodySmall?.copyWith(height: 1.5, color: textColorPrimary),
      h1: textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: textColorPrimary,
      ),
      h2: textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: textColorPrimary,
      ),
      h3: textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: textColorSecondary,
      ),
      listBullet: textTheme.bodySmall?.copyWith(color: textColorPrimary),
    );
  }

  /// Centralized brand styling for date range pickers.
  static ThemeData dateRangePickerTheme(ThemeData baseTheme) {
    return baseTheme.copyWith(
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: brandBlue,
        onPrimary: Colors.white,
        surfaceTint: brandBlue,
      ),
      datePickerTheme: baseTheme.datePickerTheme.copyWith(
        headerBackgroundColor: brandBlue,
        headerForegroundColor: Colors.white,
        rangePickerHeaderBackgroundColor: brandBlue,
        rangePickerHeaderForegroundColor: Colors.white,
        rangeSelectionBackgroundColor: brandBlue.withValues(alpha: 0.18),
        rangeSelectionOverlayColor: WidgetStatePropertyAll<Color?>(
          brandBlue.withValues(alpha: 0.22),
        ),
      ),
    );
  }

  // Provide the ThemeData to be consumed by MaterialApp
  static final ThemeData light = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    textTheme: GoogleFonts.poppinsTextTheme(),
    inputDecorationTheme: inputDecorationTheme,
    useMaterial3: true,
  );
}
