import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ClubsPage extends StatefulWidget {
  const ClubsPage({super.key});

  @override
  ClubsPageState createState() => ClubsPageState();
}

class ClubsPageState extends State<ClubsPage> {
  List<dynamic> clubs = [];
  bool isLoading = false;
  String errorMessage = '';

  void _fetchClubs() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    const url =
        'http://127.0.0.1:8000/api/clubs/print/'; // Replace with your API URL

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          clubs = data;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load clubs');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clubs'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            ElevatedButton(
              onPressed: _fetchClubs,
              child: const Text('Fetch Clubs'),
            ),
            if (isLoading) const CircularProgressIndicator(),
            if (errorMessage.isNotEmpty) Text('Error: $errorMessage'),
            Expanded(
              child: ListView.builder(
                itemCount: clubs.length,
                itemBuilder: (context, index) {
                  final club = clubs[index];
                  return ListTile(
                    title: Text(club['club_name']),
                    subtitle:
                        Text('${club['location']} - Rating: ${club['rating']}'),
                    trailing:
                        club['phone'] != null ? Text(club['phone']) : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
