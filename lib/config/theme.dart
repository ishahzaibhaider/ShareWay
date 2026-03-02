import 'package:flutter/material.dart';

class AppTheme {
  // Primary palette — brighter, more vibrant
  static const Color primaryColor = Color(0xFF38D9A9);
  static const Color secondaryColor = Color(0xFF20C997);
  static const Color accentColor = Color(0xFFFF6B6B);

  // Gradient colors — lighter, more colorful (not pitch dark)
  static const Color gradientStart = Color(0xFF1A6B5A);
  static const Color gradientEnd = Color(0xFF232946);

  // Glass colors — more visible glass effect
  static Color glassFill = Colors.white.withOpacity(0.15);
  static Color glassBorder = Colors.white.withOpacity(0.25);

  // Surface
  static const Color surfaceColor = Color(0xFF1D4E4E);

  // Text on dark/glass backgrounds — brighter for readability
  static Color textPrimary = Colors.white.withOpacity(0.95);
  static Color textSecondary = Colors.white.withOpacity(0.65);
  static Color dividerColor = Colors.white.withOpacity(0.15);

  // Background gradient
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [gradientStart, gradientEnd],
  );

  // Glass decoration helper
  static BoxDecoration glassDecoration({
    double borderRadius = 20,
    double opacity = 0.15,
  }) {
    return BoxDecoration(
      color: Colors.white.withOpacity(opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: accentColor,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: gradientEnd,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white.withOpacity(0.95),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white.withOpacity(0.95),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: Colors.white.withOpacity(0.95)),
      ),
      cardTheme: CardTheme(
        color: Colors.white.withOpacity(0.13),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primaryColor),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.45)),
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.65)),
        prefixIconColor: Colors.white.withOpacity(0.55),
        suffixIconColor: Colors.white.withOpacity(0.55),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.25)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: accentColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.white.withOpacity(0.45),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      tabBarTheme: TabBarTheme(
        labelColor: primaryColor,
        unselectedLabelColor: Colors.white.withOpacity(0.55),
        indicatorColor: primaryColor,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withOpacity(0.12),
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12),
        side: BorderSide(color: Colors.white.withOpacity(0.18)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) return primaryColor;
            return Colors.white.withOpacity(0.1);
          }),
          foregroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) return Colors.white;
            return Colors.white.withOpacity(0.65);
          }),
          side: MaterialStateProperty.all(
            BorderSide(color: Colors.white.withOpacity(0.25)),
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) return primaryColor;
          return Colors.white.withOpacity(0.65);
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor.withOpacity(0.35);
          }
          return Colors.white.withOpacity(0.12);
        }),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: const Color(0xFF1F3D3D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF1F3D3D),
        contentTextStyle: TextStyle(color: Colors.white.withOpacity(0.95)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: DividerThemeData(color: Colors.white.withOpacity(0.15)),
      listTileTheme: ListTileThemeData(
        textColor: Colors.white.withOpacity(0.9),
        iconColor: Colors.white.withOpacity(0.7),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(color: Colors.white.withOpacity(0.95)),
        headlineMedium: TextStyle(color: Colors.white.withOpacity(0.95)),
        headlineSmall: TextStyle(color: Colors.white.withOpacity(0.95)),
        bodyLarge: TextStyle(color: Colors.white.withOpacity(0.9)),
        bodyMedium: TextStyle(color: Colors.white.withOpacity(0.9)),
        bodySmall: TextStyle(color: Colors.white.withOpacity(0.65)),
      ),
    );
  }
}
