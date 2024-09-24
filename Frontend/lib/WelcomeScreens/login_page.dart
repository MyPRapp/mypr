import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:mypr/Providers/booking_provider.dart';
import 'package:mypr/Providers/global_state_provider.dart';
import 'package:mypr/routes/app_router.gr.dart';
import 'package:mypr/services/auth_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final TextEditingController _serverController = TextEditingController();

  bool _obscureText = true;
  bool _isLoading = true;
  bool _isLoginPressed = false;

  @override
  void initState() {
    super.initState();

    _initializeApp();
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _serverController.dispose();
  }

  Future<void> _initializeApp() async {
    await createFilePath();
    if (mounted) {
      context.read<ClubProvider>().loadClubsFromFile();
      await context.read<ClubProvider>().loadCataloguesFromFile();

      if (mounted) {
        final globalState = context.read<GlobalStateProvider>();
        while (!globalState.preferencesLoaded) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }
    }
    print('\x1B[32mGlobal state preferences loaded');

    if (mounted) {
      if (context.read<GlobalStateProvider>().isAuthenticated) {
        print('\x1B[32m------------USER AUTHENTICATED------------');

        _startSyncingClubs();
        _startSyncingUser();
      } else {
        print('\x1B[31m------------USER NOT AUTHENTICATED------------');
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> createFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    final Directory myprDirectory = Directory('${directory.path}/mypDirectory');

    // Create the new folder if it doesn't exist
    if (await myprDirectory.exists() == false) {
      await myprDirectory.create(recursive: true);
      print('\x1B[32mFolder created: ${myprDirectory.path}');
    } else {
      print('\x1B[32mFolder ${myprDirectory.path} already exists');
    }
  }

  Future<void> _startSyncingClubs() async {
    print('\x1B[33m------------SYNCING CLUBS------------');
    await context.read<ClubProvider>().syncClubs();
    print('\x1B[32m------------SYNCED CLUBS------------');
  }

  Future<void> _startSyncingUser() async {
    print('\x1B[33m------------SYNCING USER------------');

    UserProvider userProvider = context.read<UserProvider>();
    await userProvider.loadUserDetailsFromPreferences();
    if (mounted) {
      context.read<BottomNavBarVisibility>().show();
      context.router.replaceAll([const BottomNavBarRoute()]);
    }

    await _loadSavedUserCredentials();

    if (_emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      bool loginSuccess = await AuthService().login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (loginSuccess) {
        await userProvider.fetchUserDetailsFromServer();
      } else {
        print('\x1B[31mLogin failed, loading user details from preferences');
        await userProvider.loadUserDetailsFromPreferences();
      }
      if (mounted) {
        await context.read<BookingProvider>().fetchBookings(
            userProvider.userDetails, context.read<ClubProvider>());
      }
    }
    print('\x1B[32m------------SYNCED USER------------');
  }

  Future<void> _login() async {
    if (_emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
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
          floatingSnackBar(
              message: 'Επιτυχής σύνδεση',
              context: context,
              duration: const Duration(milliseconds: 4000));
        }
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
    } else {
      floatingSnackBar(
          message: 'Παρακαλώ συμπλήρωσε όλα τα πεδία',
          context: context,
          duration: const Duration(milliseconds: 4000));
    }
  }

  Future<void> _loadSavedUserCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedEmail = prefs.getString('saved_email');
    String? savedPassword = prefs.getString('saved_password');

    if (savedEmail != null && savedPassword != null) {
      setState(() {
        _emailController.text = savedEmail;
        _passwordController.text = savedPassword;
      });
    }
  }

  void _handleLoginFailure() {
    if (_emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      floatingSnackBar(
          message: 'Λάθος email/τηλέφωνο ή κωδικός',
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
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final double screenWidth = MediaQuery.sizeOf(context).width;

    if (_isLoading) {
      return const LoadingScreen();
    }

    return PopScope(
      canPop: false,
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: LoginBody(
            screenHeight: screenHeight,
            screenWidth: screenWidth,
            isLoginPressed: _isLoginPressed,
            emailController: _emailController,
            passwordController: _passwordController,
            serverController: _serverController,
            obscureText: _obscureText,
            onLogin: _login,
            onTogglePasswordVisibility: _togglePasswordVisibility,
          ),
        ),
      ),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

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
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9C0C04)),
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
  final TextEditingController serverController;
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
    required this.serverController,
    required this.obscureText,
    required this.onLogin,
    required this.onTogglePasswordVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: screenHeight,
      width: screenWidth,
      color: Colors.black,
      child: ListView(
        children: [
          LoginLogo(screenHeight: screenHeight),
          SizedBox(height: screenHeight / 10),
          Column(
            children: [
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
                    color: const Color.fromARGB(133, 168, 168, 168)),
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
            ],
          ),
          SizedBox(height: screenHeight / 10),
          LoginFooter(
            screenHeight: screenHeight,
            screenWidth: screenWidth,
            isLoginPressed: isLoginPressed,
            onLogin: onLogin,
            serverController: serverController,
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

class LoginHeader extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;

  const LoginHeader({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: screenHeight / 12, // Set the height to screenHeight / 15
      width: screenWidth, // Full width
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white, // Opaque at the top
              Color.fromARGB(14, 0, 0, 0), // Fully transparent at the bottom
            ],
            stops: [0.4, 1], // Control where the fade starts and ends
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn, // Blend mode to mask the image
        child: const Image(
          image: AssetImage('assets/otherPhotos/IMG_0041.jpg'),
          fit: BoxFit.fitWidth, // Make sure the image fits the width
        ),
      ),
    );
  }
}

class LoginLogo extends StatelessWidget {
  final double screenHeight;
  const LoginLogo({super.key, required this.screenHeight});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: screenHeight / 5,
      child: const Image(
        image: AssetImage(
            'assets/otherPhotos/Screenshot 2024-07-28 021714-Photoroom.png'),
        fit: BoxFit.scaleDown,
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
          color: const Color.fromARGB(133, 168, 168, 168)),
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton(
          onPressed: () {
            if (!isLoginPressed) {
              floatingSnackBar(
                  message: 'Στάλθηκε email για επαναφορά κωδικού',
                  context: context,
                  duration: const Duration(milliseconds: 1500));
            }
          },
          child: Text(
            'Επαναφορά κωδικού',
            style: TextStyle(
              color: Colors.white,
              fontSize: (screenWidth * 0.025) + (screenHeight * 0.0038),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            if (!isLoginPressed) {
              context.router.replaceAll([const SignUpRoute()]);
            }
          },
          child: Text(
            'Δημιουργία λογαριασμού',
            style: TextStyle(
              color: Colors.white,
              fontSize: (screenWidth * 0.025) + (screenHeight * 0.0038),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class LoginFooter extends StatelessWidget {
  final bool isLoginPressed;
  final VoidCallback onLogin;
  final TextEditingController serverController;
  final double screenWidth;
  final double screenHeight;
  const LoginFooter({
    super.key,
    required this.isLoginPressed,
    required this.onLogin,
    required this.serverController,
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

class ServerInputField extends StatelessWidget {
  final TextEditingController serverController;

  const ServerInputField({super.key, required this.serverController});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: serverController,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          decoration: const InputDecoration(
            hintText: 'Enter server\'s IP',
            hintStyle: TextStyle(color: Colors.black),
            border: InputBorder.none,
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Divider(
            height: 10,
            color: Color.fromARGB(204, 156, 12, 4),
            thickness: 7,
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFF9C0C04)),
            ),
            backgroundColor: Colors.black,
          ),
          onPressed: () {
            String serverIp = serverController.text.trim();
            if (serverIp.isNotEmpty) {
              final globalState = context.read<GlobalStateProvider>();
              globalState.validatedIp = serverIp;
              print(
                  '\x1B[33mConnecting to server at: http://${globalState.validatedIp}/');
              floatingSnackBar(
                message:
                    'Connecting to server at: http://${globalState.validatedIp}/',
                context: context,
                duration: const Duration(milliseconds: 1500),
              );
            }
          },
          child: const Text(
            'Connect to server',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
