import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centile palette — Moss & Bone (dark tokens).
class AppColors {
  // Core brand
  static const Color primary = Color(0xFF7FB48A); // moss
  static const Color primaryLight = Color(0xFFA9CDB1);
  static const Color primaryDark = Color(0xFF4E7E5A);

  // Accent (warm bark / amber)
  static const Color accent = Color(0xFFE0A263);
  static const Color onAccent = Color(0xFF1A1108);
  static const Color onPrimary = Color(0xFF0E1311);

  // Backgrounds
  static const Color background = Color(0xFF14181A);
  static const Color surface = Color(0xFF1A1E1F);
  static const Color surfaceLight = Color(0xFF232827); // alias: surfaceVariant
  static const Color surfaceVariant = surfaceLight;

  // Feedback & progress
  static const Color success = Color(0xFF8FCE9B);
  static const Color warning = Color(0xFFD6B466);
  static const Color danger = Color(0xFFE08673);
  static const Color info = Color(0xFF9CBBDA); // calm sky (kept for legacy callers)

  // Text
  static const Color textPrimary = Color(0xFFECE6D8);
  static const Color textSecondary = Color(0xFFABA590);
  static const Color textMuted = Color(0xFF7C7868);

  // Dividers / glass effects
  static const Color divider = Color(0xFF2C3331);
  static const Color glassBorder = Color(0x25FFFFFF);
  static const Color glassBackground = Color(0x12FFFFFF);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [background, Color(0xFF1A1E1F)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFFB6DCAE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Centile palette — Moss & Bone (light tokens).
class LightColors {
  static const Color background = Color(0xFFF5EFE6); // bone cream
  static const Color surface = Color(0xFFFFFBF3);
  static const Color surfaceLight = Color(0xFFECE3D2); // alias: surfaceVariant
  static const Color surfaceVariant = surfaceLight;

  // Brand overrides for light mode
  static const Color primary = Color(0xFF2F5D43); // deep moss
  static const Color primaryLight = Color(0xFF4E7E5A);
  static const Color primaryDark = Color(0xFF1F3F2D);
  static const Color accent = Color(0xFFC77D3E); // bark amber
  static const Color onAccent = Color(0xFF1B1410);
  static const Color onPrimary = Color(0xFFF5EFE6);

  // Feedback
  static const Color success = Color(0xFF4A7C4A);
  static const Color warning = Color(0xFFC99A2E);
  static const Color danger = Color(0xFFA23E2A);
  static const Color info = Color(0xFF6E8AA6);

  // Text
  static const Color textPrimary = Color(0xFF20281F);
  static const Color textSecondary = Color(0xFF4F5849);
  static const Color textMuted = Color(0xFF7A7666);

  // Glass / dividers
  static const Color divider = Color(0xFFD4CBB8);
  static const Color glassBorder = Color(0x20000000);
  static const Color glassBackground = Color(0x08000000);

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [background, Color(0xFFECE3D2)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

/// Curated 7-color category set users pick from when tagging tasks/habits/etc.
/// Stored as enum index 0..6; resolved per brightness.
class CategoryPalette {
  static const List<Color> light = [
    Color(0xFF2F5D43), // moss
    Color(0xFFC77D3E), // amber bark
    Color(0xFF7C6A95), // wisteria
    Color(0xFF6E8AA6), // sky
    Color(0xFF9C2F4C), // wine
    Color(0xFFC99A2E), // gold
    Color(0xFF4A7C4A), // sage
  ];

  static const List<Color> dark = [
    Color(0xFF7FB48A), // moss
    Color(0xFFE0A263), // amber bark
    Color(0xFFB6A4D5), // wisteria
    Color(0xFF9CBBDA), // sky
    Color(0xFFE2738E), // wine
    Color(0xFFD6B466), // gold
    Color(0xFF8FCE9B), // sage
  ];

  /// Return curated list for the active brightness.
  static List<Color> of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }

  /// Snap an arbitrary raw color (legacy `category.colorValue` int) to the
  /// nearest curated swatch for the active brightness.
  static Color snap(BuildContext context, Color raw) {
    final swatches = of(context);
    Color best = swatches.first;
    double bestDist = double.infinity;
    for (final c in swatches) {
      final dr = c.r - raw.r;
      final dg = c.g - raw.g;
      final db = c.b - raw.b;
      final d = dr * dr + dg * dg + db * db;
      if (d < bestDist) {
        bestDist = d;
        best = c;
      }
    }
    return best;
  }
}

/// Two-level elevation scheme.
/// L1 = page surface (no shadow). L2 = raised tile / modal sheet.
/// Legacy "glow" exports retained only for celebration components.
class AppShadows {
  // Subtle ambient for raised tiles (L2)
  static List<BoxShadow> get card => [
    BoxShadow(
      color: Colors.black.withAlpha(15),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  // Slightly stronger ambient for floating overlays (also L2)
  static List<BoxShadow> get elevated => [
    BoxShadow(
      color: Colors.black.withAlpha(30),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // Brand glow — reserved for celebrations / level-up
  static List<BoxShadow> get primaryGlow => [
    BoxShadow(
      color: AppColors.primary.withAlpha(80),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get highPriorityGlow => [
    BoxShadow(
      color: AppColors.danger.withAlpha(60),
      blurRadius: 16,
      spreadRadius: 2,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get mediumPriorityGlow => [
    BoxShadow(
      color: AppColors.warning.withAlpha(50),
      blurRadius: 12,
      spreadRadius: 1,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get lowPriorityGlow => [
    BoxShadow(
      color: AppColors.info.withAlpha(40),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get successGlow => [
    BoxShadow(
      color: AppColors.success.withAlpha(60),
      blurRadius: 16,
      spreadRadius: 2,
      offset: const Offset(0, 2),
    ),
  ];
}

/// 4pt spacing rhythm.
/// Existing symbol names preserved for source-compat. New `xxs` + `hero` added.
class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
  static const double hero = 56;
}

/// Corner radii.
class AppRadius {
  static const double sm = 6; // chip
  static const double md = 10; // card
  static const double lg = 14; // sheet / raised card
  static const double xl = 20; // bottom-sheet top edge
  static const double full = 999;
}

/// Motion tokens — durations + curves.
class AppMotion {
  static const Duration micro = Duration(milliseconds: 120);
  static const Duration standard = Duration(milliseconds: 220);
  static const Duration expressive = Duration(milliseconds: 320);
  static const Duration celebration = Duration(milliseconds: 500);

  static const Curve standardCurve = Curves.easeOutCubic;
  static const Curve expressiveCurve = Curves.easeOutQuint;
  static const Curve microCurve = Curves.easeOut;
}

/// Forest-derived tokens used by tree/forest custom paints.
class ForestTokens {
  static Color canopy(BuildContext context) => context.colors.primary;
  static Color understory(BuildContext context) =>
      Color.lerp(context.colors.primary, context.colors.surface, 0.45)!;
  static Color soil(BuildContext context) =>
      Color.lerp(context.colors.accent, const Color(0xFF3A2A1C), 0.55)!;
  static Color bark(BuildContext context) =>
      Color.lerp(context.colors.accent, const Color(0xFF1B1410), 0.7)!;
}

/// App theme configuration — Moss & Bone, Fraunces + Manrope.
class AppTheme {
  static TextTheme _buildTextTheme(TextTheme base, Color primaryText, Color secondaryText) {
    return GoogleFonts.manropeTextTheme(base).copyWith(
      displayLarge: GoogleFonts.fraunces(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: primaryText,
      ),
      displayMedium: GoogleFonts.fraunces(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: primaryText,
      ),
      displaySmall: GoogleFonts.fraunces(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: primaryText,
      ),
      headlineLarge: GoogleFonts.fraunces(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: primaryText,
      ),
      headlineMedium: GoogleFonts.fraunces(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: primaryText,
      ),
      headlineSmall: GoogleFonts.manrope(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
      titleLarge: GoogleFonts.manrope(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
      titleMedium: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
      titleSmall: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: primaryText,
      ),
      bodyLarge: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: primaryText,
      ),
      bodyMedium: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: secondaryText,
      ),
      bodySmall: GoogleFonts.manrope(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        color: secondaryText,
      ),
      labelLarge: GoogleFonts.manrope(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.6,
        color: primaryText,
      ),
      labelMedium: GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.8,
        color: secondaryText,
      ),
      labelSmall: GoogleFonts.manrope(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.6,
        color: secondaryText,
      ),
    );
  }

  static ThemeData get darkTheme {
    final textTheme = _buildTextTheme(
      ThemeData.dark().textTheme,
      AppColors.textPrimary,
      AppColors.textSecondary,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryDark,
        secondary: AppColors.accent,
        secondaryContainer: AppColors.accent,
        surface: AppColors.surface,
        surfaceContainerHighest: AppColors.surfaceLight,
        error: AppColors.danger,
        onPrimary: AppColors.onPrimary,
        onSecondary: AppColors.onAccent,
        onSurface: AppColors.textPrimary,
        onError: Color(0xFF1A0E0A),
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.fraunces(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withAlpha(60),
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.manrope(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.4,
            color: AppColors.textPrimary,
          ),
        ),
        iconTheme: const WidgetStatePropertyAll(
          IconThemeData(color: AppColors.textSecondary, size: 22),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.glassBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.manrope(color: AppColors.textMuted, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 2,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.success;
          }
          return Colors.transparent;
        }),
        side: const BorderSide(color: AppColors.textMuted, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceLight,
        selectedColor: AppColors.primary,
        labelStyle: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    final textTheme = _buildTextTheme(
      ThemeData.light().textTheme,
      LightColors.textPrimary,
      LightColors.textSecondary,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: LightColors.background,
      colorScheme: const ColorScheme.light(
        primary: LightColors.primary,
        primaryContainer: LightColors.primaryLight,
        secondary: LightColors.accent,
        secondaryContainer: LightColors.accent,
        surface: LightColors.surface,
        surfaceContainerHighest: LightColors.surfaceLight,
        error: LightColors.danger,
        onPrimary: LightColors.onPrimary,
        onSecondary: LightColors.onAccent,
        onSurface: LightColors.textPrimary,
        onError: Color(0xFFF5EFE6),
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.fraunces(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: LightColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: LightColors.textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: LightColors.surface,
        selectedItemColor: LightColors.primary,
        unselectedItemColor: LightColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: LightColors.surface,
        indicatorColor: LightColors.primary.withAlpha(40),
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.manrope(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.4,
            color: LightColors.textPrimary,
          ),
        ),
        iconTheme: const WidgetStatePropertyAll(
          IconThemeData(color: LightColors.textSecondary, size: 22),
        ),
      ),
      cardTheme: CardThemeData(
        color: LightColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: LightColors.primary,
          foregroundColor: LightColors.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: LightColors.primary,
          side: const BorderSide(color: LightColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LightColors.surfaceLight,
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(
            color: LightColors.glassBorder,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: LightColors.primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.manrope(
          color: LightColors.textMuted,
          fontSize: 13,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: LightColors.primary,
        foregroundColor: LightColors.onPrimary,
        elevation: 2,
      ),
      dividerTheme: const DividerThemeData(
        color: LightColors.divider,
        thickness: 1,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return LightColors.success;
          }
          return Colors.transparent;
        }),
        side: const BorderSide(color: LightColors.textMuted, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: LightColors.surfaceLight,
        selectedColor: LightColors.primary,
        labelStyle: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: LightColors.textPrimary,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: LightColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
      ),
    );
  }
}

/// Theme-aware color accessor — `context.colors.<token>`.
class AppColorsTheme {
  final bool isDark;

  const AppColorsTheme({required this.isDark});

  // Core brand (mode-aware)
  Color get primary => isDark ? AppColors.primary : LightColors.primary;
  Color get primaryLight =>
      isDark ? AppColors.primaryLight : LightColors.primaryLight;
  Color get primaryDark =>
      isDark ? AppColors.primaryDark : LightColors.primaryDark;
  Color get onPrimary => isDark ? AppColors.onPrimary : LightColors.onPrimary;

  // Accent
  Color get accent => isDark ? AppColors.accent : LightColors.accent;
  Color get onAccent => isDark ? AppColors.onAccent : LightColors.onAccent;

  // Backgrounds
  Color get background =>
      isDark ? AppColors.background : LightColors.background;
  Color get surface => isDark ? AppColors.surface : LightColors.surface;
  Color get surfaceLight =>
      isDark ? AppColors.surfaceLight : LightColors.surfaceLight;
  Color get surfaceVariant => surfaceLight;

  // Feedback & progress
  Color get success => isDark ? AppColors.success : LightColors.success;
  Color get warning => isDark ? AppColors.warning : LightColors.warning;
  Color get danger => isDark ? AppColors.danger : LightColors.danger;
  Color get error => danger;
  Color get info => isDark ? AppColors.info : LightColors.info;

  // Text
  Color get textPrimary =>
      isDark ? AppColors.textPrimary : LightColors.textPrimary;
  Color get textSecondary =>
      isDark ? AppColors.textSecondary : LightColors.textSecondary;
  Color get textMuted => isDark ? AppColors.textMuted : LightColors.textMuted;

  // Glass / dividers
  Color get glassBorder =>
      isDark ? AppColors.glassBorder : LightColors.glassBorder;
  Color get glassBackground =>
      isDark ? AppColors.glassBackground : LightColors.glassBackground;
  Color get divider => isDark ? AppColors.divider : LightColors.divider;

  // Gradients
  LinearGradient get backgroundGradient =>
      isDark ? AppColors.backgroundGradient : LightColors.backgroundGradient;
  LinearGradient get primaryGradient => LinearGradient(
        colors: [primary, accent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}

/// BuildContext extension for theme-aware color access.
extension AppColorsExtension on BuildContext {
  AppColorsTheme get colors {
    final isDark = Theme.of(this).brightness == Brightness.dark;
    return AppColorsTheme(isDark: isDark);
  }

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
