import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:google_fonts/google_fonts.dart';

mixin AppTheme {
  // Brand palette aligned with the admin web app.
  static const Color brandBlue = Color(0xFF0A3055);
  static const Color brandTextPrimary = Color(0xFF092C4E);
  static const Color brandTextSecondary = Color(0xFF405D7B);
  static const Color brandTextMuted = Color(0xFF607891);
  static const Color brandInfoSoft = Color(0xFFEAF4F4);
  static const Color brandAccent = Color(0xFFA1D8E3);
  static const Color success = Color(0xFF54AD57);
  static const Color danger = Color(0xFFC94040);
  static const Color borderSoft = Color(0xFFE0E0E0);
  static const Color backgroundLight = Color(0xFFF6FAFC);

  // Dark mode palette — mirrors the web app's [data-theme='dark'] CSS variables.
  static const Color darkBg = Color(0xFF081622);
  static const Color darkBgSoft = Color(0xFF0D2133);
  static const Color darkPanel = Color(0xFF11273C);
  static const Color darkPanelMuted = Color(0xFF17314A);
  static const Color darkText = Color(0xFFECF3FA);
  static const Color darkTextMuted = Color(0xFF9FB4CA);
  static const Color darkPrimary = Color(0xFF2C6BA4);
  static const Color darkPrimarySoft = Color(0xFF1F4F7C);
  static const Color darkBorder = Color(0xFF23435F);
  static const Color darkDanger = Color(0xFFE8737B);
  static const Color darkInputBg = Color(0xFF0F2438);
  static const Color darkNavHover = Color(0xFF17314A);
  // Sidebar/brand-chrome gradient — mirrors the web's --sidebar-grad-* vars so
  // the brand header reads as dark, restrained chrome (letting the aquamarine
  // logo/wordmark pop) instead of a flat bright-blue flood.
  static const Color darkSidebarGradStart = Color(0xFF0C1D2D);
  static const Color darkSidebarGradEnd = Color(0xFF10263A);

  // Light-mode border tuned to the web's [data-theme='light'] --border so card
  // and panel edges match across both frontends.
  static const Color lightBorder = Color(0xFFD7E1EA);

  static const Color textColorPrimary = brandTextPrimary;
  static const Color textColorSecondary = brandTextSecondary;
  static const Color textColorMuted = brandTextMuted;

  static const TextStyle errorMessage = TextStyle(color: Colors.red);
  static const TextStyle errorMessageEmphasis = TextStyle(
    color: Colors.red,
    fontWeight: FontWeight.w600,
  );

  // Startup failure screen — `StartupFailureApp` renders on a bare MaterialApp
  // (before AppTheme.light/dark is applied), so these are plain const styles.
  static const TextStyle startupFailureTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle startupFailureDetail = TextStyle(
    color: textColorMuted,
  );

  // Text styles
  static final TextStyle brandNameLarge = GoogleFonts.chakraPetch(
    fontSize: 25,
    fontWeight: FontWeight.w700,
    fontStyle: FontStyle.italic,
    color: brandAccent,
  ).copyWith(height: 0.9);

  static final TextStyle brandNameExtraLarge = GoogleFonts.chakraPetch(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    fontStyle: FontStyle.italic,
    color: brandAccent,
  ).copyWith(height: 0.9);

  static final TextStyle brandNameSmall = GoogleFonts.chakraPetch(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    fontStyle: FontStyle.italic,
    color: brandAccent,
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

  /// Theme-aware list-tile title so options stay legible in dark mode
  /// (light navy text is invisible on the dark scaffold background).
  static TextStyle listTileTitleStyle(
    BuildContext context, {
    bool isDestructive = false,
  }) {
    final Color color = isDestructive
        ? (_isDark(context) ? const Color(0xFFE57373) : Colors.red.shade600)
        : primaryTextColor(context);
    return TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: color);
  }

  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color primaryTextColor(BuildContext context) =>
      _isDark(context) ? darkText : textColorPrimary;

  static Color secondaryTextColor(BuildContext context) =>
      _isDark(context) ? darkText.withValues(alpha: 0.85) : textColorSecondary;

  static Color mutedTextColor(BuildContext context) =>
      _isDark(context) ? darkTextMuted : textColorMuted;

  static Color brandAccentColor(BuildContext context) =>
      _isDark(context) ? darkPrimary : brandBlue;

  /// Danger tone for inline error surfaces. The light [danger] red is too dark
  /// to read against the dark panels, so dark mode lifts it the same way the
  /// web admin does.
  static Color dangerColor(BuildContext context) =>
      _isDark(context) ? darkDanger : danger;

  /// `--primary-soft` — the slightly darker edge the web pairs with primary
  /// fills (e.g. `.btn-primary` border) so filled accents read as crisp.
  static Color primarySoftColor(BuildContext context) =>
      _isDark(context) ? darkPrimarySoft : brandTextSecondary;

  /// Background for raised surface cards (filter boxes, panels) so they
  /// follow the theme instead of a hardcoded white that hides light text.
  static Color surfaceCardColor(BuildContext context) =>
      _isDark(context) ? darkPanel : Colors.white;

  static Color surfaceCardBorderColor(BuildContext context) =>
      _isDark(context) ? darkBorder : lightBorder;

  /// Canonical surface border — mirrors the web's single `--border` token so
  /// panels, cards and tiles all share one consistent edge instead of
  /// primary-tinted, per-widget borders.
  static Color borderColor(BuildContext context) =>
      _isDark(context) ? darkBorder : lightBorder;

  /// Brand-header background. In dark mode this returns the web sidebar
  /// gradient (dark, restrained chrome); in light mode there is no gradient and
  /// callers fall back to [brandAccentColor].
  static Gradient? headerGradient(BuildContext context) => _isDark(context)
      ? const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [darkSidebarGradStart, darkSidebarGradEnd],
        )
      : null;

  static TextStyle? bodyMediumMuted(BuildContext context) {
    return Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: secondaryTextColor(context));
  }

  static TextStyle? bodySmallMuted(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall?.copyWith(
      color: mutedTextColor(context),
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle? bodySmallLabel(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall?.copyWith(
      color: secondaryTextColor(context),
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle? titleMediumBrand(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: brandAccentColor(context),
    );
  }

  static TextStyle? bodyMediumEmphasis(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: primaryTextColor(context),
    );
  }

  static TextStyle? titleMediumEmphasis(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: primaryTextColor(context),
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
    colorScheme: ColorScheme.fromSeed(
      seedColor: brandBlue,
      primary: brandBlue,
      secondary: brandTextSecondary,
      surface: Colors.white,
      error: danger,
    ),
    scaffoldBackgroundColor: backgroundLight,
    textTheme: GoogleFonts.chakraPetchTextTheme().apply(
      bodyColor: textColorPrimary,
      displayColor: textColorPrimary,
    ),
    inputDecorationTheme: inputDecorationTheme,
    useMaterial3: true,
  );

  static const InputDecorationTheme darkInputDecorationTheme =
      InputDecorationTheme(
        labelStyle: TextStyle(
          color: darkTextMuted,
          fontSize: 20,
          fontWeight: FontWeight.w300,
        ),
        floatingLabelStyle: TextStyle(
          color: darkText,
          fontSize: 20,
          fontWeight: FontWeight.w400,
        ),
      );

  static final ThemeData dark = ThemeData(
    colorScheme: const ColorScheme.dark(
      primary: darkPrimary,
      onPrimary: darkText,
      secondary: darkPrimarySoft,
      onSecondary: darkText,
      surface: darkPanel,
      onSurface: darkText,
      error: danger,
      onError: darkText,
    ),
    scaffoldBackgroundColor: darkBg,
    cardColor: darkPanel,
    dividerColor: darkBorder,
    textTheme: GoogleFonts.chakraPetchTextTheme(
      ThemeData(brightness: Brightness.dark).textTheme,
    ).apply(bodyColor: darkText, displayColor: darkText),
    inputDecorationTheme: darkInputDecorationTheme,
    useMaterial3: true,
  );
}
