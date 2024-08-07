import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mypr/OtherPages/global_state.dart';
import 'package:mypr/routes/app_router.gr.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final AuthService _authService = AuthService();
  bool _obscureText = true;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadSavedUserCredentials();
    await _checkAndFetchClubs();
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
    final globalState = context.read<GlobalState>();
    if (!globalState.dataLoaded) {
      await _fetchClubsAndCatalogues();
      if (mounted) {
        globalState.setDataLoaded(true);
      }
    }
  }

  Future<void> _fetchClubsAndCatalogues() async {
    ClubProvider clubProvider = context.read<ClubProvider>();
    await clubProvider.loadClubsFromPreferences();
    await clubProvider.fetchClubsAndCatalogues();
    await clubProvider.loadLikedClubs();
  }

  Future<void> _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    bool success = await _authService.login(email, password);

    if (mounted) {
      if (success) {
        await context.read<UserProvider>().syncUserDetails();
        if (mounted) {
          context.router.replaceAll([const BottomNavBarRoute()]);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 4),
            content: Text('Λάθος email/τηλέφωνο ή κωδικός'),
          ),
        );
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

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: screenHeight + 300,
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
                    TextField(
                      controller: _emailController,
                      style: const TextStyle(
                        fontSize: 23,
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
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Row(
                        children: [
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
                                  duration: Duration(seconds: 4),
                                  content: Text(
                                      'Στάλθηκε email για επαναφορά κωδικού'),
                                ),
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
                          ),
                        ],
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
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: Color(0xFF9C0C04)),
                      ),
                      backgroundColor: Colors.black,
                    ),
                    onPressed: () {
                      _login();
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
                ],
              ),
              const SizedBox(height: 400),
            ],
          ),
        ),
      ),
    );
  }
}
