import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Globals/global_components.dart';
import '../Globals/structs.dart';
import 'photo_manager.dart';

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
        _userDetails = UserInfoStruct.fromJson(jsonDecode(decodedBody));

        if (_userDetails.userID >= 0 && _userDetails.photo.isNotEmpty) {
          // Download and save user photo
          if (_userDetails.photo.isNotEmpty) {
            String localPath = await PhotoManager().downloadAndSaveUserPhoto(
                _userDetails.photo, 'user_${_userDetails.userID}_photo');

            _userDetails.localPhotoPath =
                localPath; // Store local path in the user object
          } else {
            errorPrint('Club photo URL is empty');
          }
        }

        await saveUserDetailsToPreferences();

        notifyListeners();
      } else {
        errorPrint('Failed to load user details');
        throw Exception('Failed to load user details');
      }
    } on TimeoutException catch (_) {
      // Fallback to cached data on timeout
      errorPrint('Failed to load user details.Request timed out');
      throw Exception('Request timed out, using cached data');
    } catch (e) {
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

      /* 
      final directory = await getApplicationDocumentsDirectory();
      final Directory userPhotosDirectory =
          Directory('${directory.path}/mypDirectory/user_photos');

      if (await userPhotosDirectory.exists()) {
        _userDetails.localPhotoPath =
            '${directory.path}/mypDirectory/user_photos/user_${_userDetails.userID}_photo.jpg';
      } else {
        errorPrint('User photos directory doesn\'t exist');
        _userDetails.localPhotoPath = 'assets/otherPhotos/Default_User.jpg';
      } 
      */

      successPrint('Loaded user details from preferences');

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
