import 'package:flutter/material.dart';
import 'package:doczz/constants/colors.dart';
import 'package:doczz/constants/text.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      scaffoldBackgroundColor: AppColors.lightBackgroundColor,
      textTheme: ThemeData.light().textTheme.copyWith(
            headlineLarge: AppTextStyles.headlineLarge,
            headlineMedium: AppTextStyles.headlineMedium,
            bodyLarge: AppTextStyles.bodyLarge,
            bodyMedium: AppTextStyles.bodyMedium,
            bodySmall: AppTextStyles.bodySmall,
          ),
      iconTheme: const IconThemeData(color: AppColors.lightTextColor),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      scaffoldBackgroundColor: AppColors.darkBackgroundColor,
      textTheme: ThemeData.dark().textTheme.copyWith(
            headlineLarge: AppTextStyles.headlineLarge
                .copyWith(color: AppColors.darkTextColor),
            headlineMedium: AppTextStyles.headlineMedium
                .copyWith(color: AppColors.darkTextColor),
            bodyLarge: AppTextStyles.bodyLarge
                .copyWith(color: AppColors.darkTextColor),
            bodyMedium: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.darkTextColor),
            bodySmall: AppTextStyles.bodySmall
                .copyWith(color: AppColors.darkTextColor),
          ),
      iconTheme: const IconThemeData(color: AppColors.darkTextColor),
    );
  }
}
