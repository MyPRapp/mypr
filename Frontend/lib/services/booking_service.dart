import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mypr/Globals/constants.dart';
import 'package:mypr/services/auth_service.dart';

import '../Globals/global_components.dart';

Future<bool> submitForm(String reservationName, String clubName, String type,
    String time, String numberOfPeople, String comments) async {
  String? accessToken = await _refreshAndGetAccessToken();
  if (accessToken == null) {
    errorPrint('Access token is null. User is not authenticated.');
    return false;
  }

  try {
    final response = await http
        .post(
      Uri.parse('$apiUrl/bookings/'),
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
      // print("❌Can't connect to server. Request timed out.");
      return http.Response('Error: Timeout', 408); // 408 Request Timeout
    });

    if (response.statusCode == 201) {
      successPrint('Booking successful');
      return true;
    } else {
      errorPrint('Booking failed: ${response.body}');
      return false;
    }
  } catch (e) {
    // print("❌Booking failed: $e");
    return false;
  }
}

Future<List<dynamic>?> getBookings() async {
  String? accessToken = await _refreshAndGetAccessToken();
  if (accessToken == null) {
    errorPrint('Access token is null. User is not authenticated.');
    return null;
  }

  try {
    final response = await http.get(
      Uri.parse('$apiUrl/bookings/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    ).timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        // print("❌Can't connect to server. Request timed out.");
        return http.Response('Error: Timeout', 408); // 408 Request Timeout
      },
    );

    if (response.statusCode == 200) {
      successPrint('Booking retrieval successful');

      // Decode using utf8 to handle non-ASCII characters properly
      final decodedBody = utf8.decode(response.bodyBytes);
      return jsonDecode(decodedBody) as List<dynamic>;
    } else {
      errorPrint('Booking retrieval failed: ${response.body}');
      return null;
    }
  } catch (e) {
    // print("❌Booking retrieval failed: $e");
    return null;
  }
}

Future<String?> _refreshAndGetAccessToken() async {
  // Refresh token before making API call
  try {
    await refreshAccessToken(); // Ensure token is refreshed
  } catch (e) {
    throw Exception('Token refresh failed');
  }
  return await getAccessToken();
}

Future<bool> deleteBooking(int bookingID) async {
  try {
    final response = await http.delete(
      Uri.parse('$apiUrl/bookings/delete/$bookingID/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getAccessToken()}',
      },
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 204) {
      successPrint('Booking $bookingID was deleted');
      return true;
    }
    errorPrint(
        'Error while deleting booking $bookingID: ${response.statusCode}\n${response.body}');
  } catch (e) {
    errorPrint('Unexpected error while deleting booking $bookingID: $e');
  }
  return false;
}
