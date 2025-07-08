import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mypr/Globals/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Globals/classes.dart';
import '../Globals/global_components.dart';

class UserProvider with ChangeNotifier {
  User _userDetails = User(
      userID: -1,
      username: '',
      firstName: '',
      lastName: '',
      email: '',
      phone: '',
      points: 0,
      isBanned: false);

  User get userDetails => _userDetails;

  //0: User logged in successfully
  //1: User didn't fill in the correct credentials
  //2: There was an error by our side
  Future<int> login(String email, String password) async {
    try {
      // Send login request
      final response = await http
          .post(
            Uri.parse('$apiUrl/token/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'username': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 8));

      // Check if the response is successful
      if (response.statusCode == 200) {
        successPrint('Login successful');

        var data = jsonDecode(response.body);
        String? accessToken = data['access'];
        String? refreshToken = data['refresh'];

        // Check if tokens are received
        if (accessToken != null && refreshToken != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', accessToken);
          await prefs.setString('refresh_token', refreshToken);
          await prefs.setString('savedEmail', email);
          await prefs.setString('savedPassword', password);

          successPrint('Tokens received and saved to SharedPreferences');
          return 0;
        } else {
          errorPrint('Tokens are null');
          return 2;
        }
      } else {
        errorPrint('Login failed with status code: ${response.statusCode}');
        errorPrint('Response body: ${utf8.decode(response.bodyBytes)}');
        return 1;
      }
    } catch (e) {
      errorPrint('Exception occurred during login: $e');
      return 2;
    }
  }

  // Fetch user details from the server, save to shared preferences, and notify listeners
  Future<void> fetchUserDetailsFromServer() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null) {
      errorPrint('No access token found');
      throw Exception('No access token found');
    }

    try {
      final response = await http.get(
        Uri.parse('$apiUrl/user/print'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        _userDetails = User.fromJson(jsonDecode(decodedBody));

        await saveUserDetailsToPreferences();

        notifyListeners();
      } else {
        errorPrint('Failed to load user details');
        throw Exception('Failed to load user details');
      }
    } on TimeoutException catch (_) {
      errorPrint('Failed to load user details.Request timed out');
      throw Exception('Request timed out, using cached data');
    } catch (e) {
      errorPrint('Server unreachable, using cached data');
      throw Exception('Server unreachable, using cached data');
    }
  }

  // Save user details and photo to shared preferences
  Future<void> saveUserDetailsToPreferences() async {
    if (_userDetails.userID < 0) return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_details', jsonEncode(_userDetails.toJson()));
  }

  // Load user details and photo from shared preferences
  Future<void> loadUserDetailsFromPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDetailsString = prefs.getString('user_details');

    if (userDetailsString == null) return;

    _userDetails = User.fromJson(jsonDecode(userDetailsString));
    successPrint('Loaded user details from preferences');

    notifyListeners();
  }

  Future<void> resetUserDetails() async {
    // Restore the default values of the _userDetails object
    _userDetails = User(
        userID: -1,
        username: '',
        firstName: '',
        lastName: '',
        email: '',
        phone: '',
        points: 0,
        isBanned: false);

    // Clear related user data from SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_details');

    notifyListeners();
  }
}
