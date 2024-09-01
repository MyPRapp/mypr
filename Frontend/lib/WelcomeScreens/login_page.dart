import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mypr/Providers/global_state_provider.dart';
import 'package:mypr/routes/app_router.gr.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Providers/club_provider.dart';
import '../Providers/user_provider.dart';
import '../global_components.dart';
import '../services/auth_service.dart';

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
  final AuthService _authService = AuthService();
  bool _obscureText = true;
  bool? _loginFailed;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadSavedUserCredentials();
    _login();
    _checkAndFetchClubs();
  }

  void _startTimeout() {
    Future.delayed(const Duration(seconds: 3), () {
      if (_loginFailed == null) {
        setState(() {
          _loginFailed = true;
        });
      }
    });
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

  Future<void> _checkAndFetchClubs() async {
    final globalState = context.read<GlobalStateProvider>();
    if (!globalState.dataLoaded) {
      await _fetchClubsAndCatalogues();
      if (mounted) {
        globalState.setDataLoaded(true);
      }
    }
  }

  Future<void> _fetchClubsAndCatalogues() async {
    ClubProvider clubProvider = context.read<ClubProvider>();
    await clubProvider.fetchClubsAndCatalogues();
  }

  Future<void> _login() async {
    // context.router.replaceAll([const BottomNavBarRoute()]);
    setState(() {
      _loginFailed = null; // Reset the login status to trigger the indicator
    });
    _startTimeout(); // Start the timeout again
    final globalState = context.read<GlobalStateProvider>();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    bool success = await _authService.login(email, password);

    if (mounted) {
      setState(() {
        _loginFailed = !success;
      });
      if (success) {
        await context.read<UserProvider>().syncUserDetails();
        if (globalState.dataLoaded) {
          await _fetchClubsAndCatalogues();
        }
        if (mounted) {
          context.router.replaceAll([const BottomNavBarRoute()]);
        }
      } else {
        if (_emailController.text.isNotEmpty &&
            _passwordController.text.isNotEmpty) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                duration: Duration(seconds: 4),
                content: Text('Λάθος email/τηλέφωνο ή κωδικός'),
              ),
            );
        }
      }
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _navigateToSignUpPage() {
    if (mounted) {
      context.router.replaceAll([const SignUpRoute()]);
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

    // Display the gradient background with a red loading indicator in the middle
    if (_loginFailed == null || _loginFailed == false) {
      if (_loginFailed != false) {
        _startTimeout();
        _loginFailed == true;
      }
      return PopScope(
        canPop: false,
        child: Scaffold(
          body: Container(
            height: screenHeight,
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
        ),
      );
    }
    // If login fails, show the login form
    else {
      return Scaffold(
        body: Container(
          height: screenHeight,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Color(0xFF9C0C04)],
              begin: Alignment.center,
              end: Alignment.bottomCenter,
            ),
          ),
          child: ListView(children: [
            Column(
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
                  padding:
                      const EdgeInsets.all(2), // Add padding for the border
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
                                    controller: _passwordController,
                                    obscureText: _obscureText,
                                    keyboardType: TextInputType.text,
                                    autofillHints: const [
                                      AutofillHints.password
                                    ],
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text(
                                  'Ξέχασες τον κωδικό;',
                                  style: TextStyle(
                                    color: Color(0xFF9C0C04),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context)
                                      ..hideCurrentSnackBar()
                                      ..showSnackBar(
                                        const SnackBar(
                                          duration: Duration(seconds: 2),
                                          content: Text(
                                              'Στάλθηκε email για επαναφορά κωδικού'),
                                        ),
                                      );
                                  },
                                  child: const Text(
                                    'Επαναφορά κωδικού',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: TextButton(
                                onPressed: _navigateToSignUpPage,
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
                    ElevatedButton(
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
                                  side: const BorderSide(
                                      color: Color(0xFF9C0C04)),
                                ),
                                backgroundColor: Colors.black,
                              ),
                              onPressed: () {
                                String serverIp = _serverController.text.trim();
                                if (serverIp != '' && serverIp != ' ') {
                                  final globalState =
                                      context.read<GlobalStateProvider>();
                                  globalState.validatedIp = serverIp;
                                  _initialize();
                                }
                                print(
                                    'Connecting to server at: http://${GlobalStateProvider().validatedIp}:8000/');
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(
                                      duration: const Duration(seconds: 2),
                                      content: Text(
                                          'Connecting to server at: http://${GlobalStateProvider().validatedIp}:8000/'),
                                    ),
                                  );
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
          ]),
        ),
      );
    }
  }
}
