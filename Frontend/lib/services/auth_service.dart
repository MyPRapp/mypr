import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mypr/Globals/constants.dart';
import 'package:mypr/Globals/global_components.dart';
import 'package:mypr/Providers/global_state_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String?> getAccessToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('access_token');
}

Future<String?> getRefreshToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('refresh_token');
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
        .timeout(const Duration(seconds: 15), onTimeout: () {
      // print("❌Can't connect to server. Refresh token request timed out.");
      return http.Response('Error: Timeout', 408); // 408 Request Timeout
    });

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      String? newAccessToken = data['access'];

      if (newAccessToken != null) {
        await prefs.setString('access_token', newAccessToken);
        successPrint('Access token refreshed successfully');
        return;
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

Future<bool> registerDevice() async {
  String? token = await FirebaseMessaging.instance.getToken();

  if (token == null) {
    errorPrint('Firebase token not found');
    return false;
  }
  //TODO: Mila me fragkisko gia to http.post
  try {
    final response = await http
        .post(
      Uri.parse('$apiUrl/register_device/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getAccessToken()}'
      },
      body: jsonEncode({'device_token': token}),
    )
        .timeout(const Duration(seconds: 15), onTimeout: () {
      return http.Response('Error: Timeout', 408); // 408 Request Timeout
    });

    if (response.statusCode == 200) {
      successPrint('Device was registered');
      return true;
    } else {
      errorPrint(
          'Error while registering device: ${response.statusCode}\n${response.body}');
      return false;
    }
  } catch (e) {
    throw Exception('Error while registering device: $e');
  }
}

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
      errorPrint('Register response body: ${utf8.decode(response.bodyBytes)}');
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
      if (responseMap.containsKey('email') && responseMap['email'].isNotEmpty) {
        emailError =
            responseMap['email'][0]; // Get the first email error message
      }

      // Check if the phone key exists and has messages
      if (responseMap.containsKey('phone') && responseMap['phone'].isNotEmpty) {
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

Future<int> changeEmailOnServerOnly(String email) async {
  String? accessToken = await getAccessToken();
  if (accessToken == null) {
    errorPrint('Access token is null. User is not authenticated.');
    return 1;
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
      print("❌Can't connect to server. Request timed out.");
      return http.Response('Error: Timeout', 408); // 408 Request Timeout
    });

    if (response.statusCode == 200) {
      successPrint('Email changed successfully');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('savedEmail', email);
      return 0;
    } else {
      errorPrint('Email change failed: ${response.body}');
      // Check if the response contains the specific error message
      if (json.decode(response.body)['error'] ==
          "This email is already in use by another user.") {
        return 2;
      }

      return 1;
    }
  } catch (e) {
    return 1;
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
      if (responseMap.containsKey('error') && responseMap['error'].isNotEmpty) {
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

Future<bool> newUserAlertEmail() async {
  final response = await http
      .post(
    Uri.parse('$apiUrl/send-email/'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'subject': 'Νέος χρήστης',
      'sender_email': 'georgetsomhs@gmail.com',
      'message': 'Καινούριος χρήστης, δεν έχει εγγραφεί ακόμα!',
    }),
  )
      .timeout(const Duration(seconds: 8), onTimeout: () {
    errorPrint('Error on email sending: Timeout exception');
    return http.Response('Error: Timeout', 408);
  });

  if (response.statusCode == 200) {
    successPrint('Email sent successfully');
    return true;
  } else {
    errorPrint('Error on email sending: ${response.body}');
    return false;
  }
}

Future<void> fetchVerifiedEmailGlobalVariable(BuildContext context) async {
  try {
    var response = await http.get(
      Uri.parse('$apiUrl/user-auth-status/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getAccessToken()}',
      },
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      successPrint(response.body);
      String jsonString = response.body;
      Map<String, dynamic> jsonData = jsonDecode(jsonString); // Decode JSON

      bool isVerified = jsonData['is_verified']; // Extract the boolean value
      if (context.mounted) {
        context.read<GlobalStateProvider>().hasVerifiedEmail = isVerified;
        return;
      }
      errorPrint('Not mounted');
    }
    errorPrint('${response.statusCode}');
    errorPrint(response.body);
    if (context.mounted) {
      context.read<GlobalStateProvider>().hasVerifiedEmail = false;
    }
  } catch (e) {
    errorPrint('Error while fetching \'verified email\' global variable: $e');
  }
}

Future<int> checkPlatformVersion(
    String currentVersion, String platformUrl) async {
  final url = '$apiUrl/$platformUrl/';

  try {
    final response =
        await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      String minimumVersion = response.body.replaceAll('"', '');
      return compareVersions(currentVersion, minimumVersion);
    } else {
      errorPrint('Couldn\'t check version via server: ${response.body}');
    }
  } catch (e) {
    errorPrint('Couldn\'t check version via server');
  }
  return 0;
}
