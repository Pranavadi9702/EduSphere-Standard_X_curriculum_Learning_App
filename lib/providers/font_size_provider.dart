import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontSizeProvider with ChangeNotifier {
  double _fontSize = 14.0; // Default font size

  double get fontSize => _fontSize;

  FontSizeProvider() {
    _loadFontSize();
  }

  void _loadFontSize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _fontSize = prefs.getDouble('fontSize') ?? 14.0;
    notifyListeners();
  }

  void setFontSize(double newSize) async {
    if (newSize == 12.0 || newSize == 14.0 || newSize == 16.0) {
      _fontSize = newSize;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('fontSize', newSize);
      notifyListeners();
    }
  }
}
