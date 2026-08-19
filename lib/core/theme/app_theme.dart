import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_font_sizes.dart';
import 'app_font_weights.dart';

class AppTheme {
  static const LinearGradient loginGradient = LinearGradient(
    begin: Alignment(0.98, 1.00),
    end: Alignment(0.10, 0.00),

    colors: [
      Color(0xFF0035AB),
      Color(0xFFBAD0FF),
    ],

    stops: [0.6, 1.0],
  );
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryBlue,
      surface: Colors.white,
      onSurface: AppColors.greyText,
      error: AppColors.errorRed,
    ),
    textTheme: GoogleFonts.interTextTheme(
      TextTheme(
        headlineSmall: TextStyle(
          inherit: false,
          fontFamily: 'Inter',
          fontSize: AppFontSizes.welcomeHeading,
          fontWeight: AppFontWeights.medium,
          color: AppColors.primaryBlue,
          height: 1.0,
          letterSpacing: 0,
        ),
        bodyMedium: TextStyle(
          inherit: false,
          fontFamily: 'Inter',
          fontSize: AppFontSizes.bodyText,
          fontWeight: AppFontWeights.regular,
          color: AppColors.greyText,
          height: 1.0,
        ),

        labelSmall: TextStyle(
          inherit: false,
          fontFamily: 'Inter',
          fontSize: AppFontSizes.labelSmall,
          fontWeight: AppFontWeights.regular,
          color: Colors.black,
          height: 1.0,
          letterSpacing: 0,
        ),

        labelMedium: TextStyle(
          inherit: false,
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w300,
          color: Colors.black.withOpacity(0.5),
          height: 1.0,
        ),

        labelLarge: TextStyle(
          inherit: false,
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          height: 1.0,
        ),
      ),
    ),
  );
}