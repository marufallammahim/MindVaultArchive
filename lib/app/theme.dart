import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5A0719),
          brightness: Brightness.light,
        ),
        inputDecorationTheme:
            const InputDecorationTheme(border: InputBorder.none),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD58A9B),
          brightness: Brightness.dark,
        ),
        inputDecorationTheme:
            const InputDecorationTheme(border: InputBorder.none),
      );
}
