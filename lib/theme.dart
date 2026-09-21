import 'package:flutter/material.dart';

/// Brand colours — the same values as app/ui-kit.tsx in the Measurely app, so
/// the site and the admin read as one product.
class Brand {
  Brand._();

  static const indigo = Color(0xFF4F46E5);
  static const violet = Color(0xFF7C3AED);
  static const teal = Color(0xFF0D9488);
  static const deep = Color(0xFF1E1B4B);
  static const deep2 = Color(0xFF3730A3);

  static const ink = Color(0xFF0F172A);
  static const body = Color(0xFF475569);
  static const muted = Color(0xFF64748B);
  static const line = Color(0xFFE2E8F0);
  static const soft = Color(0xFFF8FAFC);
  static const tint = Color(0xFFEEF2FF);
  static const white = Color(0xFFFFFFFF);
  static const success = Color(0xFF15803D);
  static const amber = Color(0xFFB45309);

  /// Feature-tile accents, one hue each.
  static const accents = <Color>[
    Color(0xFF6366F1), // indigo
    Color(0xFF0EA5E9), // sky
    Color(0xFF14B8A6), // teal
    Color(0xFFF59E0B), // amber
    Color(0xFFA855F7), // violet
    Color(0xFFF43F5E), // rose
    Color(0xFF06B6D4), // cyan
    Color(0xFF84CC16), // lime
  ];

  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deep, deep2, indigo, Color(0xFF0F766E)],
    stops: [0, 0.38, 0.64, 1],
  );

  static const markGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [indigo, violet, teal],
    stops: [0, 0.55, 1],
  );
}

/// Corner radii, so every surface rounds the same way.
class Radii {
  Radii._();

  static const control = 12.0;
  static const card = 18.0;
  static const panel = 24.0;
}

/// Elevation, expressed as soft layered shadows rather than Material's hard
/// ones. Tinted with the ink colour so they read as depth, not dirt.
class Shadows {
  Shadows._();

  static const sm = [
    BoxShadow(color: Color(0x0A0F172A), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0D0F172A), blurRadius: 12, offset: Offset(0, 4)),
  ];

  static const md = [
    BoxShadow(color: Color(0x0F0F172A), blurRadius: 4, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x140F172A), blurRadius: 24, offset: Offset(0, 10)),
  ];

  static const lg = [
    BoxShadow(color: Color(0x0F0F172A), blurRadius: 6, offset: Offset(0, 3)),
    BoxShadow(color: Color(0x1F3730A3), blurRadius: 40, offset: Offset(0, 18)),
  ];
}

/// Motion. Short and eased; nothing loops, nothing bounces.
class Motion {
  Motion._();

  static const fast = Duration(milliseconds: 160);
  static const base = Duration(milliseconds: 240);
  static const curve = Curves.easeOutCubic;

  /// Honour the operating system's "reduce motion" setting.
  static Duration of(BuildContext context, Duration d) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : d;
}

/// Layout breakpoints and the content width.
class Layout {
  Layout._();

  static const maxWidth = 1160.0;
  static const mobile = 720.0;
  static const tablet = 1024.0;

  static bool isMobile(BuildContext c) => MediaQuery.sizeOf(c).width < mobile;
  static bool isTablet(BuildContext c) => MediaQuery.sizeOf(c).width < tablet;

  static double gutter(BuildContext c) => isMobile(c) ? 16 : 32;

  /// Vertical rhythm between sections — generous on purpose.
  static double sectionGap(BuildContext c) => isMobile(c) ? 64 : 104;
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    colorScheme: ColorScheme.fromSeed(
      seedColor: Brand.indigo,
      primary: Brand.indigo,
      secondary: Brand.teal,
      surface: Brand.white,
    ),
    scaffoldBackgroundColor: Brand.white,
    visualDensity: VisualDensity.standard,
  );

  const heading = TextStyle(
    color: Brand.ink,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
    height: 1.12,
  );

  return base.copyWith(
    // .apply(fontFamily) at the end: the styles below are written from
    // scratch, and without it they would fall back to the default font.
    textTheme: base.textTheme
        .copyWith(
          displayLarge: heading.copyWith(fontSize: 56, letterSpacing: -1.4),
          displayMedium: heading.copyWith(fontSize: 44, letterSpacing: -1.1),
          displaySmall: heading.copyWith(fontSize: 34, letterSpacing: -0.8),
          headlineMedium: heading.copyWith(fontSize: 28),
          headlineSmall: heading.copyWith(fontSize: 22, letterSpacing: -0.3),
          titleLarge:
              heading.copyWith(fontSize: 18, letterSpacing: -0.2, height: 1.3),
          titleMedium: const TextStyle(
            color: Brand.ink,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
          bodyLarge:
              const TextStyle(color: Brand.body, fontSize: 18, height: 1.6),
          bodyMedium:
              const TextStyle(color: Brand.body, fontSize: 16, height: 1.6),
          bodySmall:
              const TextStyle(color: Brand.muted, fontSize: 14, height: 1.5),
          labelLarge:
              const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        )
        .apply(fontFamily: 'Inter'),
    chipTheme: ChipThemeData(
      backgroundColor: Brand.white,
      selectedColor: Brand.tint,
      side: const BorderSide(color: Brand.line),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      labelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Brand.ink),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      showCheckmark: false,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
          color: Brand.ink, borderRadius: BorderRadius.circular(8)),
      textStyle: const TextStyle(
          fontFamily: 'Inter', color: Brand.white, fontSize: 13),
    ),
    dividerTheme:
        const DividerThemeData(color: Brand.line, thickness: 1, space: 1),
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      filled: true,
      fillColor: Brand.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.control),
        borderSide: const BorderSide(color: Brand.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.control),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.control),
        borderSide: const BorderSide(color: Brand.indigo, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.control),
        borderSide: const BorderSide(color: Color(0xFFDC2626)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.control),
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
      ),
      errorStyle: const TextStyle(
          fontFamily: 'Inter', fontSize: 12.5, color: Color(0xFFDC2626)),
      floatingLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          color: Brand.indigo,
          fontWeight: FontWeight.w600),
      labelStyle: const TextStyle(color: Brand.muted),
    ),
  );
}
