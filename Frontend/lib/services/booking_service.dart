import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mypr/Providers/global_state_provider.dart';
import 'package:mypr/services/auth_service.dart';

class BookingService {
  final AuthService _authService =
      AuthService(); // Create instance of AuthService
  String get baseUrl => 'http://${GlobalStateProvider().validatedIp}/api';

  Future<bool> submitForm(String reservationName, String clubName, String type,
      String time, String numberOfPeople, String comments) async {
    String? accessToken = await _refreshAndGetAccessToken();
    if (accessToken == null) {
      print('\x1B[31mAccess token is null. User is not authenticated.');
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
        print("\x1B[31mCan't connect to server. Request timed out.");
        return http.Response('Error: Timeout', 408); // 408 Request Timeout
      });

      if (response.statusCode == 201) {
        print('\x1B[32mBooking successful');
        return true;
      } else {
        print('\x1B[31mBooking failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print("\x1B[31mBooking failed: $e");
      return false;
    }
  }

  Future<List<dynamic>?> getBookings() async {
    String? accessToken = await _refreshAndGetAccessToken();
    if (accessToken == null) {
      print('\x1B[31mAccess token is null. User is not authenticated.');
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/bookings/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print("\x1B[31mCan't connect to server. Request timed out.");
          return http.Response('Error: Timeout', 408); // 408 Request Timeout
        },
      );

      if (response.statusCode == 200) {
        print('\x1B[32mBooking retrieval successful');

        // Decode using utf8 to handle non-ASCII characters properly
        final decodedBody = utf8.decode(response.bodyBytes);
        return jsonDecode(decodedBody) as List<dynamic>;
      } else {
        print('\x1B[31mBooking retrieval failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print("\x1B[31mBooking retrieval failed: $e");
      return null;
    }
  }

  Future<String?> _refreshAndGetAccessToken() async {
    // Refresh token before making API call
    try {
      await _authService.refreshAccessToken(); // Ensure token is refreshed
    } catch (e) {
      throw Exception('Token refresh failed');
    }
    return await getAccessToken();
  }
}
