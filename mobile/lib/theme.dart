import 'package:flutter/material.dart';

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
  final base = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      primary: AppColors.teal,
      secondary: AppColors.coral,
      surface: Colors.white,
    ),
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.navy,
      displayColor: AppColors.navy,
    ),
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
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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
