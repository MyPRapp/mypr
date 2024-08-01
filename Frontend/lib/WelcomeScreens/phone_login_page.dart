import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mypr/OtherPages/global_state.dart';
import 'package:mypr/routes/app_router.gr.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';

@RoutePage()
class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  Future<void> _login(BuildContext context) async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    bool success = await _authService.login(email, password);

    if (success) {
      // ignore: use_build_context_synchronously
      context.router.replaceAll([const BottomNavBarRoute()]);
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Λάθος κινητό ή κωδικός')),
      );
    }
  }

  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _navigateToSignUpPage() {
    context.router.replaceAll([const SignUpRoute()]);
  }

  void _navigateToEmailLoginPage() {
    context.router.replaceAll([const EmailLoginRoute()]);
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BottomNavBarVisibility>().hide();
    });
    return Scaffold(
        body: SingleChildScrollView(
      child: Container(
        height: screenHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF9C0C04)],
            begin: Alignment.center,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: 80,
              width: screenWidth,
              child: const Image(
                image: AssetImage('assets/clubPhotos/IMG_0041.jpg'),
                fit: BoxFit.fitWidth,
                alignment: Alignment(0, -0.3),
              ),
            ),
            const Image(
              image: AssetImage(
                  'assets/clubPhotos/Screenshot 2024-07-28 021714-Photoroom.png'),
            ),
            SizedBox(
              width: screenWidth - 50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Text(
                      'Είσοδος στην εφαρμογή',
                      style: TextStyle(
                        color: Color(0xFF9C0C04),
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: screenWidth - 50,
                    child: TextField(
                      controller: _emailController,
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
                  const SizedBox(
                    width: 420,
                    child: Divider(
                      height: 10,
                      color: Color.fromARGB(204, 156, 12, 4),
                      thickness: 7,
                    ),
                  ),
                  SizedBox(
                    width: screenWidth - 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: screenWidth - 100,
                          child: TextField(
                            controller: _passwordController,
                            obscureText: _obscureText,
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
                          width: 50,
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
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: SizedBox(
                      child: Row(children: [
                        const Text(
                          '  Ξέχασες τον κωδικό;',
                          style: TextStyle(
                            color: Color(0xFF9C0C04),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Στάλθηκε email για επαναφορά κωδικού')),
                            );
                          },
                          child: const Text(
                            'Επαναφορά κωδικού',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        )
                      ]),
                    ),
                  ),
                  TextButton(
                    onPressed: _navigateToEmailLoginPage,
                    child: const Text(
                      'Σύνδεση με email',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _navigateToSignUpPage,
                    child: const Text(
                      'Δημιουργία λογαριασμού',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  )
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Color(0xFF9C0C04))),
                backgroundColor: Colors.black,
              ),
              onPressed: () {
                // _login(context);
                context.router.replaceAll([const BottomNavBarRoute()]);
              },
              child: const Text(
                'Είσοδος',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 100)
          ],
        ),
      ),
    ));
  }
}
