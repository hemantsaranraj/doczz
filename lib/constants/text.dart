import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart'; // Import your color definitions

class AppTextStyles {
  static TextStyle headlineLarge = GoogleFonts.poppins(
    color: AppColors
        .lightTextColor, // Update with appropriate color based on the theme
    fontSize: 44,
    fontWeight: FontWeight.bold,
  );

  static TextStyle headlineMedium = GoogleFonts.poppins(
    color: AppColors
        .lightTextColor, // Update with appropriate color based on the theme
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );

  static TextStyle bodyLarge = GoogleFonts.poppins(
    color: AppColors
        .lightTextColor, // Update with appropriate color based on the theme
    fontSize: 16,
  );

  static TextStyle bodyMedium = GoogleFonts.poppins(
    color: AppColors
        .lightTextColor, // Update with appropriate color based on the theme
    fontSize: 16,
  );

  static TextStyle bodySmall = GoogleFonts.poppins(
    color: AppColors
        .lightTextColor, // Update with appropriate color based on the theme
    fontSize: 14, // Example size for bodySmall
  );
}
