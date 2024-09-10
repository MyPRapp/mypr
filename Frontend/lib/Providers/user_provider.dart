import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img; // For image compression
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../global_components.dart';
import 'global_state_provider.dart';

class UserProvider with ChangeNotifier {
  UserInfoStruct? _userDetails;
  bool _isFetching = false;

  UserInfoStruct? get userDetails => _userDetails;
  bool get isFetching => _isFetching;

  // Fetch user details from the server, save to shared preferences, and notify listeners
  Future<void> fetchUserDetailsFromServer() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null) {
      throw Exception('No access token found');
    }

    try {
      _isFetching = true;
      notifyListeners();

      final response = await http.get(
        Uri.parse(
            'http://${GlobalStateProvider().validatedIp}:8000/api/user/print'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        _userDetails = UserInfoStruct.fromJson(jsonDecode(decodedBody));

        // Save user details and photo asynchronously
        await Future.wait([saveUserDetailsToPreferences(), _cacheUserPhoto()]);

        notifyListeners();
      } else {
        throw Exception('Failed to load user details');
      }
    } on TimeoutException catch (_) {
      // Fallback to cached data on timeout
      await loadUserDetailsFromPreferences();
      throw Exception('Request timed out, using cached data');
    } catch (e) {
      await loadUserDetailsFromPreferences();
      throw Exception('Server unreachable, using cached data');
    } finally {
      _isFetching = false;
      notifyListeners();
    }
  }

  // Save user details and photo to shared preferences
  Future<void> saveUserDetailsToPreferences() async {
    if (_userDetails == null) return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_details', jsonEncode(_userDetails!.toJson()));
  }

  // Load user details and photo from shared preferences
  Future<void> loadUserDetailsFromPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDetailsString = prefs.getString('user_details');

    if (userDetailsString != null) {
      _userDetails = UserInfoStruct.fromJson(jsonDecode(userDetailsString));
      await _loadCachedUserPhoto();
      notifyListeners();
    }
  }

  // Cache user photo for faster loading later
  Future<void> _cacheUserPhoto() async {
    if (_userDetails?.photo.isEmpty ?? true) return;

    String photoUrl =
        'http://${GlobalStateProvider().validatedIp}:8000/${_userDetails!.photo}';
    try {
      final photoFile = await _downloadAndCompressImage(photoUrl);
      if (photoFile.isNotEmpty) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_photo_path', photoFile);
      }
    } catch (e) {
      print('Error caching user photo: $e');
    }
  }

  // Load cached user photo from local storage if available
  Future<void> _loadCachedUserPhoto() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userPhotoPath = prefs.getString('user_photo_path');

    if (userPhotoPath != null && _userDetails != null) {
      File imageFile = File(userPhotoPath);
      if (await imageFile.exists()) {
        _userDetails!.photo = userPhotoPath;
      }
    }
  }

  // Download and compress the image, saving it to a file
  Future<String> _downloadAndCompressImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) return '';

      Uint8List imageBytes = response.bodyBytes;
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) return '';

      // Compress and resize the image
      img.Image compressedImage = img.copyResize(image, width: 512);
      List<int> jpegData = img.encodeJpg(compressedImage, quality: 85);

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/user_photo.jpg';
      File file = File(filePath);
      await file.writeAsBytes(jpegData);

      return filePath;
    } catch (e) {
      print('Error downloading/compressing image: $e');
      return '';
    }
  }

  // Load user photo from the local cache or server if not available
  Future<ImageProvider> loadUserPhoto(String photoPath) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedPhotoPath = prefs.getString('user_photo_path');

    if (savedPhotoPath != null) {
      File imageFile = File(savedPhotoPath);
      if (await imageFile.exists()) {
        return FileImage(imageFile);
      }
    }

    return CachedNetworkImageProvider(
        'http://${GlobalStateProvider().validatedIp}:8000/$photoPath');
  }
}
