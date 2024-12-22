import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: Colors.amber.shade500,
    // primary: Colors.amber.shade400,
    // secondary: Colors.amber.shade300,
    primary: Colors.black,
    secondary: Colors.white,
    // tertiary: const Color(0xff153BE8),
    // Colors.blue,
  ),
  textTheme: TextTheme(
    displayLarge: const TextStyle(
      fontSize: 72,
      fontWeight: FontWeight.bold,
    ),
    // TRY THIS: Change one of the GoogleFonts
    //           to "lato", "poppins", or "lora".
    //           The title uses "titleLarge"
    //           and the middle text uses "bodyMedium".
    titleLarge: GoogleFonts.oswald(
      fontSize: 30,
      fontStyle: FontStyle.italic,
    ),
    bodyMedium: GoogleFonts.merriweather(),
    displaySmall: GoogleFonts.pacifico(),
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: Colors.grey.shade900,
    primary: Colors.white,
    // primary: Colors.grey.shade700,
    secondary: Colors.grey.shade400,
  ),
  textTheme: TextTheme(
    displayLarge: const TextStyle(
      fontSize: 72,
      fontWeight: FontWeight.bold,
    ),
    // TRY THIS: Change one of the GoogleFonts
    //           to "lato", "poppins", or "lora".
    //           The title uses "titleLarge"
    //           and the middle text uses "bodyMedium".
    titleLarge: GoogleFonts.oswald(
      fontSize: 30,
      fontStyle: FontStyle.italic,
    ),
    bodyMedium: GoogleFonts.merriweather(),
    displaySmall: GoogleFonts.pacifico(),
  ),
);
