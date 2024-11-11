import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mypr/Globals/global_components.dart';
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
  Future<bool> login(String email, String password) async {
    try {
      // Send login request
      final response = await http
          .post(
            Uri.parse('$apiUrl/token/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'username': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 5)); // Adding a 5-second timeout

      // Check if the response is successful
      if (response.statusCode == 200) {
        successPrint('Login successful');
        warningPrint('Parsing tokens...');
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
          return true;
        } else {
          errorPrint('Tokens are null');
          return false;
        }
      } else {
        errorPrint('Login failed with status code: ${response.statusCode}');
        errorPrint('Response body: ${utf8.decode(response.bodyBytes)}');
        return false;
      }
    } catch (e) {
      errorPrint('Exception occurred during login: $e');
      return false;
    }
  }

  Future<int> register(String username, String password, String firstName,
      String lastName, String email, String phone, int points) async {
    try {
      late http.Response response;
      // Send registration request
      if (phone.startsWith('69') && phone.length == 10) {
        response = await http
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
      } else {
        response = await http
            .post(
              Uri.parse('$apiUrl/user/register/'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'username': username,
                'password': password,
                'first_name': firstName,
                'last_name': lastName,
                'email': email,
                'phone': '1',
                'points': points,
              }),
            )
            .timeout(const Duration(seconds: 5));
      }
      // Log response details
      if (response.statusCode != 201) {
        errorPrint('Register response status: ${response.statusCode}');
        errorPrint(
            'Register response body: ${utf8.decode(response.bodyBytes)}');
      }

      // Check if registration was successful
      if (response.statusCode == 201) {
        successPrint('Registration successful');
        return 1;
      } else {
        errorPrint('Registration failed: ${response.body}');

        // Parse the JSON response
        Map<String, dynamic> responseMap = json.decode(response.body);

        // Initialize error strings
        String emailError = '';
        String phoneError = '';

        // Check if the email key exists and has messages
        if (responseMap.containsKey('email') &&
            responseMap['email'].isNotEmpty) {
          emailError =
              responseMap['email'][0]; // Get the first email error message
        }

        // Check if the phone key exists and has messages
        if (responseMap.containsKey('phone') &&
            responseMap['phone'].isNotEmpty) {
          phoneError =
              responseMap['phone'][0]; // Get the first phone error message
        }

        // Determine the output based on the extracted messages
        if (emailError.isNotEmpty && phoneError.isNotEmpty) {
          // print('Email and Phone: $emailError, $phoneError');
          return 4; // Both errors exist
        } else if (emailError.isNotEmpty) {
          // print('Email Error: $emailError');
          return 2; // Only email error
        } else if (phoneError.isNotEmpty) {
          // print('Phone Error: $phoneError');
          return 3; // Only phone error
        }

        return 0;
      }
    } catch (e) {
      errorPrint('Exception occurred during registration: $e');
      return 0;
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
        // print("❌Can't connect to server. Refresh token request timed out.");
        return http.Response('Error: Timeout', 408); // 408 Request Timeout
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        String? newAccessToken = data['access'];

        if (newAccessToken != null) {
          await prefs.setString('access_token', newAccessToken);
          successPrint('Access token refreshed successfully');
        } else {
          throw Exception('Failed to refresh access token');
        }
      } else {
        throw Exception('Failed to refresh access token');
      }
    } catch (e) {
      errorPrint('Error refreshing access token: $e');
      rethrow;
    }
  }

  Future<bool> changeEmailOnServerOnly(String email) async {
    //TODO Check if this works
    String? accessToken = await getAccessToken();
    if (accessToken == null) {
      errorPrint('Access token is null. User is not authenticated.');
      return false;
    }

    try {
      final response = await http
          .post(
        Uri.parse('$apiUrl/email-change/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'email': email,
        }),
      )
          .timeout(const Duration(seconds: 8), onTimeout: () {
        // print("❌Can't connect to server. Request timed out.");
        return http.Response('Error: Timeout', 408); // 408 Request Timeout
      });

      if (response.statusCode == 200) {
        successPrint('Email changed successfully');
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('savedEmail', email);
        return true;
      } else {
        errorPrint('Enail change failed: ${response.body}');
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<int> changePhoneOnServerOnly(String phone) async {
    String? accessToken = await getAccessToken();
    if (accessToken == null) {
      errorPrint('Access token is null. User is not authenticated.');
      return 1;
    }

    try {
      final response = await http
          .post(
        Uri.parse('$apiUrl/phone-change/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'phone_number': phone,
        }),
      )
          .timeout(const Duration(seconds: 8), onTimeout: () {
        // print("❌Can't connect to server. Request timed out.");
        return http.Response('Error: Timeout', 408); // 408 Request Timeout
      });

      if (response.statusCode == 200) {
        successPrint('Phone changed successfully');

        return 0;
      } else {
        // Parse the JSON response
        Map<String, dynamic> responseMap = json.decode(response.body);

        // Check if the phone key exists and has messages
        if (responseMap.containsKey('error') &&
            responseMap['error'].isNotEmpty) {
          errorPrint(
              responseMap['error'][0]); // Get the first phone error message
          return 2;
        }
        errorPrint('Phone change failed: ${response.body}');
        return 1;
      }
    } catch (e) {
      return 1;
    }
  }
}
