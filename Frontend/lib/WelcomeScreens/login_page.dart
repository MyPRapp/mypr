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
  // ignore: unused_field
  final TextEditingController _serverController = TextEditingController();

  bool _obscureText = true;
  bool _isLoading = true; // Track overall loading state
  bool _isLoginPressed = false; // Track if login button is pressed

  @override
  void initState() {
    super.initState();
    _checkPreferencesLoaded();
  }

  Future<void> _checkPreferencesLoaded() async {
    final globalState = context.read<GlobalStateProvider>();

    // Wait until preferences are loaded
    while (!globalState.preferencesLoaded) {
      await Future.delayed(const Duration(milliseconds: 100)); // Small delay
    }

    // Now you can safely check if the user is authenticated
    _startSyncingClubs();
    _startSyncingUser();
  }

  Future<void> _startSyncingClubs() async {
    print('//////SYNCING CLUBS');
    await context.read<ClubProvider>().syncClubs();
    print('//////SYNCED CLUBS');
  }

  Future<void> _startSyncingUser() async {
    print('//////SYNCING USER');
    try {
      final globalState = context.read<GlobalStateProvider>();

      if (globalState.isAuthenticated) {
        print('USER AUTHENTICATED');
        UserProvider userProvider = context.read<UserProvider>();
        await _loadSavedUserCredentials();

        // Check if credentials exist before logging in
        if (_emailController.text.isNotEmpty &&
            _passwordController.text.isNotEmpty) {
          bool loginSuccess = await AuthService().login(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );

          // If login fails, stop here and don't proceed with fetching user details
          if (!loginSuccess) {
            print('Login failed, loading user details from preferences');
            await userProvider.loadUserDetailsFromPreferences();
          } else {
            // If login succeeds, fetch user details from server
            await userProvider.fetchUserDetailsFromServer();
          }
        } else {
          // If no credentials, load user details from preferences
          await userProvider.loadUserDetailsFromPreferences();
        }

        if (mounted) {
          context.read<BookingProvider>().fetchBookings(
              userProvider.userDetails, context.read<ClubProvider>());
        }

        // Navigate to the BottomNavBarRoute after syncing
        if (mounted) {
          context.router.replaceAll([const HomeRoute()]);
        }
      } else {
        print('USER NOT AUTHENTICATED');
        setState(() {
          _isLoading = false; // Stop loading and show login screen
        });
      }
      print('//////SYNCED USER');
    } catch (e) {
      print('Error during user syncing: $e');
      setState(() {
        _isLoading = false; // Stop loading and show login screen with error
      });
    }
  }

  Future<void> _login() async {
    if (_emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      setState(() {
        _isLoginPressed = true; // Start showing the loading indicator on button
      });

      try {
        // Attempt to log in using the provided credentials
        await AuthService().login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        _startSyncingClubs();

        // Check if the widget is still mounted before proceeding
        if (mounted) {
          // Fetch user details from the server if login was successful
          await context.read<UserProvider>().fetchUserDetailsFromServer();
        }
        if (mounted) {
          context.read<BookingProvider>().fetchBookings(
              context.read<UserProvider>().userDetails,
              context.read<ClubProvider>());
        }
        // Mark the user as authenticated if everything went well
        if (mounted) {
          context.read<GlobalStateProvider>().isAuthenticated = true;
        }

        if (mounted) {
          context.read<BottomNavBarVisibility>().show();
          await context.router.replaceAll([const BottomNavBarRoute()]);
        }
      } catch (e) {
        print('Login failed: $e');
        _handleLoginFailure();
      } finally {
        setState(() {
          _isLoginPressed =
              false; // Stop showing the loading indicator on button
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
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BottomNavBarVisibility>().hide();
      }
    });

    if (_isLoading) {
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

    return Scaffold(
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
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
              SizedBox(
                height: 70,
                width: screenWidth,
                child: const Image(
                  image: AssetImage('assets/otherPhotos/IMG_0041.jpg'),
                  fit: BoxFit.fitWidth,
                  alignment: Alignment(0, -0.3),
                ),
              ),
              const SizedBox(height: 25),
              const Image(
                image: AssetImage(
                    'assets/otherPhotos/Screenshot 2024-07-28 021714-Photoroom.png'),
              ),
              Container(
                width: screenWidth - 50,
                height: screenHeight / 2.5,
                padding: const EdgeInsets.all(2), // Add padding for the border
                decoration: BoxDecoration(
                  border: Border.all(
                      color: const Color(0xFF9C0C04),
                      width: 4), // Circular red border
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 30, top: 5),
                        child: Text(
                          'Είσοδος στην εφαρμογή',
                          style: TextStyle(
                            color: Color(0xFF9C0C04),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          TextField(
                            readOnly: _isLoginPressed,
                            controller: _emailController,
                            inputFormatters: [NoEmojisTextInputFormatter()],
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Email/Τηλέφωνο(+30)',
                              hintStyle: TextStyle(
                                color: Color.fromARGB(132, 156, 12, 4),
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                          const Divider(
                            height: 10,
                            color: Color.fromARGB(204, 156, 12, 4),
                            thickness: 7,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: TextField(
                                  readOnly: _isLoginPressed,
                                  controller: _passwordController,
                                  obscureText: _obscureText,
                                  keyboardType: TextInputType.text,
                                  autofillHints: const [AutofillHints.password],
                                  inputFormatters: [
                                    NoEmojisTextInputFormatter()
                                  ],
                                  style: const TextStyle(
                                    fontSize: 18,
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
                              IconButton(
                                onPressed: _togglePasswordVisibility,
                                icon: Icon(
                                  _obscureText
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: const Color(0xFF9C0C04),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.start,
                          //   children: [
                          //     const Text(
                          //       'Ξέχασες τον κωδικό;',
                          //       style: TextStyle(
                          //         color: Color(0xFF9C0C04),
                          //         fontSize: 14,
                          //         fontWeight: FontWeight.bold,
                          //       ),
                          //     ),
                          //     TextButton(
                          //       onPressed: () {
                          //         if (!_isLoginPressed) {
                          //           floatingSnackBar(
                          //               message:
                          //                   'Στάλθηκε email για επαναφορά κωδικού',
                          //               context: context,
                          //               duration:
                          //                   const Duration(milliseconds: 1500));
                          //         }
                          //       },
                          //       child: const Text(
                          //         'Επαναφορά κωδικού',
                          //         style: TextStyle(
                          //           color: Colors.white,
                          //           fontSize: 14,
                          //           fontWeight: FontWeight.w900,
                          //         ),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: TextButton(
                              onPressed: () {
                                if (!_isLoginPressed) {
                                  context.router
                                      .replaceAll([const SignUpRoute()]);
                                }
                              },
                              child: const Text(
                                'Δημιουργία λογαριασμού',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 50),
              Column(
                children: [
                  _isLoginPressed
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF9C0C04)), // Red color indicator
                        )
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: const BorderSide(color: Color(0xFF9C0C04)),
                            ),
                            backgroundColor: const Color.fromARGB(139, 0, 0, 0),
                          ),
                          onPressed: _login,
                          child: const Text(
                            'Είσοδος',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: SizedBox(
                      width: 350,
                      child: Column(
                        children: [
                          TextField(
                            controller: _serverController,
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 13, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side:
                                    const BorderSide(color: Color(0xFF9C0C04)),
                              ),
                              backgroundColor: Colors.black,
                            ),
                            onPressed: () {
                              String serverIp = _serverController.text.trim();
                              if (serverIp.isNotEmpty) {
                                final globalState =
                                    context.read<GlobalStateProvider>();
                                globalState.validatedIp = serverIp;
                                // Trigger data fetching if necessary
                                _startSyncingClubs();
                                _startSyncingUser();
                              }
                              print(
                                  'Connecting to server at: http://${GlobalStateProvider().validatedIp}:8000/');

                              floatingSnackBar(
                                  message:
                                      'Connecting to server at: http://${GlobalStateProvider().validatedIp}:8000/',
                                  context: context,
                                  duration: const Duration(milliseconds: 1500));
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
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
