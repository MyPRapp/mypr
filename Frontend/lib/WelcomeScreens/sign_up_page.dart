import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mypr/OtherPages/global_state.dart';
import 'package:mypr/routes/app_router.gr.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';

@RoutePage()
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final AuthService _authService = AuthService();

  Future<void> _register() async {
    String username = _userNameController.text.trim();
    String password = _passwordController.text.trim();
    String email = _emailController.text.trim();
    String lastName = _lastNameController.text.trim();
    String firstName = _firstNameController.text.trim();
    String phone = _phoneController.text.trim();

    bool success = await _authService.register(
        username, password, firstName, lastName, email, phone);

    if (!mounted) return;

    if (success) {
      context.router.replaceAll([const BottomNavBarRoute()]);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            duration: Duration(seconds: 4),
            content: Text('Registration failed')),
      );
    }
  }

  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  bool _obscureText2 = true;

  void _togglePasswordVisibility2() {
    setState(() {
      _obscureText2 = !_obscureText2;
    });
  }

  void _navigateToEmailLoginPage() {
    if (mounted) {
      context.router.replaceAll([const LoginRoute()]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BottomNavBarVisibility>().hide();
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: SizedBox(
          width: screenWidth,
          height: screenHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 70,
                width: screenWidth,
                child: const Image(
                  image: AssetImage('assets/clubPhotos/IMG_0041.jpg'),
                  fit: BoxFit.cover,
                  alignment: Alignment(0, -0.3),
                ),
              ),
              const SizedBox(
                height: 150,
                child: Image(
                  image: AssetImage(
                      'assets/clubPhotos/Screenshot 2024-07-28 021714-Photoroom.png'),
                ),
              ),
              SizedBox(
                width: screenWidth - 60,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 40,
                      child: Text(
                        'Δημιουργία λογαριασμού',
                        style: TextStyle(
                          color: Color(0xFF9c0c04),
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 45,
                      width: screenWidth - 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            height: 45,
                            width: (screenWidth - 60) / 2 - 10,
                            child: TextField(
                              controller: _firstNameController,
                              style: const TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Όνομα',
                                hintStyle: TextStyle(
                                  color: Color.fromARGB(132, 156, 12, 4),
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                            child: VerticalDivider(
                              color: Color.fromARGB(204, 156, 12, 4),
                              thickness: 7,
                            ),
                          ),
                          Container(
                            height: 45,
                            width: (screenWidth - 60) / 2 - 10,
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: TextField(
                                controller: _lastNameController,
                                style: const TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Επίθετο',
                                  hintStyle: TextStyle(
                                    color: Color.fromARGB(132, 156, 12, 4),
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: screenWidth - 60,
                      child: const Divider(
                          height: 5,
                          color: Color.fromARGB(204, 156, 12, 4),
                          thickness: 7),
                    ),
                    SizedBox(
                      width: screenWidth - 60,
                      child: TextField(
                        controller: _userNameController,
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Username',
                          hintStyle: TextStyle(
                            color: Color.fromARGB(132, 156, 12, 4),
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: screenWidth - 60,
                      child: const Divider(
                          height: 5,
                          color: Color.fromARGB(204, 156, 12, 4),
                          thickness: 7),
                    ),
                    SizedBox(
                      width: screenWidth - 60,
                      child: TextField(
                        controller: _phoneController,
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Τηλέφωνο(+30)',
                          hintStyle: TextStyle(
                            color: Color.fromARGB(132, 156, 12, 4),
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: screenWidth - 60,
                      child: const Divider(
                          height: 5,
                          color: Color.fromARGB(204, 156, 12, 4),
                          thickness: 7),
                    ),
                    SizedBox(
                      width: screenWidth - 60,
                      child: TextField(
                        obscureText: false,
                        controller: _emailController,
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Email',
                          hintStyle: TextStyle(
                            color: Color.fromARGB(132, 156, 12, 4),
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: screenWidth - 60,
                      child: const Divider(
                          height: 5,
                          color: Color.fromARGB(204, 156, 12, 4),
                          thickness: 7),
                    ),
                    SizedBox(
                      width: screenWidth - 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: (screenWidth - 60) - 40,
                            child: TextField(
                              obscureText: _obscureText,
                              controller: _passwordController,
                              style: const TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Κωδικός',
                                hintStyle: TextStyle(
                                  color: Color.fromARGB(132, 156, 12, 4),
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 40,
                            child: IconButton(
                              onPressed: _togglePasswordVisibility,
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: const Color(0xFF9C0C04),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: screenWidth - 60,
                      child: const Divider(
                          height: 5,
                          color: Color.fromARGB(204, 156, 12, 4),
                          thickness: 7),
                    ),
                    SizedBox(
                      width: screenWidth - 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: (screenWidth - 60) - 40,
                            child: TextField(
                              obscureText: _obscureText2,
                              style: const TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Επιβεβαίωση κωδικού',
                                hintStyle: TextStyle(
                                  color: Color.fromARGB(132, 156, 12, 4),
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 40,
                            child: IconButton(
                              onPressed: _togglePasswordVisibility2,
                              icon: Icon(
                                _obscureText2
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: const Color(0xFF9C0C04),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 70,
                      width: screenWidth - 60,
                      child: Row(
                        children: [
                          const Text(
                            'Έχεις ήδη λογαριασμό; ',
                            style: TextStyle(
                              color: Color(0xFF9C0C04),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: _navigateToEmailLoginPage,
                            child: const Text(
                              'Συνδέσου',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Color(0xFF9C0C04)),
                    ),
                    backgroundColor: Colors.transparent,
                  ),
                  onPressed: () {
                    _register();
                  },
                  child: const Text(
                    'Εγγραφή',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
