import 'package:flutter/material.dart';

class AppTheme {
  static const green = Color(0xff16a34a);
  static const emerald = Color(0xff10b981);
  static const teal = Color(0xff0d9488);
  static const ink = Color(0xff0f172a);
  static const muted = Color(0xff64748b);
  static const surface = Color(0xfff8faf8);

  static ThemeData light() => ThemeData(
    useMaterial3: true,
    fontFamily: 'Arial',
    scaffoldBackgroundColor: surface,
    colorScheme: ColorScheme.fromSeed(seedColor: green),
    cardTheme: CardTheme(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 1),
  );
}

class AppFormat {
  static String rupiah(num value) => 'Rp${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(?<=\\d)(?=(\\d{3})+$)'), (_) => '.')}';
}
