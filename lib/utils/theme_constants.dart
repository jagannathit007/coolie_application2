import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_constants.dart';

ThemeData defaultTheme = ThemeData(
  primaryColor: Constants.instance.primary,
  colorScheme: ColorScheme.light(primary: Color(0xFF0D47A1), secondary: Colors.blue[600]!, surface: Colors.white),
  scaffoldBackgroundColor: Colors.white,
  fontFamily: GoogleFonts.poppins().fontFamily,
  textTheme: GoogleFonts.poppinsTextTheme().copyWith(
    displayLarge: GoogleFonts.poppins(color: Colors.black, fontSize: 28, fontWeight: FontWeight.bold),
    displayMedium: GoogleFonts.poppins(color: Colors.black, fontSize: 24, fontWeight: FontWeight.w600),
    bodyLarge: GoogleFonts.poppins(color: Colors.grey[800], fontSize: 16),
    bodyMedium: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 14),
    labelLarge: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
  ),
  appBarTheme: AppBarTheme(
    centerTitle: true,
    elevation: 0,
    backgroundColor: Colors.black,
    titleTextStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
    iconTheme: const IconThemeData(color: Colors.white),
    actionsIconTheme: const IconThemeData(color: Colors.white),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.black,
      textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.black,
      side: BorderSide(color: Color(0xFF0D47A1)),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey[50],
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Color(0xFF0D47A1), width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.red, width: 1.5),
    ),
    labelStyle: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14),
    hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 14),
  ),
  dividerTheme: DividerThemeData(color: Colors.grey[200], thickness: 1, space: 1),
  chipTheme: ChipThemeData(
    backgroundColor: Colors.grey[100],
    selectedColor: Color(0xFF0D47A1),
    labelStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
    secondaryLabelStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  visualDensity: VisualDensity.adaptivePlatformDensity,
  useMaterial3: true,
);
