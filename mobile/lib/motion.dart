import 'package:flutter/material.dart';

/// SprachApp hareket dili — Animasyon Keşif kuralları.
/// Transform + opacity; süreler mikro 120–220ms · geçiş 260–420ms · kutlama ≤2sn.
class AppMotion {
  AppMotion._();

  static const curve = Cubic(0.2, 0.8, 0.2, 1);
  static const shakeCurve = Cubic(0.36, 0.07, 0.19, 0.97);

  static const Duration micro = Duration(milliseconds: 180);
  static const Duration press = Duration(milliseconds: 220);
  static const Duration transitionOut = Duration(milliseconds: 260);
  static const Duration transitionIn = Duration(milliseconds: 300);
  static const Duration tile = Duration(milliseconds: 420);
  static const Duration shake = Duration(milliseconds: 380);
  static const Duration reveal = Duration(milliseconds: 300);
  static const Duration rise = Duration(milliseconds: 320);
  static const Duration bar = Duration(milliseconds: 500);
  static const Duration streak = Duration(milliseconds: 440);
  static const Duration ring = Duration(milliseconds: 1400);
  static const Duration celebrate = Duration(milliseconds: 1800);

  static bool reduce(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);

  static Duration d(BuildContext context, Duration normal) =>
      reduce(context) ? Duration.zero : normal;
}
