import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main_navigation_screen.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFFD3DB5);
  static const Color backgroundColor = Color(0xFFFFFFFF); 
  static const Color surfaceColor = Color(0xFFF6F6F6);
  static const Color onPrimaryColor = Color(0xFFFFFFFF);
  static const Color onBackgroundColor = Color(0xFF1A1A1A);
  static const Color onSurfaceColor = Color(0xFF1A1A1A);
  static const Color secondaryColor = Color(0xFF000000);
  static const Color errorColor = Color(0xFFB00020);

  static const Color gradientStart = Color(0x15FD3DB5);
  static const Color gradientEnd = Color(0x05FD3DB5);

  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.light,

      colorScheme: const ColorScheme(
        primary: primaryColor,
        onPrimary: onPrimaryColor,
        secondary: primaryColor,
        onSecondary: onPrimaryColor,
        background: backgroundColor,
        onBackground: onBackgroundColor,
        surface: surfaceColor,
        onSurface: onSurfaceColor,
        error: errorColor,
        onError: onPrimaryColor,
        brightness: Brightness.light,
      ),

      scaffoldBackgroundColor: backgroundColor,

      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: onSurfaceColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: onSurfaceColor),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: onSurfaceColor,
        ),
      ),

      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: const EdgeInsets.all(16),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: onPrimaryColor,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: GoogleFonts.inter(
          color: onSurfaceColor.withOpacity(0.8),
          fontWeight: FontWeight.w400,
        ),
        hintStyle: GoogleFonts.inter(
          color: onSurfaceColor.withOpacity(0.5),
          fontWeight: FontWeight.w300,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),

      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: onBackgroundColor,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: onBackgroundColor,
        ),
        displaySmall: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: onBackgroundColor,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: onBackgroundColor,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: onBackgroundColor,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: onBackgroundColor,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: onSurfaceColor,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: onSurfaceColor,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w300,
          color: onSurfaceColor,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: onSurfaceColor,
        ),
      ),

      iconTheme: const IconThemeData(color: onSurfaceColor),

      dividerTheme: DividerThemeData(
        color: onSurfaceColor.withOpacity(0.1),
        thickness: 1,
      ),

      listTileTheme: ListTileThemeData(
        tileColor: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  static TextStyle get balanceTextStyle => GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: onBackgroundColor,
      );

  static TextStyle get sectionHeaderTextStyle => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: onBackgroundColor,
      );

  static TextStyle get transactionAmountTextStyle => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: onSurfaceColor,
      );

  static TextStyle get mainTextStyle => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: onBackgroundColor,
      );

  static TextStyle get subTextStyle => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w300,
        color: onSurfaceColor,
      );

  static BoxDecoration get gradientCardDecoration => BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: primaryColor.withOpacity(0.2),
          width: 1.2,
        ),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [gradientStart, gradientEnd],
        ),
      );

  static BoxDecoration get transactionCardDecoration => BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryColor.withOpacity(0.1),
        ),
      );

  static BoxDecoration get successDecoration => BoxDecoration(
        color: primaryColor.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.25)),
      );

  static BoxDecoration get errorDecoration => BoxDecoration(
        color: errorColor.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: errorColor.withOpacity(0.25)),
      );

  static const double borderRadiusSmall = 12;
  static const double borderRadiusMedium = 16;
  static const double borderRadiusLarge = 20;
  static const double borderRadiusXLarge = 24;
  static const double borderRadiusXXLarge = 28;
}
