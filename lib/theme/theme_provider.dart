import 'package:depanini/theme/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// StateNotifier class to manage the theme state
class ThemeNotifier extends StateNotifier<ThemeData> {
  ThemeNotifier() : super(lightTheme) {
    _loadTheme();
  }

  // Load the theme from SharedPreferences
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDark') ?? false;
    state = isDark ? darkTheme : lightTheme;
  }

  // Toggle the theme between light and dark
  void toggleTheme() async {
    final newTheme = state == lightTheme ? darkTheme : lightTheme;
    state = newTheme;

    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDark', newTheme == darkTheme); // Save the theme preference
  }
}

// Create a provider for ThemeNotifier
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeData>((ref) {
  return ThemeNotifier();
});
