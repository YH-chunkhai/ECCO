import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color bgDark = Color(0xFF0B1329);
  static const Color bgDarkSecondary = Color(0xFF111C3A);
  static const Color cardDark = Color(0xD917213C);
  static const Color inputDark = Color(0xD90B1329);
  static const Color borderDark = Color(0x24FFFFFF);

  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color inputLight = Color(0xFFF1F5F9);
  static const Color borderLight = Color(0xCCCBD5E1);

  static const Color primary = Color(0xFF38BDF8);
  static const Color primaryDark = Color(0xFF0284C7);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentEmerald = Color(0xFF10B981);
  static const Color accentPurple = Color(0xFFC084FC);
  static const Color accentRed = Color(0xFFF43F5E);

  static const Color textDarkMain = Color(0xFFF8FAFC);
  static const Color textDarkMuted = Color(0xFF94A3B8);
  static const Color textLightMain = Color(0xFF0F172A);
  static const Color textLightMuted = Color(0xFF475569);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient amberGradient = LinearGradient(
    colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF34D399), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFFC084FC), Color(0xFF9333EA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      primaryColor: primary,
      cardColor: cardDark,
      dividerColor: borderDark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accentAmber,
        surface: cardDark,
        error: accentRed,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        ThemeData.dark().textTheme,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: bgLight,
      primaryColor: primaryDark,
      cardColor: cardLight,
      dividerColor: borderLight,
      colorScheme: const ColorScheme.light(
        primary: primaryDark,
        secondary: accentAmber,
        surface: cardLight,
        error: accentRed,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        ThemeData.light().textTheme,
      ),
    );
  }
}
