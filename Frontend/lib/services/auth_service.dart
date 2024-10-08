import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mypr/global_components.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String?> getAccessToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('access_token');
}

Future<String?> getRefreshToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('refresh_token');
}

class AuthService {
  Future<bool> login(String username, String password) async {
    try {
      // Send login request
      final response = await http
          .post(
            Uri.parse('$apiUrl/token/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(const Duration(seconds: 5)); // Adding a 5-second timeout

      // Check if the response is successful
      if (response.statusCode == 200) {
        print('✅Login successful');
        print('🟡Parsing tokens...');
        var data = jsonDecode(response.body);
        String? accessToken = data['access'];
        String? refreshToken = data['refresh'];

        // Check if tokens are received
        if (accessToken != null && refreshToken != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', accessToken);
          await prefs.setString('refresh_token', refreshToken);
          await prefs.setString('savedEmail', username);
          await prefs.setString('savedPassword', password);

          print('✅Tokens received and saved to SharedPreferences');
          return true;
        } else {
          print('❌Tokens are null');
          return false;
        }
      } else {
        print('❌Login failed with status code: ${response.statusCode}');
        print('❌Response body: ${utf8.decode(response.bodyBytes)}');
        return false;
      }
    } catch (e) {
      print('❌Exception occurred during login: $e');
      return false;
    }
  }

  Future<bool> register(String username, String password, String firstName,
      String lastName, String email, String phone, int points) async {
    try {
      // Send registration request
      final response = await http
          .post(
            Uri.parse('$apiUrl/user/register/'),
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
      print('✅Register response status: ${response.statusCode}');
      print('✅Register response body: ${utf8.decode(response.bodyBytes)}');

      // Check if registration was successful
      if (response.statusCode == 201) {
        print('✅Registration successful');
        return true;
      } else {
        print('❌Registration failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌Exception occurred during registration: $e');
      return false;
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
        Uri.parse('$apiUrl/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      )
          .timeout(const Duration(seconds: 10), onTimeout: () {
        print("❌Can't connect to server. Refresh token request timed out.");
        return http.Response('Error: Timeout', 408); // 408 Request Timeout
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        String? newAccessToken = data['access'];

        if (newAccessToken != null) {
          await prefs.setString('access_token', newAccessToken);
          print('✅Access token refreshed successfully');
        } else {
          throw Exception('Failed to refresh access token');
        }
      } else {
        throw Exception('Failed to refresh access token');
      }
    } catch (e) {
      print('❌Error refreshing access token: $e');
      rethrow;
    }
  }
}
