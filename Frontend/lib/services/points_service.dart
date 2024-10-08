import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mypr/services/auth_service.dart';

import '../global_components.dart';

class PointsService {
  Future<int> retractPoints(int points) async {
    //Only retracts points(can't add point if negative points are given)
    String? accessToken = await getAccessToken();
    final response = await http.post(
      Uri.parse('$apiUrl/reduce-points/'),
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
