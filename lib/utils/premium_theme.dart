import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Pitch black palette ──────────────────────────────────────────────────────
  static const Color black      = Color(0xFF000000);
  static const Color black1     = Color(0xFF0A0A0A);
  static const Color black2     = Color(0xFF111111);
  static const Color black3     = Color(0xFF1A1A1A);
  static const Color black4     = Color(0xFF222222);
  static const Color black5     = Color(0xFF2A2A2A);

  // ── Orange accent (replaces gold) ───────────────────────────────────────────
  static const Color orange      = Color(0xFFFF6B00); // vivid orange
  static const Color orangeLight = Color(0xFFFF8C3A); // lighter orange
  static const Color orangeDark  = Color(0xFFCC5500); // pressed state

  // Keep gold aliases pointing to orange for backward compat
  static const Color gold        = orange;
  static const Color goldLight   = orangeLight;
  static const Color goldDark    = orangeDark;

  static const Color white      = Color(0xFFFFFFFF);
  static const Color white90    = Color(0xE6FFFFFF);
  static const Color white60    = Color(0x99FFFFFF);
  static const Color white30    = Color(0x4DFFFFFF);
  static const Color white10    = Color(0x1AFFFFFF);
  static const Color white06    = Color(0x0FFFFFFF);

  static const Color green      = Color(0xFF22C55E);
  static const Color greenDim   = Color(0xFF16A34A);
  static const Color amber      = Color(0xFFF59E0B);
  static const Color red        = Color(0xFFEF4444);
  static const Color blue       = Color(0xFF3B82F6);

  // ── Semantic aliases ─────────────────────────────────────────────────────────
  static const Color bg              = black1;
  static const Color surface         = black2;
  static const Color surfaceElevated = black3;
  static const Color border          = black5;
  static const Color accent          = orange;
  static const Color accentSoft      = Color(0x1AFF6B00);

  static const Color textPrimary     = white;
  static const Color textSecondary   = white60;
  static const Color textMuted       = white30;
  static const Color textTertiary    = white30;
  static const Color textOnDark      = black;

  // ── Backward compat aliases ──────────────────────────────────────────────────
  static const Color navy            = black;
  static const Color navyLight       = black3;
  static const Color primaryColor    = black;
  static const Color backgroundColor = bg;
  static const Color surfaceColor    = surface;
  static const Color cardColor       = surface;
  static const Color successColor    = green;
  static const Color warningColor    = amber;
  static const Color errorColor      = red;
  static const Color infoColor       = blue;
  static const Color textOnPrimary   = white;
  static const Color primary         = black;
  static const Color primaryDark     = black;
  static const Color primaryLight    = black3;
  static const Color secondaryColor  = orange;
  static const Color secondaryDark   = orangeDark;
  static const Color accentColor     = orange;
  static const Color accentDark      = orangeDark;
  static const Color accentLight     = accentSoft;

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [black, black3],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [orange, orangeLight, orange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x40000000),
    blurRadius: 16,
    offset: Offset(0, 4),
  );

  static const BoxShadow goldShadow = BoxShadow(
    color: Color(0x40FF6B00),
    blurRadius: 20,
    offset: Offset(0, 6),
  );

  static const BorderRadius cardRadius   = BorderRadius.all(Radius.circular(14));
  static const BorderRadius buttonRadius = BorderRadius.all(Radius.circular(12));
  static const BorderRadius inputRadius  = BorderRadius.all(Radius.circular(12));

  // ── Typography ───────────────────────────────────────────────────────────────
  static TextTheme get textTheme => GoogleFonts.interTextTheme().copyWith(
        displayLarge:   _t(32, FontWeight.w700, white,   1.2),
        displayMedium:  _t(28, FontWeight.w700, white,   1.2),
        displaySmall:   _t(24, FontWeight.w600, white,   1.3),
        headlineLarge:  _t(22, FontWeight.w600, white,   1.3),
        headlineMedium: _t(20, FontWeight.w600, white,   1.4),
        headlineSmall:  _t(18, FontWeight.w600, white,   1.4),
        titleLarge:     _t(16, FontWeight.w600, white,   1.5),
        titleMedium:    _t(14, FontWeight.w500, white,   1.5),
        titleSmall:     _t(12, FontWeight.w500, white60, 1.5),
        bodyLarge:      _t(16, FontWeight.w400, white,   1.6),
        bodyMedium:     _t(14, FontWeight.w400, white60, 1.6),
        bodySmall:      _t(12, FontWeight.w400, white30, 1.6),
      );

  static TextStyle _t(double size, FontWeight w, Color c, double h) =>
      GoogleFonts.inter(fontSize: size, fontWeight: w, color: c, height: h);

  // ── Material theme ───────────────────────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: orange,
          secondary: orange,
          surface: black2,
          error: red,
          onPrimary: white,
          onSecondary: white,
          onSurface: white,
          onError: white,
        ),
        scaffoldBackgroundColor: black1,
        cardColor: black2,
        dividerColor: black5,
        textTheme: textTheme,
        appBarTheme: AppBarTheme(
          backgroundColor: black,
          foregroundColor: white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: _t(17, FontWeight.w600, white, 1.4),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: orange,
            foregroundColor: white,
            elevation: 0,
            shape: const RoundedRectangleBorder(borderRadius: buttonRadius),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: black4,
          border: OutlineInputBorder(
              borderRadius: inputRadius,
              borderSide: const BorderSide(color: black5)),
          enabledBorder: OutlineInputBorder(
              borderRadius: inputRadius,
              borderSide: const BorderSide(color: black5)),
          focusedBorder: OutlineInputBorder(
              borderRadius: inputRadius,
              borderSide: const BorderSide(color: orange, width: 1.5)),
          errorBorder: OutlineInputBorder(
              borderRadius: inputRadius,
              borderSide: const BorderSide(color: red)),
          focusedErrorBorder: OutlineInputBorder(
              borderRadius: inputRadius,
              borderSide: const BorderSide(color: red, width: 1.5)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintStyle: GoogleFonts.inter(fontSize: 14, color: white30),
          labelStyle: GoogleFonts.inter(fontSize: 14, color: white60),
          errorStyle: GoogleFonts.inter(fontSize: 12, color: red),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected) ? orange : Colors.transparent),
          checkColor: WidgetStateProperty.all(white),
          side: const BorderSide(color: black5, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: black2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          titleTextStyle: _t(17, FontWeight.w700, white, 1.3),
          contentTextStyle: _t(14, FontWeight.w400, white60, 1.5),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: black2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        ),
        datePickerTheme: DatePickerThemeData(
          backgroundColor: black2,
          headerBackgroundColor: black,
          headerForegroundColor: white,
          dayForegroundColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected) ? black : white),
          dayBackgroundColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected) ? orange : Colors.transparent),
          todayForegroundColor: WidgetStateProperty.all(orange),
          todayBorder: const BorderSide(color: orange),
          yearForegroundColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected) ? white : white),
          yearBackgroundColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected) ? orange : Colors.transparent),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
}

typedef PremiumTheme = AppTheme;
