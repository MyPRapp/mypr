import 'package:auto_route/auto_route.dart';
import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:mypr/Providers/booking_provider.dart';
import 'package:mypr/Providers/global_state_provider.dart';
import 'package:mypr/routes/app_router.gr.dart';
import 'package:mypr/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Providers/club_provider.dart';
import '../Providers/user_provider.dart';
import '../global_components.dart';

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
    _checkPreferencesLoaded();
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _serverController.dispose();
  }

  Future<void> _checkPreferencesLoaded() async {
    if (!mounted) {
      return;
    }
    final globalState = context.read<GlobalStateProvider>();

    while (!globalState.preferencesLoaded) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    print('Preferences loaded');

    await _startSyncingClubs();
    _startSyncingUser();
  }

  Future<void> _startSyncingClubs() async {
    print('//////SYNCING CLUBS');
    if (mounted) {
      await context.read<ClubProvider>().syncClubs();
    }
    print('//////SYNCED CLUBS');
  }

  Future<void> _startSyncingUser() async {
    print('//////SYNCING USER');
    if (!mounted) {
      return;
    }
    try {
      final globalState = context.read<GlobalStateProvider>();

      if (globalState.isAuthenticated) {
        print('USER AUTHENTICATED');
        UserProvider userProvider = context.read<UserProvider>();
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
            print('Login failed, loading user details from preferences');
            await userProvider.loadUserDetailsFromPreferences();
          }
        } else {
          await userProvider.loadUserDetailsFromPreferences();
        }
        if (mounted) {
          context.read<BookingProvider>().fetchBookings(
              userProvider.userDetails, context.read<ClubProvider>());
        }

        if (mounted) {
          context.read<BottomNavBarVisibility>().show();
          context.router.replaceAll([const BottomNavBarRoute()]);
        }
      } else {
        print('USER NOT AUTHENTICATED');
        setState(() {
          _isLoading = false;
        });
      }
      print('//////SYNCED USER');
    } catch (e) {
      print('Error during user syncing: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _login() async {
    if (_emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      setState(() {
        _isLoginPressed = true;
      });

      try {
        bool success = await AuthService().login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        _startSyncingClubs();
        if (success) {
          if (mounted) {
            await context.read<UserProvider>().fetchUserDetailsFromServer();
          }
          if (mounted) {
            context.read<BookingProvider>().fetchBookings(
                context.read<UserProvider>().userDetails,
                context.read<ClubProvider>());
          }
          if (mounted) {
            context.read<GlobalStateProvider>().isAuthenticated = true;
          }

          if (mounted) {
            context.read<BottomNavBarVisibility>().show();
            await context.router.replaceAll([const BottomNavBarRoute()]);
          }
        }
      } catch (e) {
        print('Login failed: $e');
        _handleLoginFailure();
      } finally {
        setState(() {
          _isLoginPressed = false;
        });
      }
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

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Color(0xFF9C0C04)],
          begin: Alignment.center,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          //HEADER: TOP PICTURE AND LOGO PICTURE
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              LoginHeader(
                screenWidth: screenWidth,
                screenHeight: screenHeight,
              ),
              LoginLogo(screenHeight: screenHeight),
            ],
          ),
          //LOGIN FORM AND LOGIN BUTTON
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                LoginForm(
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  emailController: emailController,
                  passwordController: passwordController,
                  obscureText: obscureText,
                  isLoginPressed: isLoginPressed,
                  onTogglePasswordVisibility: onTogglePasswordVisibility,
                ),
                LoginFooter(
                  isLoginPressed: isLoginPressed,
                  onLogin: onLogin,
                  serverController: serverController,
                ),
                SizedBox(height: screenHeight / 100)
              ],
            ),
          ),
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
      height: screenHeight / 15, // Set the height to screenHeight / 15
      width: screenWidth, // Full width
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white, // Opaque at the top
              Color.fromARGB(0, 0, 0, 0), // Fully transparent at the bottom
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

class LoginForm extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscureText;
  final bool isLoginPressed;
  final VoidCallback onTogglePasswordVisibility;

  const LoginForm({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.emailController,
    required this.passwordController,
    required this.obscureText,
    required this.isLoginPressed,
    required this.onTogglePasswordVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: screenWidth * 0.90,
      height: screenHeight / 2.5,
      decoration: BoxDecoration(
        border: Border.all(
            color: const Color(0xFF9C0C04),
            width: screenHeight * screenWidth * 0.00001),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding:
            EdgeInsets.only(left: screenWidth / 20, right: screenWidth / 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              height: screenHeight / 100,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                LoginTextField(
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  controller: emailController,
                  hintText: 'Email/Τηλέφωνο(+30)',
                  isLoginPressed: isLoginPressed,
                ),
                Divider(
                  height: screenHeight * 0.001,
                  color: const Color.fromARGB(204, 156, 12, 4),
                  thickness: screenHeight * 0.005,
                ),
                Row(
                  children: [
                    Expanded(
                      child: LoginTextField(
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        controller: passwordController,
                        hintText: 'Κωδικός',
                        isObscure: obscureText,
                        isLoginPressed: isLoginPressed,
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
              ],
            ),
            ForgotPasswordAndSignUp(
                isLoginPressed: isLoginPressed,
                screenHeight: screenHeight,
                screenWidth: screenWidth),
          ],
        ),
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
    return TextField(
      readOnly: isLoginPressed,
      controller: controller,
      obscureText: isObscure,
      style: TextStyle(
        fontSize: screenHeight * screenWidth * 0.000052,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: screenHeight * screenWidth * 0.000052,
          fontWeight: FontWeight.w600,
          color: const Color.fromARGB(132, 156, 12, 4),
        ),
        border: InputBorder.none,
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
    return SizedBox(
      height: screenHeight * 0.1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: screenWidth * 0.9 - screenWidth / 10,
            height: screenHeight * 0.05,
            child: Row(
              children: [
                SizedBox(
                  width: screenWidth * 0.02,
                ),
                Text(
                  'Ξέχασες τον κωδικό;',
                  style: TextStyle(
                    color: const Color(0xFF9C0C04),
                    fontSize: (screenWidth * 0.02) + (screenHeight * 0.0035),
                    fontWeight: FontWeight.w700,
                  ),
                ),
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
                      fontSize: (screenWidth * 0.02) + (screenHeight * 0.0035),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: screenHeight * 0.05,
            child: TextButton(
              onPressed: () {
                if (!isLoginPressed) {
                  context.router.replaceAll([const SignUpRoute()]);
                }
              },
              child: Text(
                'Δημιουργία λογαριασμού',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: (screenWidth * 0.02) + (screenHeight * 0.0035),
                  fontWeight: FontWeight.w700,
                ),
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
  final TextEditingController serverController;

  const LoginFooter({
    super.key,
    required this.isLoginPressed,
    required this.onLogin,
    required this.serverController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        isLoginPressed
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9C0C04)),
              )
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: //TODO Change dimensions of button
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: Color(0xFF9C0C04)),
                  ),
                  backgroundColor: const Color.fromARGB(139, 0, 0, 0),
                ),
                onPressed: onLogin,
                child: const Icon(
                  Icons.keyboard_arrow_right,
                  color: Colors.red,
                )),
        // Padding(
        //   padding: const EdgeInsets.only(top: 10),
        //   child: ServerInputField(
        //     serverController: serverController,
        //   ),
        // ),
      ],
    );
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
                  'Connecting to server at: http://${globalState.validatedIp}:8000/');
              floatingSnackBar(
                message:
                    'Connecting to server at: http://${globalState.validatedIp}:8000/',
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
