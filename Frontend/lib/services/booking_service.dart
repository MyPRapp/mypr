import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mypr/OtherPages/global_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingService {
  String get baseUrl =>
      'http://${GlobalState().validatedIp}:8000/api'; // Dynamically generate baseUrl

  Future<String?> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<bool> submitForm(String reservationName, String clubName, String type,
      String time, String numberOfPeople, String comments) async {
    String? accessToken = await getAccessToken();

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
          .timeout(const Duration(seconds: 10), onTimeout: () {
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
    String? accessToken = await getAccessToken();

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
      ).timeout(const Duration(seconds: 10), onTimeout: () {
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
