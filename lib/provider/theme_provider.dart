import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';

/// App-wide theme state. Registered above MaterialApp with
/// ChangeNotifierProvider so any screen can flip light/dark mode with
/// `context.read<ThemeProvider>().toggleTheme()` and rebuild reactively
/// with `context.watch<ThemeProvider>()`.
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    _isDarkMode = await LocalStorageService.getDarkMode();
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    await LocalStorageService.setDarkMode(_isDarkMode);
  }

  Future<void> setDarkMode(bool value) async {
    if (_isDarkMode == value) return;
    _isDarkMode = value;
    notifyListeners();
    await LocalStorageService.setDarkMode(_isDarkMode);
  }
}
