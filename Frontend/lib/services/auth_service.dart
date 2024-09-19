import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mypr/Providers/global_state_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  String get baseUrl => 'http://${GlobalStateProvider().validatedIp}:8000/api';

  Future<bool> login(String username, String password) async {
    try {
      // Send login request
      final response = await http
          .post(
            Uri.parse('$baseUrl/token/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(const Duration(seconds: 5)); // Adding a 5-second timeout

      // Check if the response is successful
      if (response.statusCode == 200) {
        print('\x1B[32mLogin successful');
        print('\x1B[33mParsing tokens...');
        var data = jsonDecode(response.body);
        String? accessToken = data['access'];
        String? refreshToken = data['refresh'];

        // Check if tokens are received
        if (accessToken != null && refreshToken != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', accessToken);
          await prefs.setString('refresh_token', refreshToken);
          await prefs.setString('saved_email', username);
          await prefs.setString('saved_password', password);

          print('\x1B[32mTokens received and saved to SharedPreferences');
          return true;
        } else {
          print('\x1B[31mTokens are null');
          return false;
        }
      } else {
        print('\x1B[31mLogin failed with status code: ${response.statusCode}');
        print('\x1B[31mResponse body: ${utf8.decode(response.bodyBytes)}');
        return false;
      }
    } catch (e) {
      print('\x1B[31mException occurred during login: $e');
      return false;
    }
  }

  Future<bool> register(String username, String password, String firstName,
      String lastName, String email, String phone, int points) async {
    try {
      // Send registration request
      final response = await http
          .post(
            Uri.parse('$baseUrl/user/register/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': username,
              'password': password,
              'first_name': firstName,
              'last_name': lastName,
              'email': email,
              'phone': phone,
              'points': points,
            }),
          )
          .timeout(const Duration(seconds: 5));

      // Log response details
      print('\x1B[32mRegister response status: ${response.statusCode}');
      print(
          '\x1B[32mRegister response body: ${utf8.decode(response.bodyBytes)}');

      // Check if registration was successful
      if (response.statusCode == 201) {
        print('\x1B[32mRegistration successful');
        return true;
      } else {
        print('\x1B[31mRegistration failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('\x1B[31mException occurred during registration: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getUserDetails() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      // Check if token exists
      if (token == null) {
        print('\x1B[31mAccess token not found');
        throw Exception('Access token not found');
      }

      // Fetch user details
      final response = await http.get(
        Uri.parse('$baseUrl/user/print'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        print('\x1B[32mUser details loaded successfully');
        return jsonDecode(response.body);
      } else {
        print('\x1B[31mFailed to load user details: ${response.statusCode}');
        throw Exception('Failed to load user details');
      }
    } catch (e) {
      print('\x1B[31mException occurred while loading user details: $e');
      rethrow;
    }
  }

  Future<void> refreshAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? refreshToken = prefs.getString('refresh_token');

    if (refreshToken == null) {
      throw Exception('Refresh token not found');
    }

    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      )
          .timeout(const Duration(seconds: 10), onTimeout: () {
        print(
            "\x1B[31mCan't connect to server. Refresh token request timed out.");
        return http.Response('Error: Timeout', 408); // 408 Request Timeout
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        String? newAccessToken = data['access'];

        if (newAccessToken != null) {
          await prefs.setString('access_token', newAccessToken);
          print('\x1B[32mAccess token refreshed successfully');
        } else {
          throw Exception('Failed to refresh access token');
        }
      } else {
        throw Exception('Failed to refresh access token');
      }
    } catch (e) {
      print('\x1B[31mError refreshing access token: $e');
      rethrow;
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
    print('\x1B[32mUser logged out successfully');
  }
}
