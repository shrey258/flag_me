import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Provides the retro/classic gold and black theme for the application.
/// This theme emphasizes vintage aesthetics with classic typography,
/// subtle textures, and ornate details centered around a gold and black color scheme.
class RetroTheme {
  // Core Colors
  static const Color goldPrimary = Color(0xFFD4AF37);      // Main gold color
  static const Color goldLight = Color(0xFFE9D58A);        // Lighter gold for hover states
  static const Color goldDark = Color(0xFFAA8C2C);         // Darker gold for pressed states
  static const Color blackPrimary = Color(0xFF121212);     // Deep black for backgrounds
  static const Color blackLight = Color(0xFF1E1E1E);       // Lighter black for cards
  static const Color blackAccent = Color(0xFF2C2C2C);      // Accent black for surfaces
  static const Color creamAccent = Color(0xFFF5ECD7);      // Cream for subtle accents
  static const Color textLight = Color(0xFFE0E0E0);        // Light text
  static const Color textMuted = Color(0xFFAAAAAA);        // Muted text
  static const Color errorColor = Color(0xFFCF6679);       // Error color

  // Gradients
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFD4AF37),
      Color(0xFFBF9B30),
    ],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1E1E1E),
      Color(0xFF121212),
    ],
  );

  // Textures
  static const String subtleTexturePath = 'assets/textures/subtle_texture.png';
  static const String paperTexturePath = 'assets/textures/paper_texture.png';

  // Get the retro theme data
  static ThemeData getTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      // Core colors
      colorScheme: const ColorScheme.dark(
        primary: goldPrimary,
        onPrimary: blackPrimary,
        secondary: goldLight,
        onSecondary: blackPrimary,
        tertiary: creamAccent,
        onTertiary: blackPrimary,
        surface: blackLight,
        onSurface: textLight,
        error: errorColor,
        onError: blackPrimary,
      ),
      // Typography
      textTheme: TextTheme(
        // Headings - Serif fonts for retro feel
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 57,
          fontWeight: FontWeight.bold,
          color: textLight,
          letterSpacing: -0.25,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 45,
          fontWeight: FontWeight.bold,
          color: textLight,
          letterSpacing: 0,
        ),
        displaySmall: GoogleFonts.playfairDisplay(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: textLight,
          letterSpacing: 0,
        ),
        headlineLarge: GoogleFonts.playfairDisplay(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textLight,
          letterSpacing: 0,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: textLight,
          letterSpacing: 0,
        ),
        headlineSmall: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textLight,
          letterSpacing: 0,
        ),
        titleLarge: GoogleFonts.playfairDisplay(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textLight,
          letterSpacing: 0,
        ),
        // Body text - Clean sans-serif for legibility
        bodyLarge: GoogleFonts.lato(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textLight,
          letterSpacing: 0.5,
        ),
        bodyMedium: GoogleFonts.lato(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textLight,
          letterSpacing: 0.25,
        ),
        bodySmall: GoogleFonts.lato(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: textMuted,
          letterSpacing: 0.4,
        ),
        labelLarge: GoogleFonts.lato(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textLight,
          letterSpacing: 0.1,
        ),
      ),
      // Card theme
      cardTheme: CardTheme(
        color: blackLight,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: goldPrimary, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.all(8),
      ),
      // App bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: blackPrimary,
        elevation: 0,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: goldPrimary,
        ),
        iconTheme: const IconThemeData(color: goldPrimary),
      ),
      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: blackPrimary,
        selectedItemColor: goldPrimary,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: blackAccent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: goldPrimary, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: goldPrimary.withOpacity(0.6), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: goldPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCF6679), width: 1),
        ),
        labelStyle: GoogleFonts.lato(color: textMuted),
        hintStyle: GoogleFonts.lato(color: textMuted.withOpacity(0.7)),
      ),
      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: goldPrimary,
          foregroundColor: blackPrimary,
          elevation: 4,
          shadowColor: goldPrimary.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.playfairDisplay(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: goldPrimary,
          side: const BorderSide(color: goldPrimary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.playfairDisplay(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: goldPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.playfairDisplay(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      // Slider theme
      sliderTheme: SliderThemeData(
        activeTrackColor: goldPrimary,
        inactiveTrackColor: goldPrimary.withOpacity(0.3),
        thumbColor: goldPrimary,
        overlayColor: goldPrimary.withOpacity(0.2),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      ),
      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return goldPrimary;
          }
          return null;
        }),
        checkColor: WidgetStateProperty.all(blackPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        side: const BorderSide(color: goldPrimary, width: 1.5),
      ),
      // Radio theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return goldPrimary;
          }
          return goldPrimary.withOpacity(0.6);
        }),
      ),
      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return goldPrimary;
          }
          return textLight;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return goldPrimary.withOpacity(0.5);
          }
          return textMuted.withOpacity(0.5);
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      // Dialog theme
      dialogTheme: DialogTheme(
        backgroundColor: blackLight,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: goldPrimary, width: 1),
        ),
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: goldPrimary,
        ),
        contentTextStyle: GoogleFonts.lato(
          fontSize: 16,
          color: textLight,
        ),
      ),
      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: blackAccent,
        contentTextStyle: GoogleFonts.lato(
          color: textLight,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: goldPrimary, width: 1),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      // Divider theme
      dividerTheme: const DividerThemeData(
        color: goldPrimary,
        thickness: 0.5,
        indent: 16,
        endIndent: 16,
      ),
      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: goldPrimary,
        foregroundColor: blackPrimary,
        elevation: 6,
        highlightElevation: 12,
      ),
      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: goldPrimary,
        linearTrackColor: blackAccent,
        circularTrackColor: blackAccent,
      ),
      // Tab bar theme
      tabBarTheme: TabBarTheme(
        labelColor: goldPrimary,
        unselectedLabelColor: textMuted,
        indicatorColor: goldPrimary,
        labelStyle: GoogleFonts.playfairDisplay(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.playfairDisplay(
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
      ),
      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: blackAccent,
        disabledColor: blackAccent.withOpacity(0.7),
        selectedColor: goldPrimary,
        secondarySelectedColor: goldDark,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: GoogleFonts.lato(
          fontSize: 14,
          color: textLight,
        ),
        secondaryLabelStyle: GoogleFonts.lato(
          fontSize: 14,
          color: blackPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: goldPrimary, width: 1),
        ),
      ),
      // Tooltip theme
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: blackAccent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: goldPrimary, width: 1),
        ),
        textStyle: GoogleFonts.lato(
          fontSize: 12,
          color: textLight,
        ),
      ),
    );
  }
}
