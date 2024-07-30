import 'dart:convert';
import 'package:http/http.dart' as http;
//import 'package:shared_preferences/shared_preferences.dart';

class BookingService {
  final String baseUrl = 'http://127.0.0.1:8000/api'; // or your local network IP

  Future<bool> submitForm(String clubName,String time,String type) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bookings/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'club': clubName,
        'booked_at': time,
        'booking_type': type,
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
}


