import 'package:flutter/material.dart';
import 'package:jwt_auth_app/services/club_details_screen.dart';

import 'screens/login_screen.dart';
// import 'services/auth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter JWT Auth',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(),
      routes: {
        '/welcome': (context) => const ClubsPage(),
        // Add other routes here
      },
    );
  }
}
/* 
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: Center(
        child: FutureBuilder<String?>(
          future: AuthService().getAccessToken(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasData) {
              return Text('Welcome! Your token: ${snapshot.data}');
            } else {
              return const Text('No token found.');
            }
          },
        ),
      ),
    );
  }
} */
