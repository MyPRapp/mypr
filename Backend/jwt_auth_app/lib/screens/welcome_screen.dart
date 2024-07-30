import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'booking_screen.dart'; // Import the new BookingScreen

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final AuthService _authService = AuthService();
  String _username = '';
  String _email = '';
  String _firstName = '';
  String _lastName = '';
  String _phone = '';

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  _loadUserDetails() async {
    try {
      Map<String, dynamic> userDetails = await _authService.getUserDetails();
      setState(() {
        _username = userDetails['username'];
        _email = userDetails['email'];
        _firstName = userDetails['first_name'];
        _lastName = userDetails['last_name'];
        _phone = userDetails['phone'];
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load user details')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: Center(
        child: _username.isEmpty
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Welcome, $_username!',
                      style: const TextStyle(fontSize: 24)),
                  Text('First Name: $_firstName'),
                  Text('Last Name: $_lastName'),
                  Text('Email: $_email'),
                  Text('Phone Number: $_phone'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const BookingScreen()),
                      );
                    },
                    child: const Text('Make a Booking'),
                  ),
                ],
              ),
      ),
    );
  }
}

