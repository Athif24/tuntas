import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/theme_config.dart';

class ThemeProvider extends ChangeNotifier {
  final List<AppTheme> themes = allThemes;
  int _selectedThemeIndex = 0;

  ThemeProvider() {
    _loadSavedTheme();
  }

  AppTheme get currentTheme => themes[_selectedThemeIndex];
  int get selectedThemeIndex => _selectedThemeIndex;

  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIndex = prefs.getInt('selected_theme_index');
    if (savedIndex != null && savedIndex >= 0 && savedIndex < themes.length) {
      _selectedThemeIndex = savedIndex;
      notifyListeners();
    }
  }

  Future<void> setTheme(int index) async {
    if (index < 0 || index >= themes.length) return;
    _selectedThemeIndex = index;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_theme_index', index);
  }
}
