import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../global_components.dart';
import 'global_state_provider.dart';

class UserProvider with ChangeNotifier {
  UserInfoStruct? _userDetails;

  UserInfoStruct? get userDetails => _userDetails;

  // Save user details including the photo to shared preferences
  Future<void> saveUserDetailsToPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_userDetails != null) {
      // Save user details
      await prefs.setString('user_details', jsonEncode(_userDetails!.toJson()));

      // Fetch and save the user's photo as a base64 string if it exists
      if (_userDetails!.photo.isNotEmpty) {
        String base64Photo = await imageToBase64(
            'http://${GlobalStateProvider().validatedIp}:8000/${_userDetails!.photo}');
        if (base64Photo.isNotEmpty) {
          await prefs.setString('user_photo', base64Photo);
        } else {
          debugPrint('User photo could not be saved as base64');
        }
      }
    }
  }

  // Load user details including the photo from shared preferences
  Future<void> loadUserDetailsFromPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDetailsString = prefs.getString('user_details');
    String? userPhotoBase64 = prefs.getString('user_photo');

    if (userDetailsString != null) {
      _userDetails = UserInfoStruct.fromJson(jsonDecode(userDetailsString));

      // If a photo is saved, convert it back from base64 and assign it to the user details
      if (userPhotoBase64 != null && _userDetails != null) {
        // final Uint8List bytes = base64Decode(userPhotoBase64);
        // _userDetails!.photo = base64Encode(bytes); // Save photo as a base64 string
        _userDetails!.photo = userPhotoBase64;
      }
      notifyListeners();
    }
  }

  // Fetch user details from the server and save them to shared preferences
  Future<void> fetchUserDetailsFromServer() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token != null) {
      final response = await http.get(
        Uri.parse(
            'http://${GlobalStateProvider().validatedIp}:8000/api/user/print'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);

        _userDetails = UserInfoStruct.fromJson(jsonDecode(decodedBody));

        // Save user details and photo to shared preferences
        await saveUserDetailsToPreferences();

        notifyListeners();
      } else {
        throw Exception('Failed to load user details');
      }
    } else {
      throw Exception('No access token found');
    }
  }

  // Sync user details by first fetching from the server and falling back to loading from preferences if fetching fails
  Future<void> syncUserDetails() async {
    try {
      await fetchUserDetailsFromServer(); // Try fetching from the server
    } catch (e) {
      debugPrint('Failed to fetch from server, loading from preferences: $e');
      await loadUserDetailsFromPreferences(); // If it fails, load from preferences
    }
    notifyListeners(); // Notify listeners regardless of where the data came from
  }
}
