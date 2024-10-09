import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalStateProvider with ChangeNotifier {
  static final GlobalStateProvider _instance = GlobalStateProvider._internal();

  String _validatedIp = '13.38.200.158';
  bool _isAuthenticated = false;
  bool _preferencesLoaded =
      false; // Add this state to track if preferences are loaded

  GlobalStateProvider._internal() {
    loadFromPreferences(); // Load initial values from SharedPreferences
  }

  factory GlobalStateProvider() {
    return _instance;
  }

  // Getters
  String get validatedIp => _validatedIp;

  bool get isAuthenticated => _isAuthenticated;

  bool get preferencesLoaded =>
      _preferencesLoaded; // New getter to check if preferences are loaded

  // Setters
  set validatedIp(String value) {
    _validatedIp = value;
    _saveToPreferences('validatedIp', value);

    notifyListeners();
  }

  set isAuthenticated(bool value) {
    _isAuthenticated = value;
    _saveToPreferences('isAuthenticated', value);

    notifyListeners();
  }

  // Load values from SharedPreferences
  Future<void> loadFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _validatedIp = prefs.getString('validatedIp') ?? '13.38.200.158';
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    // Set the preferences loaded state to true
    _preferencesLoaded = true;

    notifyListeners(); // Notify that preferences have been loaded
  }

  // Save values to SharedPreferences
  Future<void> _saveToPreferences(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    }
  }
}
