import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../global_components.dart';
import 'global_state_provider.dart';

class UserProvider with ChangeNotifier {
  UserInfoStruct _userDetails = UserInfoStruct(
    userID: -1,
    username: '',
    firstName: '',
    lastName: '',
    email: '',
    phone: '',
    points: 0,
    photo: '',
  );

  UserInfoStruct get userDetails => _userDetails;

  // Fetch user details from the server, save to shared preferences, and notify listeners
  Future<void> fetchUserDetailsFromServer() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null) {
      print('\x1B[31mNo access token found');
      throw Exception('No access token found');
    }

    try {
      final response = await http.get(
        Uri.parse('http://${GlobalStateProvider().validatedIp}/api/user/print'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        _userDetails = UserInfoStruct.fromJson(jsonDecode(decodedBody));

        // Save user details and photo asynchronously
        await Future.wait([saveUserDetailsToPreferences()]);

        notifyListeners();
      } else {
        print('\x1B[31mFailed to load user details');
        throw Exception('Failed to load user details');
      }
    } on TimeoutException catch (_) {
      // Fallback to cached data on timeout
      await loadUserDetailsFromPreferences();
      throw Exception('Request timed out, using cached data');
    } catch (e) {
      await loadUserDetailsFromPreferences();
      throw Exception('Server unreachable, using cached data');
    }
  }

  // Save user details and photo to shared preferences
  Future<void> saveUserDetailsToPreferences() async {
    if (_userDetails.userID == -1) return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_details', jsonEncode(_userDetails.toJson()));
  }

  // Load user details and photo from shared preferences
  Future<void> loadUserDetailsFromPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDetailsString = prefs.getString('user_details');

    if (userDetailsString != null) {
      _userDetails = UserInfoStruct.fromJson(jsonDecode(userDetailsString));
      print('\x1B[32mLoaded user details from preferences');
      notifyListeners();
    }
  }

  Future<void> resetUserDetails() async {
    // Restore the default values of the _userDetails object
    _userDetails = UserInfoStruct(
      userID: -1,
      username: '',
      firstName: '',
      lastName: '',
      email: '',
      phone: '',
      points: 0,
      photo: '',
    );

    // Clear related user data from SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_details');

    // Notify listeners of the changes
    notifyListeners();
  }
}
