import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_constants.dart';

ThemeData defaultTheme = ThemeData(
  primaryColor: Constants.instance.lightPrimary,
  colorScheme: ColorScheme.light(
    primary: Constants.instance.lightPrimary,
    secondary: Constants.instance.lightSecondary,
    surface: const Color(0xFFF8F8F8),
    error: Constants.instance.lightError,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: const Color(0xFF1E293B),
    onError: Colors.white,
  ),
  scaffoldBackgroundColor: const Color(0xFFF8F8F8),
  fontFamily: GoogleFonts
      .poppins()
      .fontFamily,
  useMaterial3: true,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  textTheme: GoogleFonts.poppinsTextTheme().copyWith(
    displayLarge: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontSize: 28, fontWeight: FontWeight.w700),
    displayMedium: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontSize: 24, fontWeight: FontWeight.w600),
    titleLarge: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontSize: 20, fontWeight: FontWeight.w600),
    titleMedium: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontSize: 16, fontWeight: FontWeight.w600),
    bodyLarge: GoogleFonts.poppins(color: const Color(0xFF334155), fontSize: 16),
    bodyMedium: GoogleFonts.poppins(color: const Color(0xFF64748B), fontSize: 14),
    labelLarge: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
    labelSmall: GoogleFonts.poppins(color: const Color(0xFF94A3B8), fontSize: 11, letterSpacing: 0.8),
  ),
  appBarTheme: AppBarTheme(
    centerTitle: true,
    elevation: 0,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    titleTextStyle: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontSize: 18, fontWeight: FontWeight.w600),
    iconTheme: const IconThemeData(color: Color(0xFF1E293B), size: 22),
    actionsIconTheme: const IconThemeData(color: Color(0xFF1E293B), size: 22),
    shape: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return const Color(0xFFCBD5E1);
        if (states.contains(WidgetState.pressed)) return const Color(0xFF9B0000);
        return const Color(0xFFC60000);
      }),
      foregroundColor: WidgetStateProperty.all(Colors.white),
      elevation: WidgetStateProperty.all(0),
      padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 16, horizontal: 24)),
      shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      textStyle: WidgetStateProperty.all(GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
      overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(0.12)),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFFC60000),
      textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFFC60000),
      side: const BorderSide(color: Color(0xFFC60000), width: 1.5),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFC60000), width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFD32F2F)),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
    ),
    labelStyle: GoogleFonts.poppins(color: const Color(0xFF64748B), fontSize: 14),
    hintStyle: GoogleFonts.poppins(color: const Color(0xFFCBD5E1), fontSize: 14),
    prefixIconColor: const Color(0xFF94A3B8),
    suffixIconColor: const Color(0xFF94A3B8),
    floatingLabelStyle: GoogleFonts.poppins(color: const Color(0xFFC60000), fontSize: 13, fontWeight: FontWeight.w500),
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
  ),
  dividerTheme: const DividerThemeData(color: Color(0xFFE2E8F0), thickness: 1, space: 1),
  chipTheme: ChipThemeData(
    backgroundColor: const Color(0xFFFEF2F2),
    selectedColor: const Color(0xFFFEE2E2),
    labelStyle: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFFC60000)),
    secondaryLabelStyle: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF9B0000)),
    side: const BorderSide(color: Color(0xFFFECACA)),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: const Color(0xFFC60000),
    unselectedItemColor: const Color(0xFF94A3B8),
    selectedLabelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
    unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
    elevation: 0,
    type: BottomNavigationBarType.fixed,
  ),
  listTileTheme: const ListTileThemeData(
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    tileColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return Colors.white;
      return const Color(0xFFCBD5E1);
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return const Color(0xFFC60000);
      return const Color(0xFFE2E8F0);
    }),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFFC60000),
    foregroundColor: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
  ),
);
