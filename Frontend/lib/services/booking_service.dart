import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mypr/Providers/global_state_provider.dart';
import 'package:mypr/services/auth_service.dart';

class BookingService {
  final AuthService _authService =
      AuthService(); // Create instance of AuthService
  String get baseUrl => 'http://${GlobalStateProvider().validatedIp}:8000/api';

  Future<void> _ensureTokenIsValid() async {
    try {
      await _authService.refreshAccessToken(); // Ensure token is refreshed
    } catch (e) {
      throw Exception('Token refresh failed');
    }
  }

  Future<String?> _getAccessToken() async {
    await _ensureTokenIsValid(); // Refresh token before making API call
    return await _authService.getAccessToken();
  }

  Future<bool> submitForm(String reservationName, String clubName, String type,
      String time, String numberOfPeople, String comments) async {
    String? accessToken = await _getAccessToken();
    if (accessToken == null) {
      print('Access token is null. User is not authenticated.');
      return false;
    }

    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/bookings/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'reservation_name': reservationName,
          'club_name': clubName,
          'booking_type': type,
          'booked_at': time,
          'number_of_people': numberOfPeople,
          'comments': comments,
        }),
      )
          .timeout(const Duration(seconds: 8), onTimeout: () {
        print("Can't connect to server. Request timed out.");
        return http.Response('Error: Timeout', 408); // 408 Request Timeout
      });

      if (response.statusCode == 201) {
        print('Booking successful');
        return true;
      } else {
        print('Booking failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print("Booking failed: $e");
      return false;
    }
  }

  Future<List<dynamic>?> getBookings() async {
    String? accessToken = await _getAccessToken();
    if (accessToken == null) {
      print('Access token is null. User is not authenticated.');
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/bookings/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      ).timeout(const Duration(seconds: 5), onTimeout: () {
        print("Can't connect to server. Request timed out.");
        return http.Response('Error: Timeout', 408); // 408 Request Timeout
      });

      if (response.statusCode == 200) {
        print('Booking retrieval successful');
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        print('Booking retrieval failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print("Booking retrieval failed: $e");
      return null;
    }
  }
}
