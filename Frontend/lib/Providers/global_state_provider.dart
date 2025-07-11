import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalStateProvider with ChangeNotifier {
  static final GlobalStateProvider _instance = GlobalStateProvider._internal();

  bool _hasLoggedIn = false;
  bool _hasVerifiedEmail = false;
  bool _preferencesLoaded =
      false; // Add this state to track if preferences are loaded
  bool _hasCheckedAppVersion = false;
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
  bool get hasLoggedIn => _hasLoggedIn;

  bool get hasVerifiedEmail => _hasVerifiedEmail;

  bool get hasCheckedAppVersion => _hasCheckedAppVersion;

  bool get preferencesLoaded => _preferencesLoaded;

  bool get refreshProfilePage => _refreshProfilePage;

  bool get refreshHomePage => _refreshHomePage;

  bool get refreshReservationPage => _refreshReservationPage;

  bool get justRegistered => _justRegistered;

  String get mustSendCancellationEmail => _mustSendCancellationEmail;

  // Setters
  Future<void> setHasLoggedIn(bool value) async {
    _hasLoggedIn = value;
    await _saveToPreferences('hasLoggedIn', value);

    notifyListeners();
  }

  Future<void> setHasVerifiedEmail(bool value) async {
    _hasVerifiedEmail = value;
    await _saveToPreferences('hasVerifiedEmail', value);

    notifyListeners();
  }

  Future<void> setMustSendCancellationEmail(String value) async {
    _mustSendCancellationEmail = value;
    await _saveToPreferences('mustSendCancellationEmail', value);

    notifyListeners();
  }

  void setRefreshProfilePage(bool value) {
    _refreshProfilePage = value;
    notifyListeners();
  }

  void setRefreshHomePage(bool value) {
    _refreshHomePage = value;
    notifyListeners();
  }

  void setRefreshReservationPage(bool value) {
    _refreshReservationPage = value;
    notifyListeners();
  }

  void setJustRegistered(bool value) {
    _justRegistered = value;
    notifyListeners();
  }

  void setHasCheckedAppVersion(bool value) {
    _hasCheckedAppVersion = value;
    notifyListeners();
  }

  // Load values from SharedPreferences
  Future<void> loadFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _hasLoggedIn = prefs.getBool('hasLoggedIn') ?? false;
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
