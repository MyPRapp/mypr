import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';




class PointsService {
  static const String apiUrl = 'http://127.0.0.1:8000/api/reduce-points/';
 

  Future<String?> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }


  Future<int> retractPoints(int points) async {
    String? accessToken = await getAccessToken();
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: json.encode({'points': points}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['current_points'];
    } else {
      throw Exception('Failed to retract points');
    }
  }
}
