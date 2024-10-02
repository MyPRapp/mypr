import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:mypr/Providers/booking_provider.dart';
import 'package:mypr/Providers/global_state_provider.dart';
import 'package:mypr/routes/app_router.gr.dart';
import 'package:mypr/services/auth_service.dart';
import 'package:provider/provider.dart';

import '../Navigation/bottom_nav_bar.dart';
import '../Providers/club_provider.dart';
import '../Providers/user_provider.dart';

@RoutePage()
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscureText = true;
  bool _isLoginPressed = false;
  Future<void> _startSyncingClubs() async {
    await context.read<ClubProvider>().syncClubs();
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      FocusManager.instance.primaryFocus?.unfocus();
      floatingSnackBar(
          message: 'Παρακαλώ συμπλήρωσε όλα τα πεδία',
          context: context,
          duration: const Duration(milliseconds: 4000));
      return;
    } else {
      print('\x1B[32m------------LOGGING IN------------');
      setState(() {
        _isLoginPressed = true;
      });
      bool success = false;

      success = await AuthService().login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (success) {
        if (mounted) {
          await context.read<UserProvider>().fetchUserDetailsFromServer();
        }
        if (mounted) {
          context.read<BottomNavBarVisibility>().show();
          await context.router.replaceAll([const BottomNavBarRoute()]);
        }
        _startSyncingClubs();

        if (mounted) {
          context.read<GlobalStateProvider>().isAuthenticated = true;
        }
        if (mounted) {
          context.read<BookingProvider>().fetchBookings(
              context.read<UserProvider>().userDetails,
              context.read<ClubProvider>());
        }

        print('\x1B[32m------------LOGGED IN------------');
      } else {
        _handleLoginFailure();
        print('\x1B[31m------------LOGIN FAILED------------');
      }
      setState(() {
        _isLoginPressed = false;
      });
    }
  }

  void _handleLoginFailure() {
    if (_emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      FocusManager.instance.primaryFocus?.unfocus();
      floatingSnackBar(
          message: 'Λάθος στοιχεία εισόδου',
          context: context,
          duration: const Duration(milliseconds: 4000));
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final double screenWidth = MediaQuery.sizeOf(context).width;
    return PopScope(
      canPop: false,
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          backgroundColor: Colors.black,
          resizeToAvoidBottomInset: false,
          body: LoginBody(
            screenHeight: screenHeight,
            screenWidth: screenWidth,
            isLoginPressed: _isLoginPressed,
            emailController: _emailController,
            passwordController: _passwordController,
            obscureText: _obscureText,
            onLogin: _login,
            onTogglePasswordVisibility: _togglePasswordVisibility,
          ),
        ),
      ),
    );
  }
}

class LoginBody extends StatelessWidget {
  final double screenHeight;
  final double screenWidth;
  final bool isLoginPressed;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscureText;
  final VoidCallback onLogin;
  final VoidCallback onTogglePasswordVisibility;

  const LoginBody({
    super.key,
    required this.screenHeight,
    required this.screenWidth,
    required this.isLoginPressed,
    required this.emailController,
    required this.passwordController,
    required this.obscureText,
    required this.onLogin,
    required this.onTogglePasswordVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: screenWidth,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Color.fromARGB(150, 156, 12, 4)],
          begin: Alignment.centerRight,
          end: Alignment.topLeft,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                    top: screenHeight * 0.08, bottom: screenHeight * 0.05),
                child: LoginLogo(
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  text: '',
                  color: Colors.white,
                ),
              ),
              LoginTextField(
                screenHeight: screenHeight,
                screenWidth: screenWidth,
                controller: emailController,
                hintText: 'Email/Τηλέφωνο(+30)',
                isLoginPressed: isLoginPressed,
              ),
              SizedBox(height: screenHeight * 0.02),
              Container(
                width: screenWidth * 0.85,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color.fromARGB(133, 84, 84, 84)),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        readOnly: isLoginPressed,
                        controller: passwordController,
                        obscureText: obscureText,
                        cursorColor: const Color.fromARGB(125, 244, 67, 54),
                        style: TextStyle(
                          fontSize: screenHeight * screenWidth * 0.000052,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(screenWidth * 0.02),
                          hintText: 'Κωδικός',
                          hintStyle: TextStyle(
                            fontSize: screenHeight * screenWidth * 0.000052,
                            fontWeight: FontWeight.w600,
                            color: const Color.fromARGB(132, 199, 199, 199),
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onTogglePasswordVisibility,
                      icon: Icon(
                        size: screenHeight * 0.03,
                        obscureText ? Icons.visibility_off : Icons.visibility,
                        color: const Color(0xFF9C0C04),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
              LoginFooter(
                screenHeight: screenHeight,
                screenWidth: screenWidth,
                isLoginPressed: isLoginPressed,
                onLogin: onLogin,
              ),
            ],
          ),
          ForgotPasswordAndSignUp(
              isLoginPressed: isLoginPressed,
              screenHeight: screenHeight,
              screenWidth: screenWidth),
        ],
      ),
    );
  }
}

class LoginLogo extends StatelessWidget {
  final double screenHeight;
  final double screenWidth;
  final String text;
  final Color color;
  const LoginLogo(
      {super.key,
      required this.screenHeight,
      required this.screenWidth,
      required this.text,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: screenWidth,
      height: screenHeight / 5,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: (screenHeight / 5) / 5.5,
              child: Text(
                text,
                style: TextStyle(
                    color: color, fontSize: 21, fontWeight: FontWeight.w900),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: (screenHeight / 5) / 5.5),
            child: SizedBox(
              width: screenWidth,
              height: screenHeight / 10,
              child: const Image(
                alignment: Alignment.center,
                image: AssetImage(
                    'assets/otherPhotos/Logo_v2.2-removebg(cropped).png'),
                fit: BoxFit.scaleDown,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LoginTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isObscure;
  final bool isLoginPressed;
  final double screenHeight;
  final double screenWidth;

  const LoginTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.isLoginPressed,
    required this.screenHeight,
    required this.screenWidth,
    this.isObscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: screenWidth * 0.85,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: const Color.fromARGB(133, 84, 84, 84)),
      child: TextField(
        readOnly: isLoginPressed,
        controller: controller,
        obscureText: isObscure,
        cursorColor: const Color.fromARGB(125, 244, 67, 54),
        style: TextStyle(
          fontSize: screenHeight * screenWidth * 0.000052,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(screenWidth * 0.02),
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: screenHeight * screenWidth * 0.000052,
            fontWeight: FontWeight.w600,
            color: const Color.fromARGB(132, 199, 199, 199),
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class ForgotPasswordAndSignUp extends StatelessWidget {
  final bool isLoginPressed;
  final double screenWidth;
  final double screenHeight;
  const ForgotPasswordAndSignUp({
    super.key,
    required this.isLoginPressed,
    required this.screenHeight,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: screenHeight * 0.05),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: screenWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Πρώτη φορά εδώ;',
                  style: TextStyle(
                    color: const Color.fromARGB(104, 255, 255, 255),
                    fontSize: screenHeight * screenWidth * 0.000045,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (!isLoginPressed) {
                      AutoRouter.of(context).replaceAll([const SignUpRoute()]);
                    }
                  },
                  child: Text(
                    'Κάνε εγγραφή',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      decorationColor: const Color.fromARGB(200, 255, 255, 255),
                      color: Colors.white,
                      fontSize: (screenWidth * 0.01) + (screenHeight * 0.012),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: screenWidth,
            child: Text(
              textAlign: TextAlign.center,
              'ή',
              style: TextStyle(
                color: const Color.fromARGB(200, 255, 255, 255),
                fontSize: screenHeight * screenWidth * 0.000052,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              if (!isLoginPressed) {
                floatingSnackBar(
                    message: 'Στάλθηκε email για επαναφορά κωδικού',
                    context: context,
                    duration: const Duration(milliseconds: 4000));
              }
            },
            child: Text(
              'Επαναφορά κωδικού',
              style: TextStyle(
                decoration: TextDecoration.underline,
                decorationColor: const Color.fromARGB(157, 255, 255, 255),
                color: Colors.white,
                fontSize: (screenWidth * 0.01) + (screenHeight * 0.012),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LoginFooter extends StatelessWidget {
  final bool isLoginPressed;
  final VoidCallback onLogin;
  final double screenWidth;
  final double screenHeight;
  const LoginFooter({
    super.key,
    required this.isLoginPressed,
    required this.onLogin,
    required this.screenHeight,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor:
              isLoginPressed ? Colors.transparent : const Color(0xFF9C0C04),
        ),
        onPressed: onLogin,
        child: isLoginPressed
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9C0C04)),
              )
            : const Icon(
                Icons.arrow_forward,
                color: Colors.black,
              ));
  }
}
