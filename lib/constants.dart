// ignore_for_file: constant_identifier_names
import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// API
/// ---------------------------------------------------------------------------
const String API_BASE_URL = 'https://dummyjson.com';

/// ---------------------------------------------------------------------------
/// Brand colors (used as accents in both light & dark mode)
/// ---------------------------------------------------------------------------
const Color FB_PRIMARY = Color.fromARGB(255, 135, 222, 234);
const Color FB_SECONDARY = Color.fromARGB(255, 64, 214, 233);
const Color FB_DARK_PRIMARY = Color(0xFF00838F);
const Color FB_LIGHT_PRIMARY = Color(0xFFB2EBF2);
const Color FB_TEXT_COLOR_WHITE = Color.fromARGB(255, 0, 117, 98);

/// ---------------------------------------------------------------------------
/// Dark mode surface colors
/// ---------------------------------------------------------------------------
const Color FB_DARK_BG = Color(0xFF121212);
const Color FB_DARK_SURFACE = Color.fromARGB(255, 70, 69, 69);
const Color FB_DARK_CARD = Color(0xFF232323);
const Color FB_DARK_TEXT = Color(0xFFECECEC);

/// ---------------------------------------------------------------------------
/// Helpers so screens/widgets can adapt to the current theme without
/// hard-coding colors everywhere.
/// ---------------------------------------------------------------------------
bool isDark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

Color bgColor(BuildContext context) =>
    Theme.of(context).scaffoldBackgroundColor;

Color cardColor(BuildContext context) => Theme.of(context).cardColor;

Color primaryTextColor(BuildContext context) =>
    isDark(context) ? FB_DARK_TEXT : Colors.black;

Color secondaryTextColor(BuildContext context) =>
    isDark(context) ? Colors.grey[400]! : Colors.grey[600]!;

/// ---------------------------------------------------------------------------
/// Themes
/// ---------------------------------------------------------------------------
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: FB_LIGHT_PRIMARY,
  cardColor: const Color.fromARGB(255, 234, 248, 248),
  primaryColor: FB_DARK_PRIMARY,
  fontFamily: 'Frutiger',
  colorScheme: ColorScheme.fromSeed(
    seedColor: FB_DARK_PRIMARY,
    brightness: Brightness.light,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: FB_PRIMARY,
    foregroundColor: Colors.black,
    elevation: 2,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: FB_SECONDARY,
    selectedItemColor: FB_DARK_PRIMARY,
    unselectedItemColor: Colors.black54,
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Colors.black),
    bodyLarge: TextStyle(color: Colors.black),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.all(FB_DARK_PRIMARY),
  ),
  useMaterial3: true,
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: FB_DARK_BG,
  cardColor: FB_DARK_CARD,
  primaryColor: FB_DARK_PRIMARY,
  fontFamily: 'Frutiger',
  colorScheme: ColorScheme.fromSeed(
    seedColor: FB_DARK_PRIMARY,
    brightness: Brightness.dark,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: FB_DARK_SURFACE,
    foregroundColor: FB_DARK_TEXT,
    elevation: 2,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: FB_DARK_SURFACE,
    selectedItemColor: FB_DARK_PRIMARY,
    unselectedItemColor: Colors.grey,
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: FB_DARK_TEXT),
    bodyLarge: TextStyle(color: FB_DARK_TEXT),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.all(FB_DARK_PRIMARY),
  ),
  useMaterial3: true,
);
