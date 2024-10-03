import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mypr/Providers/global_state_provider.dart';
import 'package:mypr/services/auth_service.dart';

class PointsService {
  String get apiUrl =>
      'http://${GlobalStateProvider().validatedIp}/api/reduce-points/'; // Dynamically generate apiUrl

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
