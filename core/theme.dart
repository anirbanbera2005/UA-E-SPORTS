import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class EsportsColors {
  static const electricBlue = Color(0xFF0066FF);
  static const neonPurple = Color(0xFF8B5CF6);
  static const cyan = Color(0xFF00E5FF);
  static const darkGray = Color(0xFF0F1225);
  static const gold = Color(0xFFFFD740);
  static const goldDark = Color(0xFFFF8F00);
  static const live = Color(0xFFFF1744);
  static const success = Color(0xFF00E676);
  static const warning = Color(0xFFFFAB00);
  static const bg1 = Color(0xFF050816);
  static const bg2 = Color(0xFF0A0E21);
  static const bg3 = Color(0xFF0F1433);
  static const card = Color(0xFF111836);
  static const cardHover = Color(0xFF161E45);
  static const border = Color(0xFF1E2654);
  static const borderGlow = Color(0xFF2A3575);
  static const glass = Color(0x1AFFFFFF);
  static const glassStrong = Color(0x33FFFFFF);
  static const glassBorder = Color(0x22FFFFFF);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB0B8D4);
  static const textMuted = Color(0xFF6B7299);
  static const textDim = Color(0xFF3D4470);

  static const primaryGradient = LinearGradient(
    colors: [electricBlue, neonPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const cyanGradient = LinearGradient(
    colors: [cyan, electricBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const goldGradient = LinearGradient(
    colors: [gold, goldDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const meshBg = LinearGradient(
    colors: [bg1, bg2, Color(0xFF0D0F2E), bg2],
    stops: [0, 0.3, 0.7, 1],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class EsportsTheme {
  static ThemeData get dark => ThemeData.dark().copyWith(
    scaffoldBackgroundColor: EsportsColors.bg1,
    colorScheme: const ColorScheme.dark(
      primary: EsportsColors.electricBlue,
      secondary: EsportsColors.cyan,
      surface: EsportsColors.card,
      error: EsportsColors.live,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 1, color: EsportsColors.textPrimary, decoration: TextDecoration.none),
      headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: EsportsColors.textPrimary, decoration: TextDecoration.none),
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: EsportsColors.textPrimary, decoration: TextDecoration.none),
      titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: EsportsColors.textPrimary, decoration: TextDecoration.none),
      titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: EsportsColors.textPrimary, decoration: TextDecoration.none),
      bodyLarge: TextStyle(fontSize: 14, color: EsportsColors.textSecondary, decoration: TextDecoration.none),
      bodyMedium: TextStyle(fontSize: 13, color: EsportsColors.textSecondary, decoration: TextDecoration.none),
      bodySmall: TextStyle(fontSize: 11, color: EsportsColors.textMuted, decoration: TextDecoration.none),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: EsportsColors.textPrimary, decoration: TextDecoration.none),
      labelSmall: TextStyle(fontSize: 10, color: EsportsColors.textMuted, decoration: TextDecoration.none),
    ),
  );
}

BoxDecoration glassDecoration({
  double opacity = 0.08,
  double borderRadius = 16,
  Color? borderColor,
  List<BoxShadow>? shadows,
}) {
  return BoxDecoration(
    color: Colors.white.withOpacity(opacity),
    borderRadius: BorderRadius.circular(borderRadius),
    border: Border.all(color: borderColor ?? EsportsColors.glassBorder),
    boxShadow: shadows,
  );
}

BoxDecoration neonDecoration({
  required Color color,
  double borderRadius = 16,
  double glowIntensity = 0.3,
}) {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(borderRadius),
    border: Border.all(color: color.withOpacity(0.4)),
    boxShadow: [
      BoxShadow(color: color.withOpacity(glowIntensity), blurRadius: 20, spreadRadius: -4),
      BoxShadow(color: color.withOpacity(glowIntensity * 0.5), blurRadius: 40, spreadRadius: -8),
    ],
  );
}