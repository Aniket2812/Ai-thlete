import 'package:flutter/material.dart';

class AppTheme {
  static const Color backgroundColor = Color(0xFF000000);
  static const Color cardBackgroundColor = Color(0xFF121212);
  static const Color cardColor = Color(0xFF121212);
  static const Color accentColor = Color(0xFFE0FE10);
  static const Color textColor = Colors.white;
  static const Color secondaryTextColor = Color(0xFF9E9E9E);
  static const Color primaryColor = Colors.white;
  static const Color errorColor = Colors.red;
  
  // Adding gradient definitions
  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF14001a),
      Color(0xFF14001a),
    ],
  );
  
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF75f0b9),
      Color(0xFF73ebac),
    ],
  );

  static final ThemeData darkTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    cardColor: cardColor,
    cardTheme: CardTheme(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.zero,
      color: cardBackgroundColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: cardBackgroundColor,
      selectedItemColor: accentColor,
      unselectedItemColor: secondaryTextColor,
      elevation: 8,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textColor),
      bodyMedium: TextStyle(color: textColor),
      titleLarge: TextStyle(color: textColor),
      titleMedium: TextStyle(color: textColor),
    ),
    iconTheme: const IconThemeData(
      color: accentColor,
    ),
    dividerColor: const Color(0xFF2A2A2A),
  );
}
