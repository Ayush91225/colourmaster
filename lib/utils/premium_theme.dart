import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Light palette ─────────────────────────────────────────────────────────────
  static const Color black      = Color(0xFFF5F5F0); // off-white background
  static const Color black1     = Color(0xFFF0F0EB); // slightly deeper bg
  static const Color black2     = Color(0xFFFFFFFF); // card surface (pure white)
  static const Color black3     = Color(0xFFEEEEE8); // subtle card / input bg
  static const Color black4     = Color(0xFFE5E5DF); // icon bg / muted surface
  static const Color black5     = Color(0xFFD8D8D2); // borders / dividers

  // ── Orange accent ─────────────────────────────────────────────────────────────
  static const Color orange      = Color(0xFFFF6B00);
  static const Color orangeLight = Color(0xFFFF8C3A);
  static const Color orangeDark  = Color(0xFFCC5500);

  static const Color gold        = orange;
  static const Color goldLight   = orangeLight;
  static const Color goldDark    = orangeDark;

  // ── Text colours (dark on light bg) ──────────────────────────────────────────
  static const Color white      = Color(0xFF1A1A1A); // primary text
  static const Color white90    = Color(0xFF2A2A2A);
  static const Color white60    = Color(0xFF666666); // secondary text
  static const Color white30    = Color(0xFF999999); // muted text
  static const Color white10    = Color(0xFFCCCCCC);
  static const Color white06    = Color(0xFFE0E0E0);

  // ── Status colours ────────────────────────────────────────────────────────────
  static const Color green      = Color(0xFF16A34A);
  static const Color greenDim   = Color(0xFF15803D);
  static const Color amber      = Color(0xFFD97706);
  static const Color red        = Color(0xFFDC2626);
  static const Color blue       = Color(0xFF2563EB);

  // ── Semantic aliases ──────────────────────────────────────────────────────────
  static const Color bg              = black1;
  static const Color surface         = black2;
  static const Color surfaceElevated = black3;
  static const Color border          = black5;
  static const Color accent          = orange;
  static const Color accentSoft      = Color(0x1AFF6B00);

  static const Color textPrimary     = white;      // dark text
  static const Color textSecondary   = white60;
  static const Color textMuted       = white30;
  static const Color textTertiary    = white30;
  static const Color textOnDark      = Color(0xFFFFFFFF); // text on orange buttons

  // ── Backward compat aliases ───────────────────────────────────────────────────
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
  static const Color textOnPrimary   = Color(0xFFFFFFFF);
  static const Color primary         = black;
  static const Color primaryDark     = black1;
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
    color: Color(0x14000000),
    blurRadius: 12,
    offset: Offset(0, 2),
  );

  static const BoxShadow goldShadow = BoxShadow(
    color: Color(0x40FF6B00),
    blurRadius: 20,
    offset: Offset(0, 6),
  );

  static const BorderRadius cardRadius   = BorderRadius.all(Radius.circular(14));
  static const BorderRadius buttonRadius = BorderRadius.all(Radius.circular(12));
  static const BorderRadius inputRadius  = BorderRadius.all(Radius.circular(12));

  // ── Typography ────────────────────────────────────────────────────────────────
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

  // ── Material theme ────────────────────────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: orange,
          secondary: orange,
          surface: black2,
          error: red,
          onPrimary: Color(0xFFFFFFFF),
          onSecondary: Color(0xFFFFFFFF),
          onSurface: white,
          onError: Color(0xFFFFFFFF),
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
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: orange,
            foregroundColor: const Color(0xFFFFFFFF),
            elevation: 0,
            shape: const RoundedRectangleBorder(borderRadius: buttonRadius),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: black3,
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
          checkColor: WidgetStateProperty.all(const Color(0xFFFFFFFF)),
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
          headerBackgroundColor: orange,
          headerForegroundColor: Color(0xFFFFFFFF),
          dayForegroundColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected) ? const Color(0xFFFFFFFF) : white),
          dayBackgroundColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected) ? orange : Colors.transparent),
          todayForegroundColor: WidgetStateProperty.all(orange),
          todayBorder: const BorderSide(color: orange),
          yearForegroundColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected) ? const Color(0xFFFFFFFF) : white),
          yearBackgroundColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected) ? orange : Colors.transparent),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
}

typedef PremiumTheme = AppTheme;
