import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Palette ──────────────────────────────────────────────────────────────
  static const Color background    = Color(0xFFFAFAF8);
  static const Color surface       = Color(0xFFFFFFFF);
  static const Color sand          = Color(0xFFF5F0EA);
  static const Color beige         = Color(0xFFEDE8E0);
  static const Color brandGreen    = Color(0xFF1B3022);
  static const Color brandGreenLt  = Color(0xFF2A4A35);
  static const Color brandEspresso = Color(0xFF2C1B18);
  static const Color accent        = Color(0xFFD4A853);
  static const Color textMain      = Color(0xFF1A1A1A);
  static const Color textSub       = Color(0xFF6C757D);
  static const Color border        = Color(0xFFE5DDD4);
  static const Color success       = Color(0xFF27AE60);
  static const Color danger        = Color(0xFFC0392B);

  // kept for backward-compat
  static const Color brandPrimary   = brandGreen;
  static const Color brandSecondary = brandEspresso;

  // ── Text Styles ──────────────────────────────────────────────────────────
  static TextStyle get displayXL => GoogleFonts.outfit(
    fontSize: 36, fontWeight: FontWeight.w900,
    color: textMain, letterSpacing: -1.0, height: 1.1,
  );
  static TextStyle get displayL => GoogleFonts.outfit(
    fontSize: 28, fontWeight: FontWeight.w900,
    color: textMain, letterSpacing: -0.5, height: 1.2,
  );
  static TextStyle get displayM => GoogleFonts.outfit(
    fontSize: 22, fontWeight: FontWeight.w800, color: textMain, height: 1.3,
  );
  static TextStyle get titleL => GoogleFonts.outfit(
    fontSize: 18, fontWeight: FontWeight.w700, color: textMain,
  );
  static TextStyle get titleM => GoogleFonts.outfit(
    fontSize: 16, fontWeight: FontWeight.w700, color: textMain,
  );
  static TextStyle get body => GoogleFonts.outfit(
    fontSize: 14, fontWeight: FontWeight.w400, color: textMain, height: 1.5,
  );
  static TextStyle get caption => GoogleFonts.outfit(
    fontSize: 12, fontWeight: FontWeight.w500, color: textSub,
  );

  // ── Reusable decorations ─────────────────────────────────────────────────
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(22),
    border: Border.all(color: border),
  );

  static BoxDecoration get sandDecoration => BoxDecoration(
    color: sand, borderRadius: BorderRadius.circular(18),
  );

  // ── ThemeData ────────────────────────────────────────────────────────────
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      primaryColor: brandGreen,
      colorScheme: const ColorScheme.light(
        primary: brandGreen,
        secondary: brandEspresso,
        surface: surface,
        onPrimary: Colors.white,
        onSurface: textMain,
        outline: border,
      ),
      textTheme: GoogleFonts.outfitTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20, fontWeight: FontWeight.w900, color: textMain,
        ),
        iconTheme: const IconThemeData(color: textMain),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
          textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: brandGreen, width: 1.5),
        ),
        hintStyle: GoogleFonts.outfit(color: textSub, fontSize: 14),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: brandGreen,
        unselectedItemColor: textSub,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: brandGreen,
        contentTextStyle: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        behavior: SnackBarBehavior.floating,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: ZoomPageTransitionsBuilder(),
        },
      ),
    );
  }

  // ── 3D Visual Effects ──────────────────────────────────────────────────────
  static List<BoxShadow> get shadow3D => [
    BoxShadow(
      color: brandEspresso.withOpacity(0.08),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
    BoxShadow(
      color: Colors.white.withOpacity(0.8),
      blurRadius: 12,
      offset: const Offset(-6, -6),
    ),
  ];

  static BoxDecoration get card3D => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: border.withOpacity(0.5)),
    boxShadow: shadow3D,
  );

  static BoxDecoration gradient3D(List<Color> colors) => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors,
    ),
    borderRadius: BorderRadius.circular(22),
    boxShadow: [
      BoxShadow(
        color: colors.last.withOpacity(0.35),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  );
}
