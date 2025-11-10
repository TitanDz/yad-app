import 'package:flutter/material.dart';

class AppTheme {
  // === BRAND COLORS - DESIGN SYSTEM ===
  // Divinity: Primary action color - confident, professional blue
  static const Color divinity = Color(0xFF4D41DE);       // Primary blue
  
  // Celestial: Secondary accent - light, approachable blue
  static const Color celestial = Color(0xFFC9DDFC);     // Light blue accent
  
  // Purity: Light mode primary surface - clean, minimal
  static const Color purity = Color(0xFFFAF8F2);        // Light pearl gray
  
  // Discipline: Dark mode primary surface - sophisticated, professional
  static const Color discipline = Color(0xFF292621);    // Dark charcoal

  // === SEMANTIC COLORS ===
  static const Color primary = divinity;
  static const Color primaryLight = celestial;
  static const Color primaryDark = Color(0xFF3A2FBD);   // Deeper divinity
  
  // Success, warning, error states
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  
  // Accent and secondary colors
  static const Color secondary = Color(0xFF10B981);
  static const Color accentLight = celestial;           // Same as celestial for consistency
  
  // === LIGHT MODE PALETTE ===
  // Surface backgrounds with subtle gradation
  static const Color lightSurface = purity;             // #FAF8F2 - primary background
  static const Color lightSurfaceVariant = Color(0xFFF5F3ED);  // Slightly darker variant
  static const Color lightContainer = Color(0xFFEFEDE7);       // Container background
  static const Color lightContainerHigh = Color(0xFFE8E6E0);   // Elevated container
  
  // Text and semantic light mode colors
  static const Color lightText = Color(0xFF1A1815);     // Almost black for high contrast
  static const Color lightTextSecondary = Color(0xFF6B6560);  // Medium gray
  static const Color lightBorder = Color(0xFFDDDAD3);   // Subtle border
  static const Color lightDivider = Color(0xFFE8E6E0);  // Light divider
  
  // === DARK MODE PALETTE ===
  // Surface backgrounds for dark mode
  static const Color darkSurface = discipline;          // #292621 - primary background
  static const Color darkSurfaceVariant = Color(0xFF3A3530); // Slightly lighter variant
  static const Color darkContainer = Color(0xFF403A35);      // Container background
  static const Color darkContainerHigh = Color(0xFF4A4440);  // Elevated container
  
  // Text and semantic dark mode colors
  static const Color darkText = Color(0xFFFAF8F2);      // Purity for high contrast
  static const Color darkTextSecondary = Color(0xFFC8C3BC); // Light gray
  static const Color darkBorder = Color(0xFF544E47);    // Subtle dark border
  static const Color darkDivider = Color(0xFF3A3530);   // Dark divider
  
  // === LEGACY NEUTRAL PALETTE (for compatibility) ===
  static const Color neutral900 = Color(0xFF1A1815);    // Aligned with discipline
  static const Color neutral800 = Color(0xFF2A2520);
  static const Color neutral700 = Color(0xFF3A3530);
  static const Color neutral600 = Color(0xFF5A5550);
  static const Color neutral500 = Color(0xFF7A7570);
  static const Color neutral400 = Color(0xFF9A9590);
  static const Color neutral300 = Color(0xFFD1D5DB);
  static const Color neutral200 = Color(0xFFE5E7EB);
  static const Color neutral100 = Color(0xFFF3F4F6);
  static const Color neutral50 = purity;

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primary,                              // Divinity blue
        onPrimary: Colors.white,                       // White text on primary
        primaryContainer: primaryLight,                // Celestial light blue
        onPrimaryContainer: primary,                   // Dark blue text on light blue
        secondary: secondary,                          // Green
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFFD1FAE5),        // Very light green
        onSecondaryContainer: secondary,
        error: error,
        onError: Colors.white,
        surface: lightSurface,                         // Purity background
        onSurface: lightText,                          // Dark text
        outline: lightBorder,                          // Border color
        outlineVariant: lightDivider,                  // Divider color
        surfaceContainerHighest: lightContainerHigh,   // Elevated containers
      ),
      scaffoldBackgroundColor: lightSurface,           // Overall background
      appBarTheme: const AppBarTheme(
        backgroundColor: lightSurface,                 // Purity background
        foregroundColor: lightText,                    // Dark text
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      textTheme: _textTheme(lightText),
      inputDecorationTheme: _inputDecorationThemeLightMode(),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,                     // Divinity blue
          foregroundColor: Colors.white,               // White text
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,                           // White cards
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: lightDivider, width: 1),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: lightSurface,
        selectedItemColor: primary,
        unselectedItemColor: lightTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primaryLight,                          // Use Celestial for dark mode
        onPrimary: discipline,                          // Dark text on light blue
        primaryContainer: primaryDark,                  // Darker blue
        onPrimaryContainer: Colors.white,              // White text on dark blue
        secondary: secondary,                          // Green
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFF065F46),        // Deep green
        onSecondaryContainer: Color(0xFFD1FAE5),      // Light green text
        error: error,
        onError: Colors.white,
        surface: darkSurface,                          // Discipline background
        onSurface: darkText,                           // Purity text
        outline: darkBorder,                           // Border color
        outlineVariant: darkDivider,                   // Divider color
        surfaceContainerHighest: darkContainerHigh,    // Elevated containers
      ),
      scaffoldBackgroundColor: darkSurface,            // Overall background
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,                  // Discipline background
        foregroundColor: darkText,                     // Purity text
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      textTheme: _textTheme(darkText),
      inputDecorationTheme: _inputDecorationThemeDarkMode(),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLight,                // Celestial light blue
          foregroundColor: discipline,                  // Dark text
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryLight,
          side: const BorderSide(color: celestial, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: darkContainer,                          // Elevated dark container
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: celestial,                  // Light blue for selection
        unselectedItemColor: darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  static TextTheme _textTheme(Color color) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color,
      ),
      titleSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: color,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: color,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: color,
      ),
    );
  }

  static InputDecorationTheme _inputDecorationThemeLightMode() {
    return InputDecorationTheme(
      filled: true,
      fillColor: lightContainer,                        // Light container background
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lightBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lightDivider),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error, width: 2),
      ),
      hintStyle: TextStyle(color: lightTextSecondary, fontSize: 14),
      labelStyle: TextStyle(color: lightText, fontWeight: FontWeight.w500),
      errorStyle: const TextStyle(color: error, fontSize: 12),
      prefixIconColor: lightTextSecondary,
      suffixIconColor: lightTextSecondary,
    );
  }

  static InputDecorationTheme _inputDecorationThemeDarkMode() {
    return InputDecorationTheme(
      filled: true,
      fillColor: darkContainer,                         // Dark container background
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: celestial, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkDivider),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error, width: 2),
      ),
      hintStyle: TextStyle(color: darkTextSecondary, fontSize: 14),
      labelStyle: TextStyle(color: darkText, fontWeight: FontWeight.w500),
      errorStyle: const TextStyle(color: error, fontSize: 12),
      prefixIconColor: darkTextSecondary,
      suffixIconColor: darkTextSecondary,
    );
  }

}
