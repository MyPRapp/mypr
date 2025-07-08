import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalStateProvider with ChangeNotifier {
  static final GlobalStateProvider _instance = GlobalStateProvider._internal();

  bool _isAuthenticated = false;
  bool _hasVerifiedEmail = false;
  bool _preferencesLoaded =
      false; // Add this state to track if preferences are loaded
  final bool _hasCheckedAppVersion = false;
  bool _refreshProfilePage = false;
  bool _refreshHomePage = false;
  bool _refreshReservationPage = false;
  bool _justRegistered = false;
  String _mustSendCancellationEmail = '';

  GlobalStateProvider._internal() {
    loadFromPreferences(); // Load initial values from SharedPreferences
  }

  factory GlobalStateProvider() {
    return _instance;
  }

  // Getters

  bool get isAuthenticated => _isAuthenticated;

  bool get hasVerifiedEmail => _hasVerifiedEmail;

  bool get hasCheckedAppVersion => _hasCheckedAppVersion;

  bool get preferencesLoaded =>
      _preferencesLoaded; // New getter to check if preferences are loaded

  bool get refreshProfilePage => _refreshProfilePage;

  bool get refreshHomePage => _refreshHomePage;

  bool get refreshReservationPage => _refreshReservationPage;

  bool get justRegistered => _justRegistered;

  String get mustSendCancellationEmail => _mustSendCancellationEmail;

  // Setters
  set isAuthenticated(bool value) {
    _isAuthenticated = value;
    _saveToPreferences('isAuthenticated', value);

    notifyListeners();
  }

  set hasVerifiedEmail(bool value) {
    _hasVerifiedEmail = value;
    _saveToPreferences('hasVerifiedEmail', value);

    notifyListeners();
  }

  set mustSendCancellationEmail(String value) {
    _mustSendCancellationEmail = value;
    _saveToPreferences('mustSendCancellationEmail', value);

    notifyListeners();
  }

  set refreshProfilePage(bool value) {
    _refreshProfilePage = value;
    notifyListeners();
  }

  set refreshHomePage(bool value) {
    _refreshHomePage = value;
    notifyListeners();
  }

  set refreshReservationPage(bool value) {
    _refreshReservationPage = value;
    notifyListeners();
  }

  set justRegistered(bool value) {
    _justRegistered = value;
    notifyListeners();
  }

  // Load values from SharedPreferences
  Future<void> loadFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    _hasVerifiedEmail = prefs.getBool('hasVerifiedEmail') ?? false;
    _mustSendCancellationEmail =
        prefs.getString('mustSendCancellationEmail') ?? '';

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
