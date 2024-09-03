import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalStateProvider with ChangeNotifier {
  static final GlobalStateProvider _instance = GlobalStateProvider._internal();

  String _validatedIp = '192.168.1.9';
  bool _clubsLoaded = false;
  bool _isAuthenticated = false;

  GlobalStateProvider._internal() {
    _loadFromPreferences(); // Load initial values from SharedPreferences
  }

  factory GlobalStateProvider() {
    return _instance;
  }

  // Getters
  String get validatedIp => _validatedIp;
  bool get clubsLoaded => _clubsLoaded;
  bool get isAuthenticated => _isAuthenticated;

  // Setters
  set validatedIp(String value) {
    _validatedIp = value;
    _saveToPreferences('validatedIp', value);
    notifyListeners();
  }

  void setClubsLoaded(bool value) {
    _clubsLoaded = value;
    notifyListeners();
  }

  set isAuthenticated(bool value) {
    _isAuthenticated = value;
    _saveToPreferences('isAuthenticated', value);
    notifyListeners();
  }

  // Load values from SharedPreferences
  Future<void> _loadFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _validatedIp = prefs.getString('validatedIp') ?? '192.168.1.9';
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    notifyListeners();
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
