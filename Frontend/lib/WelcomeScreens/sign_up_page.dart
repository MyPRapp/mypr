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

  _register() async {
    String username = _userNameController.text.trim();
    String password = _passwordController.text.trim();
    String email = _emailController.text.trim();
    String lastName = _lastNameController.text.trim();
    String firstName = _firstNameController.text.trim();
    String phone = _phoneController.text.trim();
    bool success = await _authService.register(
        username, password, firstName, lastName, email, phone);
    if (success) {
      // ignore: use_build_context_synchronously
      context.router.replaceAll([const BottomNavBarRoute()]);
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed')),
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

  void _navigateToPhoneLoginPage() {
    context.router.replaceAll([const EmailLoginRoute()]);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BottomNavBarVisibility>().hide();
    });
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        width: 500,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 60,
                width: double.maxFinite,
                child: Image(
                  image: AssetImage('assets/clubPhotos/IMG_0041.jpg'),
                  fit: BoxFit.fitWidth,
                  alignment: Alignment(0, -0.3),
                ),
              ),
              const Image(
                image: AssetImage(
                    'assets/clubPhotos/Screenshot 2024-07-28 021714-Photoroom.png'),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(
                  child: Text(
                    'Δημιουργία λογαριασμού',
                    style: TextStyle(
                      color: Color(0xFF9c0c04),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 50,
                  width: 400,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: 50,
                        width: 190,
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
                            )),
                      ),
                      const SizedBox(
                        width: 20,
                        child: VerticalDivider(
                          color: Color.fromARGB(204, 156, 12, 4),
                          thickness: 7,
                        ),
                      ),
                      Container(
                        height: 50,
                        width: 190,
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
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 400,
                  child: Divider(
                      height: 10,
                      color: Color.fromARGB(204, 156, 12, 4),
                      thickness: 7),
                ),
                SizedBox(
                  width: 400,
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
                      )),
                ),
                const SizedBox(
                  width: 400,
                  child: Divider(
                      height: 10,
                      color: Color.fromARGB(204, 156, 12, 4),
                      thickness: 7),
                ),
                SizedBox(
                  width: 400,
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
                      )),
                ),
                const SizedBox(
                  width: 400,
                  child: Divider(
                      height: 10,
                      color: Color.fromARGB(204, 156, 12, 4),
                      thickness: 7),
                ),
                SizedBox(
                  width: 400,
                  child: TextField(
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
                      )),
                ),
                const SizedBox(
                  width: 400,
                  child: Divider(
                      height: 10,
                      color: Color.fromARGB(204, 156, 12, 4),
                      thickness: 7),
                ),
                SizedBox(
                  width: 400,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 300,
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
                            )),
                      ),
                      SizedBox(
                        child: IconButton(
                          onPressed: _togglePasswordVisibility,
                          icon: const Icon(
                            Icons.visibility_off_rounded,
                            color: Color(0xFF9C0C04),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 400,
                  child: Divider(
                      height: 10,
                      color: Color.fromARGB(204, 156, 12, 4),
                      thickness: 7),
                ),
                SizedBox(
                  width: 400,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 300,
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
                            )),
                      ),
                      SizedBox(
                        child: IconButton(
                          onPressed: _togglePasswordVisibility2,
                          icon: const Icon(
                            Icons.visibility_off_rounded,
                            color: Color(0xFF9C0C04),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 100,
                  width: 400,
                  child: Row(children: [
                    const Text(
                      'Έχεις ήδη λογαριασμό; ',
                      style: TextStyle(
                        color: Color(0xFF9C0C04),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: _navigateToPhoneLoginPage,
                      child: const Text(
                        'Συνδέσου',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    )
                  ]),
                ),
              ]),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
              const SizedBox(
                height: 20,
              ),
              const SizedBox(
                height: 60,
                width: double.maxFinite,
                child: Image(
                  image: AssetImage('assets/clubPhotos/IMG_0041.jpg'),
                  fit: BoxFit.fitWidth,
                  alignment: Alignment(0, -0.3),
                ),
              ),
            ]),
      ),
    );
  }
}
