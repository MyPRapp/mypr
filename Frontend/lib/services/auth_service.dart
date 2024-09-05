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
        print('Login successful, parsing tokens...');
        var data = jsonDecode(response.body);
        String? accessToken = data['access'];
        String? refreshToken = data['refresh'];

        // Check if tokens are received
        if (accessToken != null && refreshToken != null) {
          print('Tokens received, saving to SharedPreferences...');
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', accessToken);
          await prefs.setString('refresh_token', refreshToken);
          await prefs.setString('saved_email', username);
          await prefs.setString('saved_password', password);

          return true;
        } else {
          print('Tokens are null');
        }
      } else {
        print('Login failed with status code: ${response.statusCode}');
        print('Response body: ${utf8.decode(response.bodyBytes)}');
      }
    } catch (e) {
      print('Exception occurred during login: $e');
    }

    return false;
  }

  Future<bool> register(String username, String password, String firstName,
      String lastName, String email, String phone, int points) async {
    try {
      // Send registration request
      final response = await http.post(
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
      );

      // Log response details
      print('Register response status: ${response.statusCode}');
      print('Register response body: ${utf8.decode(response.bodyBytes)}');

      // Check if registration was successful
      if (response.statusCode == 201) {
        print('Registration successful');
        return true;
      } else {
        print('Registration failed: ${response.body}');
      }
    } catch (e) {
      print('Exception occurred during registration: $e');
    }

    return false;
  }

  Future<Map<String, dynamic>> getUserDetails() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      // Check if token exists
      if (token == null) {
        throw Exception('Access token not found');
      }

      // Fetch user details
      final response = await http.get(
        Uri.parse('$baseUrl/user/print'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        print('User details loaded successfully');
        return jsonDecode(response.body);
      } else {
        print('Failed to load user details: ${response.statusCode}');
        throw Exception('Failed to load user details');
      }
    } catch (e) {
      print('Exception occurred while loading user details: $e');
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
          .timeout(const Duration(seconds: 8), onTimeout: () {
        print("Can't connect to server. Refresh token request timed out.");
        return http.Response('Error: Timeout', 408); // 408 Request Timeout
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        String? newAccessToken = data['access'];

        if (newAccessToken != null) {
          await prefs.setString('access_token', newAccessToken);
          print('Access token refreshed successfully');
        } else {
          throw Exception('Failed to refresh access token');
        }
      } else {
        throw Exception('Failed to refresh access token');
      }
    } catch (e) {
      print('Error refreshing access token: $e');
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
    print('User logged out successfully');
  }
}
