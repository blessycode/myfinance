import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const preferenceKey = 'jireh_theme_is_dark';
  bool _isDark;

  ThemeProvider({bool initialIsDark = false}) : _isDark = initialIsDark;
  bool get isDark => _isDark;

  Future<void> setDark(bool value) async {
    if (_isDark == value) return;
    _isDark = value;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(preferenceKey, value);
  }

  void toggle() {
    setDark(!_isDark);
  }
}
