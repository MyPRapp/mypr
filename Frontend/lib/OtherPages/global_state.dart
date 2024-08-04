import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ClubInfoStruct {
  late int clubID;
  late String clubName;
  late int clubMinPrice;
  late int clubMaxPersons;
  late String clubPhone;
  late String clubLocation;
  late double clubRating;
  late String clubAvailability;

  ClubInfoStruct({
    required this.clubID,
    this.clubName = '',
    this.clubMinPrice = -1,
    this.clubMaxPersons = -1,
    this.clubPhone = '',
    this.clubLocation = '',
    this.clubRating = -1,
    this.clubAvailability = '',
  });
}

class ClubProvider with ChangeNotifier {
  final Map<String, bool> _likedClubs = {};
  final List<ClubInfoStruct> _clubs = [];

  List<ClubInfoStruct> get likedClubs =>
      _clubs.where((club) => _likedClubs[club.clubName] == true).toList();

  List<ClubInfoStruct> get allClubs => _clubs;

  bool isLiked(String clubName) {
    return _likedClubs[clubName] ?? false;
  }

  void toggleLike(String clubName) {
    _likedClubs[clubName] = !(_likedClubs[clubName] ?? false);
    notifyListeners();
  }

  void addOrUpdateClub(ClubInfoStruct club) {
    int index = _clubs.indexWhere((c) => c.clubID == club.clubID);
    if (index != -1) {
      _clubs[index] = club;
    } else {
      _clubs.add(club);
    }
    notifyListeners();
  }

  void removeClub(int clubID) {
    _clubs.removeWhere((club) => club.clubID == clubID);
    notifyListeners();
  }

  String getClubAvailability(String clubName) {
    return _clubs
        .firstWhere((club) => club.clubName == clubName)
        .clubAvailability;
  }

  int getClubIDByName(String clubName) {
    return _clubs.firstWhere((club) => club.clubName == clubName).clubID;
  }
}

class UserProvider with ChangeNotifier {
  Map<String, dynamic>? _userDetails;

  Map<String, dynamic>? get userDetails => _userDetails;

  UserProvider() {
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDetailsString = prefs.getString('user_details');

    if (userDetailsString != null) {
      _userDetails = jsonDecode(userDetailsString);
      notifyListeners();
    }
  }

  Future<void> fetchUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token != null) {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/user/print'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        _userDetails = jsonDecode(response.body);
        await prefs.setString('user_details', jsonEncode(_userDetails));
        notifyListeners();
      } else {
        throw Exception('Failed to load user details');
      }
    } else {
      throw Exception('No access token found');
    }
  }
}

class AuthService {
  final String baseUrl = 'http://127.0.0.1:8000/api';

  Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/token/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      String? accessToken = data['access'];
      String? refreshToken = data['refresh'];

      if (accessToken != null && refreshToken != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', accessToken);
        await prefs.setString('refresh_token', refreshToken);
        await prefs.setString('saved_email', username);
        await prefs.setString('saved_password', password);

        // Fetch and save user details
        final userResponse = await http.get(
          Uri.parse('$baseUrl/user/print'),
          headers: {'Authorization': 'Bearer $accessToken'},
        );

        if (userResponse.statusCode == 200) {
          var userDetails = jsonDecode(userResponse.body);
          await prefs.setString('user_details', jsonEncode(userDetails));
        }

        return true;
      }
    }
    return false;
  }

  Future<bool> register(String username, String password, String firstName,
      String lastName, String email, String phone) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone
      }),
    );

    print('Register response status: ${response.statusCode}');
    print('Register response body: ${response.body}');

    if (response.statusCode == 201) {
      print('Registration successful');
      return true;
    } else {
      print('Registration failed: ${response.body}');
      return false;
    }
  }

  Future<Map<String, dynamic>> getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    final response = await http.get(
      Uri.parse('$baseUrl/user/print'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user details');
    }
  }

  Future<String?> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<String?> getRefreshToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }
}

class BottomNavBarVisibility extends ChangeNotifier {
  bool _isVisible = true;

  bool get isVisible => _isVisible;

  void show() {
    _isVisible = true;
    notifyListeners();
  }

  void hide() {
    _isVisible = false;
    notifyListeners();
  }
}
