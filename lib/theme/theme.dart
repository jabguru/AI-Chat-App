import 'package:ai_chat_app/gen/fonts.gen.dart';
import 'package:ai_chat_app/theme/colors.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static get themeData => ThemeData(
    brightness: Brightness.dark,
    fontFamily: FontFamily.poppins,
    scaffoldBackgroundColor: AppColors.background,
    colorSchemeSeed: AppColors.primary,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.white),
      surfaceTintColor: AppColors.background,
    ),
    textTheme: TextTheme(
      bodyMedium: TextStyle(
        fontSize: 14.0,
        color: AppColors.textColor,
        fontWeight: FontWeight.w400,
      ),
      bodyLarge: TextStyle(fontSize: 16.0, color: AppColors.textColor),
      headlineMedium: TextStyle(
        fontFamily: FontFamily.ranade,
        fontSize: 26.0,
        color: AppColors.white,
        fontWeight: FontWeight.w700,
        height: 1.23,
      ),
    ),
  );
}
