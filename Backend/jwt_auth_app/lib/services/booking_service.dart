import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BookingService {
  final String baseUrl =
      'http://127.0.0.1:8000/api'; // or your local network IP

  Future<String?> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<bool> submitForm(
      String clubName, String type, String time, String numberOfPeople) async {
    String? accessToken = await getAccessToken();

    if (accessToken == null) {
      print('Access token is null. User is not authenticated.');
      return false;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/bookings/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'club_name': clubName,
        'booking_type': type,
        'booked_at': time,
        'number_of_people': numberOfPeople,
      }),
    );

    print('Submit form response status: ${response.statusCode}');
    print('Submit form response body: ${response.body}');

    if (response.statusCode == 201) {
      print('Booking successful');
      return true;
    } else {
      print('Booking failed: ${response.body}');
      return false;
    }
  }

  // Function to fetch club details from the server
  Future<Map<String, dynamic>> getClubDetails(String clubId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/clubs/details/$clubId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load club details');
    }
  }
}
