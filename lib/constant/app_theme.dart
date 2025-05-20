// app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Primary color for your app
  static Color primaryColor = Color(0xFFA1EEBD);
  
  // Secondary color
  static Color secondaryColor = Color(0xFF7BD3EA);
  
  // Background color
  static Color backgroundColor = Color(0xFFF3F3F3);
  
  // Text colors
  static Color primaryTextColor = Color(0xFF1B1238);
  static Color secondaryTextColor = Color(0xFFFB86A8);
  
  // AppBar color
  static Color appBarColor = Color(0xFFFFFFFF);
  
  // Floating Action Button color
  static Color fabColor = Color(0xFF7BD3EA);
  
  // Error color
  static Color errorColor = Color(0xFFFB86A8);
  
  // Success color
  static Color successColor = Color(0xFFA1EEBD);
  
  // Warning color
  static Color warningColor = Color(0xFFF6F7C4);
  
  // Get the ThemeData based on your custom colors
  static ThemeData get themeData {
    return ThemeData(
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        background: backgroundColor,
        error: errorColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: appBarColor,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: fabColor,
        foregroundColor: Colors.white,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: primaryTextColor),
        bodyMedium: TextStyle(color: primaryTextColor),
        titleLarge: TextStyle(color: primaryTextColor),
        titleMedium: TextStyle(color: primaryTextColor),
        titleSmall: TextStyle(color: secondaryTextColor),
      ),
    );
  }
}