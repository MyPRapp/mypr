import 'package:auto_route/auto_route.dart';
import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mypr/Providers/booking_provider.dart';
import 'package:mypr/Providers/global_state_provider.dart';
import 'package:mypr/routes/app_router.gr.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Providers/club_provider.dart';
import '../Providers/user_provider.dart';
import '../global_components.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

@RoutePage()
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _obscureText = true;
  bool _obscureText2 = true;
  bool _isRegistering = false;

  final _formKey = GlobalKey<FormState>();

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _togglePasswordVisibility2() {
    setState(() {
      _obscureText2 = !_obscureText2;
    });
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isRegistering = true;
      });

      String firstName = _firstNameController.text.trim();
      String lastName = _lastNameController.text.trim();
      String username = "$firstName$lastName";
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();
      String phone = _phoneController.text.trim();
      int points = 20;

      bool registerSuccess = await _authService.register(
        username,
        password,
        firstName,
        lastName,
        email,
        phone,
        points,
      );

      if (registerSuccess) {
        await _clearPreferences();
        _showSnackBar('Επιτυχής εγγραφή!');
        await _login();
      } else {
        setState(() {
          _isRegistering = false;
        });
        _showSnackBar(
            'Υπήρξε κάποιο σφάλμα κατά την εγγραφή. Παρακαλώ προσπάθησε ξανά');
      }
    } else {
      _showSnackBar('Παρακαλώ συμπλήρωσε όλα τα πεδία');
    }
  }

  Future<void> _clearPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (mounted) {
      ClubProvider clubProvider = context.read<ClubProvider>();
      await clubProvider.deleteAllLiked();
    }

    await prefs.remove('saved_email');
    await prefs.remove('saved_password');
    await prefs.remove('user_details');
    await prefs.remove('user_photo_path');
    await prefs.remove('bookings');
  }

  Future<void> _login() async {
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
          context.read<GlobalStateProvider>().isAuthenticated = true;
          context.read<BottomNavBarVisibility>().show();
          await context.router.replaceAll([const BottomNavBarRoute()]);
        }
      } else {
        if (mounted) {
          context.read<BottomNavBarVisibility>().show();
          await context.router.replaceAll([const LoginRoute()]);
        }
      }
    } catch (e) {
      print('Login failed: $e');
      _showSnackBar('Υπήρξε κάποιο σφάλμα κατά την είσοδο στην εφαρμογή');
    } finally {
      setState(() {
        _isRegistering = false;
      });
    }
  }

  Future<void> _startSyncingClubs() async {
    print('//////SYNCING CLUBS');
    await context.read<ClubProvider>().syncClubs();
    print('//////SYNCED CLUBS');
  }

  void _showSnackBar(String message) {
    floatingSnackBar(
        message: message,
        context: context,
        duration: const Duration(milliseconds: 4000));
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

    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.black,
        body: SizedBox(
          width: screenWidth,
          height: screenHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // HEADER: TOP PICTURE AND LOGO PICTURE
              LoginHeader(
                  screenWidth: MediaQuery.of(context).size.width,
                  screenHeight: MediaQuery.of(context).size.height),
              LoginLogo(screenHeight: MediaQuery.of(context).size.height),
              Expanded(
                child: _SignUpForm(
                  formKey: _formKey,
                  firstNameController: _firstNameController,
                  lastNameController: _lastNameController,
                  phoneController: _phoneController,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  confirmPasswordController: _confirmPasswordController,
                  isRegistering: _isRegistering,
                  obscureText: _obscureText,
                  obscureText2: _obscureText2,
                  togglePasswordVisibility: _togglePasswordVisibility,
                  togglePasswordVisibility2: _togglePasswordVisibility2,
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  onRegister: _register,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignUpForm extends StatelessWidget {
  const _SignUpForm({
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.phoneController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isRegistering,
    required this.obscureText,
    required this.obscureText2,
    required this.togglePasswordVisibility,
    required this.togglePasswordVisibility2,
    required this.screenHeight,
    required this.screenWidth,
    required this.onRegister,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final double screenHeight;
  final double screenWidth;
  final bool isRegistering;
  final bool obscureText;
  final bool obscureText2;
  final VoidCallback togglePasswordVisibility;
  final VoidCallback togglePasswordVisibility2;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final double screenWidth = MediaQuery.sizeOf(context).width;

    return SizedBox(
      width: screenWidth * 0.8,
      child: Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // First and last name fields
            SizedBox(
              height: screenHeight / 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _TextFieldWidget(
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    controller: firstNameController,
                    hintText: 'Όνομα',
                    isRegistering: isRegistering,
                    inputFormatters: const [],
                  ),

                  _TextFieldWidget(
                    controller: lastNameController,
                    hintText: 'Επίθετο',
                    isRegistering: isRegistering,
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                  ),

                  // Phone field
                  _TextFieldWidget(
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    controller: phoneController,
                    hintText: 'Τηλέφωνο(+30)',
                    isRegistering: isRegistering,
                    inputFormatters: [
                      NoEmojisTextInputFormatter(),
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(15),
                    ],
                  ),

                  // Email field
                  _TextFieldWidget(
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    controller: emailController,
                    hintText: 'Email',
                    isRegistering: isRegistering,
                    inputFormatters: [NoEmojisTextInputFormatter()],
                  ),

                  // Password fields
                  _PasswordFields(
                    passwordController: passwordController,
                    confirmPasswordController: confirmPasswordController,
                    obscureText: obscureText,
                    obscureText2: obscureText2,
                    togglePasswordVisibility: togglePasswordVisibility,
                    togglePasswordVisibility2: togglePasswordVisibility2,
                    isRegistering: isRegistering,
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                  ),
                  // Sign up button and login prompt
                ],
              ),
            ),
            //TODO Add a 'go to login page' button
            _SignUpButton(
              isRegistering: isRegistering,
              onRegister: onRegister,
            ),
            SizedBox(height: screenHeight / 100),
          ],
        ),
      ),
    );
  }
}

class _TextFieldWidget extends StatelessWidget {
  const _TextFieldWidget({
    required this.controller,
    required this.hintText,
    required this.isRegistering,
    required this.screenWidth,
    required this.screenHeight,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String hintText;
  final double screenHeight;
  final double screenWidth;
  final bool isRegistering;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: screenHeight * 0.08,
      child: Column(
        children: [
          Expanded(
            child: SizedBox(
              height: screenHeight * 0.05,
              child: TextField(
                readOnly: isRegistering,
                controller: controller,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: const TextStyle(
                      color: Color.fromARGB(132, 156, 12, 4),
                    ),
                    border: InputBorder.none),
                inputFormatters: inputFormatters,
              ),
            ),
          ),
          _Divider(
            screenWidth: screenWidth,
            screenHeight: screenHeight,
          ),
        ],
      ),
    );
  }
}

class _PasswordFields extends StatelessWidget {
  const _PasswordFields({
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscureText,
    required this.obscureText2,
    required this.togglePasswordVisibility,
    required this.togglePasswordVisibility2,
    required this.isRegistering,
    required this.screenWidth,
    required this.screenHeight,
  });

  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscureText;
  final bool obscureText2;
  final VoidCallback togglePasswordVisibility;
  final VoidCallback togglePasswordVisibility2;
  final bool isRegistering;
  final double screenWidth;
  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PasswordField(
          controller: passwordController,
          hintText: 'Κωδικός',
          obscureText: obscureText,
          toggleVisibility: togglePasswordVisibility,
          isRegistering: isRegistering,
          screenWidth: screenWidth,
          screenHeight: screenHeight,
        ),
        _Divider(
          screenWidth: screenWidth,
          screenHeight: screenHeight,
        ),
        _PasswordField(
          controller: confirmPasswordController,
          hintText: 'Επιβεβαίωση κωδικού',
          obscureText: obscureText2,
          toggleVisibility: togglePasswordVisibility2,
          isRegistering: isRegistering,
          screenWidth: screenWidth,
          screenHeight: screenHeight,
        ),
      ],
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.toggleVisibility,
    required this.isRegistering,
    required this.screenWidth,
    required this.screenHeight,
  });

  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final VoidCallback toggleVisibility;
  final bool isRegistering;
  final double screenWidth;
  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: screenWidth * 0.8,
      height: screenHeight * 0.08,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SizedBox(
              height: screenHeight * 0.05,
              child: TextField(
                readOnly: isRegistering,
                obscureText: obscureText,
                controller: controller,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: const TextStyle(
                    color: Color.fromARGB(132, 156, 12, 4),
                  ),
                  border: InputBorder.none,
                ),
              ),
            ), //TODO Change size of icon and fontsize of texts
          ),
          SizedBox(
            width: 40,
            child: IconButton(
              onPressed: toggleVisibility,
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF9C0C04),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignUpButton extends StatelessWidget {
  const _SignUpButton({
    required this.isRegistering,
    required this.onRegister,
  });

  final bool isRegistering;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return isRegistering
        ? const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9C0C04)),
          )
        : ElevatedButton(
            style: ElevatedButton.styleFrom(
              //TODO Change dimensions of button
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: Color(0xFF9C0C04)),
              ),
              backgroundColor: Colors.transparent,
            ),
            onPressed: onRegister,
            child: const Icon(
              Icons.keyboard_arrow_right,
              color: Colors.red,
            ));
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.screenWidth, required this.screenHeight});

  final double screenWidth;
  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    double divirderHeight = screenHeight * 0.001;
    double divirderWidth = screenWidth * 0.8;
    return SizedBox(
      width: divirderWidth,
      child: Divider(
        height: divirderHeight,
        color: const Color.fromARGB(204, 156, 12, 4),
        thickness: (screenWidth * 0.0015) + (screenHeight * 0.006),
      ),
    );
  }
}
