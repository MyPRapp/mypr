import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mypr/routes/app_router.gr.dart';

@RoutePage()
class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _navigateToMainApp() {
    context.router.replaceAll([const BottomNavBarRoute()]);
  }

  void _navigateToSignUpPage() {
    context.router.replaceAll([const SignUpRoute()]);
  }

  void _navigateToEmailLoginPage() {
    context.router.replaceAll([const EmailLoginRoute()]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
            SizedBox(
              width: 420,
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
                  const SizedBox(
                    width: 420,
                    child: TextField(
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
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
                    width: 420,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 350,
                          child: TextField(
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
                    padding: const EdgeInsets.only(top: 30),
                    child: SizedBox(
                      width: 420,
                      child: Row(children: [
                        const Text(
                          '  Ξέχασες τον κωδικό;',
                          style: TextStyle(
                            color: Color(0xFF9C0C04),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Επαναφορά κωδικού',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
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
                        fontSize: 17,
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
                        fontSize: 17,
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
                _navigateToMainApp();
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
            const SizedBox(height: 200)
          ],
        ),
      ),
    );
  }
}
