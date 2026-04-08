import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color accentColor = Color(0xFF6161F2);
  
  // Dark Theme Colors
  static const Color darkBase = Color(0xFF0A0A0A);
  static const Color darkRaised = Color(0xFF141414);
  static const Color darkOverlay = Color(0xFF1A1A1A);
  static const Color darkElevated = Color(0xFF242424);
  
  // Light Theme Colors
  static const Color lightBase = Color(0xFFFFFFFF);
  static const Color lightRaised = Color(0xFFF7F7F7);
  static const Color lightOverlay = Color(0xFFF0F0F0);
  static const Color lightElevated = Color(0xFFE8E8E8);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentColor,
        brightness: Brightness.light,
        surface: lightBase,
        onSurface: Colors.black,
      ),
      scaffoldBackgroundColor: lightBase,
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBase,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: const CardTheme(
        color: lightRaised,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentColor,
        brightness: Brightness.dark,
        surface: darkRaised,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: darkBase,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBase,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: const CardTheme(
        color: darkRaised,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    );
  }
}
