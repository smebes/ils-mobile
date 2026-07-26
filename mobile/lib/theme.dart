import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// SprachApp tasarım sistemi — gorsel_prompt_yonetimi.md paletiyle hizalı.
class AppColors {
  static const cream = Color(0xFFFAF3E7);
  static const teal = Color(0xFF2A9D8F);
  static const coral = Color(0xFFE76F51);
  static const mustard = Color(0xFFE9C46A);
  static const navy = Color(0xFF264653);
  static const bg = Color(0xFFEEF3F4);

  // Artikel renk kodu (Alman öğreniminin altın kuralı)
  static const der = Color(0xFF2F80ED); // mavi
  static const die = Color(0xFFE0455B); // kırmızı
  static const das = Color(0xFF27AE60); // yeşil

  static Color artikel(String? a) {
    switch (a) {
      case 'der':
        return der;
      case 'die':
        return die;
      case 'das':
        return das;
      default:
        return navy;
    }
  }
}

ThemeData buildTheme() {
  final textTheme = GoogleFonts.nunitoSansTextTheme().apply(
    bodyColor: AppColors.navy,
    displayColor: AppColors.navy,
  );
  final display = GoogleFonts.nunitoTextTheme(textTheme);
  final merged = textTheme.copyWith(
    displayLarge: display.displayLarge?.copyWith(fontWeight: FontWeight.w800),
    displayMedium: display.displayMedium?.copyWith(fontWeight: FontWeight.w800),
    displaySmall: display.displaySmall?.copyWith(fontWeight: FontWeight.w800),
    headlineLarge: display.headlineLarge?.copyWith(fontWeight: FontWeight.w800),
    headlineMedium:
        display.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
    headlineSmall: display.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
    titleLarge: display.titleLarge?.copyWith(fontWeight: FontWeight.w800),
    titleMedium: display.titleMedium?.copyWith(fontWeight: FontWeight.w800),
    titleSmall: display.titleSmall?.copyWith(fontWeight: FontWeight.w700),
  );
  final base = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      primary: AppColors.teal,
      secondary: AppColors.coral,
      surface: Colors.white,
    ),
    textTheme: merged,
  );
  return base.copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: AppColors.navy,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        textStyle: GoogleFonts.nunito(
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}

/// Ortak kart gölge/şekil.
BoxDecoration cardDecoration({Color? color, Color? border}) => BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: border != null ? Border.all(color: border, width: 2.5) : null,
      boxShadow: [
        BoxShadow(
          color: AppColors.navy.withValues(alpha: 0.08),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ],
    );
