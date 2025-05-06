import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeProvider() {
    _loadTheme(); // Load theme from SharedPreferences when provider initializes
  }

  ThemeMode get themeMode => _themeMode;

  void toggleTheme(bool isDarkMode) async {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setBool('isDarkMode', isDarkMode); // Save theme preference
  }

  Future<void> _loadTheme() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    bool isDarkMode = sp.getBool('isDarkMode') ?? false;
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // Update UI when loading the saved theme
  }
}
