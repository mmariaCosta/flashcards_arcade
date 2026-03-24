import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ArcadeColors {
  // Backgrounds
  static const void_ = Color(0xFF000000);
  static const deep = Color(0xFF05050A);
  static const pit = Color(0xFF0A0A12);
  static const surface = Color(0xFF0E0E1C);
  static const panel = Color(0xFF12121E);
  static const card = Color(0xFF16162A);
  static const cardHover = Color(0xFF1C1C30);

  // Neon palette
  static const cyan = Color(0xFF00FFFF);
  static const pink = Color(0xFFFF00AA);
  static const green = Color(0xFF00FF41);
  static const yellow = Color(0xFFFFE600);
  static const orange = Color(0xFFFF6600);
  static const purple = Color(0xFFBF00FF);
  static const red = Color(0xFFFF0044);
  static const blue = Color(0xFF0088FF);

  // Dim versions (for backgrounds)
  static const cyanDim = Color(0x1A00FFFF);
  static const pinkDim = Color(0x1AFF00AA);
  static const greenDim = Color(0x1500FF41);
  static const yellowDim = Color(0x15FFE600);
  static const purpleDim = Color(0x15BF00FF);

  // Text
  static const textBright = Color(0xFFFFFFFF);
  static const textMid = Color(0xFFB0B8CC);
  static const textDim = Color(0xFF505870);
  static const textGhost = Color(0xFF2A2D3E);

  // Border
  static const borderDefault = Color(0xFF1E2030);
  static const borderMid = Color(0xFF2E3050);
}

class ArcadeTheme {
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: ArcadeColors.void_,
    colorScheme: const ColorScheme.dark(
      primary: ArcadeColors.cyan,
      secondary: ArcadeColors.pink,
      surface: ArcadeColors.surface,
      error: ArcadeColors.red,
    ),
    textTheme: GoogleFonts.shareTechMonoTextTheme(
      const TextTheme(
        bodyLarge:   TextStyle(color: ArcadeColors.textBright, fontSize: 16),
        bodyMedium:  TextStyle(color: ArcadeColors.textMid, fontSize: 14),
        bodySmall:   TextStyle(color: ArcadeColors.textDim, fontSize: 12),
        labelSmall:  TextStyle(color: ArcadeColors.textDim, fontSize: 10),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    }),
  );
}

// ─── FONT HELPERS ───
class ArcadeFonts {
  static TextStyle pixel({
    double size = 12,
    Color color = ArcadeColors.textBright,
    FontWeight weight = FontWeight.normal,
    double? height,
    double letterSpacing = 0.05,
  }) => GoogleFonts.pressStart2p(
    fontSize: size,
    color: color,
    fontWeight: weight,
    height: height ?? 1.6,
    letterSpacing: letterSpacing,
  );

  static TextStyle vt323({
    double size = 24,
    Color color = ArcadeColors.textBright,
    double letterSpacing = 0.05,
  }) => GoogleFonts.vt323(
    fontSize: size,
    color: color,
    letterSpacing: letterSpacing,
    height: 1.1,
  );

  static TextStyle mono({
    double size = 14,
    Color color = ArcadeColors.textBright,
    FontWeight weight = FontWeight.normal,
    double letterSpacing = 0.03,
  }) => GoogleFonts.shareTechMono(
    fontSize: size,
    color: color,
    fontWeight: weight,
    letterSpacing: letterSpacing,
  );
}

// ─── GLOW HELPERS ───
class ArcadeGlow {
  static List<Shadow> cyan({double intensity = 1.0}) => [
    Shadow(color: ArcadeColors.cyan.withOpacity(0.9 * intensity), blurRadius: 6),
    Shadow(color: ArcadeColors.cyan.withOpacity(0.5 * intensity), blurRadius: 14),
    Shadow(color: ArcadeColors.cyan.withOpacity(0.2 * intensity), blurRadius: 30),
  ];

  static List<Shadow> pink({double intensity = 1.0}) => [
    Shadow(color: ArcadeColors.pink.withOpacity(0.9 * intensity), blurRadius: 6),
    Shadow(color: ArcadeColors.pink.withOpacity(0.5 * intensity), blurRadius: 14),
    Shadow(color: ArcadeColors.pink.withOpacity(0.2 * intensity), blurRadius: 30),
  ];

  static List<Shadow> green({double intensity = 1.0}) => [
    Shadow(color: ArcadeColors.green.withOpacity(0.9 * intensity), blurRadius: 6),
    Shadow(color: ArcadeColors.green.withOpacity(0.5 * intensity), blurRadius: 14),
    Shadow(color: ArcadeColors.green.withOpacity(0.2 * intensity), blurRadius: 30),
  ];

  static List<Shadow> yellow({double intensity = 1.0}) => [
    Shadow(color: ArcadeColors.yellow.withOpacity(0.9 * intensity), blurRadius: 6),
    Shadow(color: ArcadeColors.yellow.withOpacity(0.5 * intensity), blurRadius: 14),
    Shadow(color: ArcadeColors.yellow.withOpacity(0.2 * intensity), blurRadius: 30),
  ];

  static List<BoxShadow> boxCyan({double intensity = 1.0}) => [
    BoxShadow(color: ArcadeColors.cyan.withOpacity(0.4 * intensity), blurRadius: 10, spreadRadius: 0),
    BoxShadow(color: ArcadeColors.cyan.withOpacity(0.15 * intensity), blurRadius: 25, spreadRadius: 0),
  ];

  static List<BoxShadow> boxPink({double intensity = 1.0}) => [
    BoxShadow(color: ArcadeColors.pink.withOpacity(0.4 * intensity), blurRadius: 10, spreadRadius: 0),
    BoxShadow(color: ArcadeColors.pink.withOpacity(0.15 * intensity), blurRadius: 25, spreadRadius: 0),
  ];

  static List<BoxShadow> boxGreen({double intensity = 1.0}) => [
    BoxShadow(color: ArcadeColors.green.withOpacity(0.4 * intensity), blurRadius: 10, spreadRadius: 0),
    BoxShadow(color: ArcadeColors.green.withOpacity(0.15 * intensity), blurRadius: 25, spreadRadius: 0),
  ];

  static List<Shadow> purple({double intensity = 1.0}) => [
  Shadow(color: ArcadeColors.purple.withOpacity(0.9 * intensity), blurRadius: 6),
  Shadow(color: ArcadeColors.purple.withOpacity(0.5 * intensity), blurRadius: 14),
  Shadow(color: ArcadeColors.purple.withOpacity(0.2 * intensity), blurRadius: 30),
];
}
