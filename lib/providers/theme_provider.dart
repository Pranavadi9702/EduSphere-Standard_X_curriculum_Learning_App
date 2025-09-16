import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool("isDarkMode") ?? false;
    notifyListeners();
  }

  void toggleTheme(bool value) async {
    _isDarkMode = value;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isDarkMode", value);
    notifyListeners();
  }
}
