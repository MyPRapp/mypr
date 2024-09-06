import 'dart:async';
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
      print('User details saved to preferences: ${_userDetails!.toJson()}');

      // Fetch and save the user's photo as a base64 string if it exists
      if (_userDetails!.photo.isNotEmpty) {
        String base64Photo = await imageToBase64(
            'http://${GlobalStateProvider().validatedIp}:8000/${_userDetails!.photo}');
        if (base64Photo.isNotEmpty) {
          await prefs.setString('user_photo', base64Photo);
          print('User photo saved to preferences as base64');
        } else {
          debugPrint('User photo could not be saved as base64');
        }
      }
    } else {
      print('No user details to save');
    }
  }

// Load user details including the photo from shared preferences
  Future<bool> loadUserDetailsFromPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDetailsString = prefs.getString('user_details');
    String? userPhotoBase64 = prefs.getString('user_photo');

    if (userDetailsString != null) {
      _userDetails = UserInfoStruct.fromJson(jsonDecode(userDetailsString));
      print('User details loaded from preferences: $_userDetails');

      // If a photo is saved, convert it back from base64 and assign it to the user details
      if (userPhotoBase64 != null && _userDetails != null) {
        _userDetails!.photo = userPhotoBase64;
        print('User photo loaded from preferences');
      }
      notifyListeners();
      return true; // Successfully loaded user details
    } else {
      print('No user details found in preferences');
      return false; // No user details found in preferences
    }
  }

  // Fetch user details from the server and save them to shared preferences
  Future<void> fetchUserDetailsFromServer() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token != null) {
      try {
        print('Fetching user details from server...');

        final response = await http.get(
          Uri.parse(
              'http://${GlobalStateProvider().validatedIp}:8000/api/user/print'),
          headers: {'Authorization': 'Bearer $token'},
        ).timeout(const Duration(seconds: 5)); // Add a 5-second timeout

        if (response.statusCode == 200) {
          final decodedBody = utf8.decode(response.bodyBytes);
          _userDetails = UserInfoStruct.fromJson(jsonDecode(decodedBody));

          // Save user details and photo to shared preferences
          await saveUserDetailsToPreferences();
          print('User details fetched and saved');
          notifyListeners();
        } else {
          print(
              'Failed to load user details from server: ${response.statusCode}');
          throw Exception('Failed to load user details');
        }
      } on TimeoutException catch (e) {
        print('Request to server timed out: $e');
        await loadUserDetailsFromPreferences();
        throw Exception('Request timed out, using saved preferences');
      } catch (e) {
        print('Server unreachable, falling back to saved preferences: $e');
        await loadUserDetailsFromPreferences();
        throw Exception('Server unreachable, using saved preferences');
      }
    } else {
      print('No access token found');
      throw Exception('No access token found');
    }
  }
}
