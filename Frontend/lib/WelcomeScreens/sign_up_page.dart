import 'package:auto_route/auto_route.dart';
import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mypr/Providers/global_state_provider.dart';
import 'package:mypr/Providers/liked_clubs_provider.dart';
import 'package:mypr/routes/app_router.gr.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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
  bool _phoneValidating = false;

  // Error state variables
  bool firstnameError = false;
  bool lastnameError = false;
  bool phoneError = false;
  bool emailError = false;
  bool passwordError = false;
  bool confirmationPasswordError = false;
  bool _isCheckBoxPressed = false;

  void _toggleCheckBox() {
    setState(() {
      _isCheckBoxPressed = !_isCheckBoxPressed;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _register() async {
    if (_isCheckBoxPressed == false) {
      FocusManager.instance.primaryFocus?.unfocus();
      floatingSnackBar(
          message: 'Δεν έχεις συμφωνήσει με τους όρους χρήσης',
          context: context,
          duration: const Duration(milliseconds: 4000));
      return;
    }
    setState(() {
      // Reset error states
      firstnameError = false;
      lastnameError = false;
      phoneError = false;
      emailError = false;
      passwordError = false;
      confirmationPasswordError = false;

      String firstName = _firstNameController.text.trim();
      String lastName = _lastNameController.text.trim();
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();
      String confirmPassword = _confirmPasswordController.text.trim();
      String phone = _phoneController.text.trim();

      // Name and surname validation
      firstnameError = firstName.isEmpty ||
          !RegExp(r'^[\p{L}]+$', unicode: true).hasMatch(firstName);
      lastnameError = lastName.isEmpty ||
          !RegExp(r'^[\p{L}]+$', unicode: true).hasMatch(lastName);

      // Phone validation
      phoneError = phone.isEmpty || phone.length < 7 || phone.length > 15;

      // Email validation
      emailError = email.isEmpty ||
          !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

      // Password validation
      passwordError =
          !RegExp(r'^(?=(.*[a-zA-Z]){4,})(?=.*[0-9]).+$').hasMatch(password);

      // Confirmation password validation
      confirmationPasswordError = password != confirmPassword;
    });

    // If there are any errors, do not proceed with registration
    if (firstnameError ||
        lastnameError ||
        phoneError ||
        emailError ||
        passwordError ||
        confirmationPasswordError) {
      return;
    }

    setState(() {
      _firstNameController.text = _firstNameController.text[0].toUpperCase() +
          _firstNameController.text.substring(1);
      _lastNameController.text = _lastNameController.text[0].toUpperCase() +
          _lastNameController.text.substring(1);
    });
    // If validation is successful
    _showSnackBar('Στάλθηκε κωδικός με SMS');
    setState(() {
      _phoneValidating = true;
    });
    if (!await _showPhoneConfirmationDialog()) {
      setState(() {
        _phoneValidating = false;
      });
      return;
    }
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
      await _login();
    } else {
      setState(() {
        _isRegistering = false;
        _phoneValidating = false;
      });
      _showSnackBar(
          'Υπήρξε κάποιο σφάλμα κατά την εγγραφή. Παρακαλώ προσπάθησε ξανά');
    }
  }

  Future<void> _login() async {
    if (_emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      print('\x1B[32m------------LOGGING IN------------');
      setState(() {
        _isRegistering = true;
      });
      bool success = false;

      success = await AuthService().login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (success) {
        if (mounted) {
          context.read<GlobalStateProvider>().isAuthenticated = true;
          context.router.replaceAll([const BottomNavBarRoute()]);
        }
        print('\x1B[32m------------LOGGED IN------------');
      } else {
        _showSnackBar('Λάθος στοιχεία εισόδου');
        print('\x1B[31m------------LOGIN FAILED------------');
      }
      setState(() {
        _isRegistering = false;
      });
    } else {
      FocusManager.instance.primaryFocus?.unfocus();
      floatingSnackBar(
          message: 'Παρακαλώ συμπλήρωσε όλα τα πεδία',
          context: context,
          duration: const Duration(milliseconds: 4000));
    }
  }

  Future<bool> _showPhoneConfirmationDialog() async {
    String codeInput = '';
    bool isCodeValid = false; // Simulate the validation result
    bool showError = false; // Track whether to show the error message
    int attemptCount = 0; // Track the number of attempts

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor:
                  Colors.black, // Match the dialog's background to your page
              title: const Text(
                'Επιβεβαίωση Κινητού',
                style: TextStyle(color: Colors.white), // Set title text color
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    style: const TextStyle(
                        color: Colors.white), // Input text color
                    decoration: const InputDecoration(
                      hintText: 'Εισάγετε τον 6-ψήφιο κωδικό',
                      hintStyle:
                          TextStyle(color: Colors.grey), // Hint text color
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.redAccent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                    ),
                    onChanged: (value) {
                      codeInput = value;
                    },
                  ),
                  if (showError) // Show error message if showError is true
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Λάθος κωδικός',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (codeInput.length == 6) {
                      if (attemptCount >= 3) {
                        // If the user has tried more than 3 times, return false
                        Navigator.of(context).pop(false);
                        _showSnackBar('Ο αριθμός κινητού δεν επιβεβαιώθηκε');
                        return;
                      }

                      // Simulate code validation (Replace with actual code validation)
                      if (codeInput == '123456') {
                        // Replace '123456' with actual logic
                        isCodeValid = true;
                        Navigator.of(context).pop(true);
                        _showSnackBar(
                            'Ο αριθμός κινητού επιβεβαιώθηκε με επιτυχία');
                      } else {
                        // Show the error message if the code is invalid
                        setState(() {
                          showError = true;
                          attemptCount++;
                        });

                        // Hide the error message after 4 seconds
                        Future.delayed(const Duration(seconds: 4), () {
                          setState(() {
                            showError = false;
                          });
                        });
                      }
                    }
                  },
                  child: const Text(
                    'Επιβεβαίωση',
                    style: TextStyle(
                        color: Colors.redAccent), // Set button text color
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    return isCodeValid;
  }

  Future<void> _clearPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (mounted) {
      await context.read<LikesClubsProvider>().deleteAllLiked();
    }

    await prefs.remove('saved_email');
    await prefs.remove('saved_password');
    await prefs.remove('user_details');
    await prefs.remove('user_photo_path');
    await prefs.remove('bookings');
  }

  void _showSnackBar(String message) {
    FocusManager.instance.primaryFocus?.unfocus();
    floatingSnackBar(
        message: message,
        context: context,
        duration: const Duration(milliseconds: 4000));
  }

  @override
  void dispose() {
    super.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final double screenWidth = MediaQuery.sizeOf(context).width;
    return PopScope(
      canPop: false,
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.black,
          body: ListView(
            padding: EdgeInsets.zero,
            children: [
              // HEADER: TOP PICTURE AND LOGO PICTURE
              Stack(
                children: [
                  Header(screenWidth: screenWidth, screenHeight: screenHeight),
                ],
              ),
              LoginLogo(
                screenHeight: screenHeight,
                screenWidth: screenWidth,
                text: 'Καλώς όρισες στην',
                color: const Color(0xFF9C0C04),
              ),
              _SignUpForm(
                phoneValidating: _phoneValidating,
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
                firstnameError: firstnameError,
                lastnameError: lastnameError,
                phoneError: phoneError,
                emailError: emailError,
                passwordError: passwordError,
                confirmationPasswordError: confirmationPasswordError,
                isCheckBoxPressed: _isCheckBoxPressed,
                toggleCheckBox: _toggleCheckBox,
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
    required this.firstNameController,
    required this.lastNameController,
    required this.phoneController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isRegistering,
    required this.phoneValidating,
    required this.obscureText,
    required this.obscureText2,
    required this.togglePasswordVisibility,
    required this.togglePasswordVisibility2,
    required this.screenHeight,
    required this.screenWidth,
    required this.onRegister,
    required this.firstnameError,
    required this.lastnameError,
    required this.phoneError,
    required this.emailError,
    required this.passwordError,
    required this.confirmationPasswordError,
    required this.isCheckBoxPressed,
    required this.toggleCheckBox,
  });

  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final double screenHeight;
  final double screenWidth;
  final bool isRegistering;
  final bool phoneValidating;
  final bool obscureText;
  final bool obscureText2;
  final VoidCallback togglePasswordVisibility;
  final VoidCallback togglePasswordVisibility2;
  final VoidCallback onRegister;
  final bool firstnameError;
  final bool lastnameError;
  final bool phoneError;
  final bool emailError;
  final bool passwordError;
  final bool confirmationPasswordError;
  final bool isCheckBoxPressed;
  final Function toggleCheckBox;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: screenWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // First and last name fields
          SizedBox(
            width: screenWidth * 0.8,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _TextFieldWidget(
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  controller: firstNameController,
                  hintText: 'Όνομα',
                  isRegistering: isRegistering,
                  inputFormatters: [NoEmojisTextInputFormatter()],
                ),

                _TextFieldWidget(
                  controller: lastNameController,
                  hintText: 'Επίθετο',
                  isRegistering: isRegistering,
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  inputFormatters: [NoEmojisTextInputFormatter()],
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
                _PasswordField(
                  controller: passwordController,
                  hintText: 'Κωδικός',
                  obscureText: obscureText,
                  toggleVisibility: togglePasswordVisibility,
                  isRegistering: isRegistering,
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
                // Sign up button and login prompt
              ],
            ),
          ),

          Row(
            children: [
              SizedBox(
                width: screenWidth * 0.1,
              ),
              CheckBoxWidget(
                isCheckBoxPressed: isCheckBoxPressed,
                toggleCheckBox: toggleCheckBox,
              ),
              Text(
                'Συμφωνώ με τους ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: (screenWidth * 0.01) + (screenHeight * 0.012),
                  fontWeight: FontWeight.w800,
                ),
              ),
              GestureDetector(
                //TODO Change url
                onTap: () {
                  launchUrl(Uri.parse('https://www.instagram.com/mypr_app/'),
                      mode: LaunchMode.externalApplication);
                },
                child: Text(
                  'όρους χρήσης',
                  style: TextStyle(
                      decoration: TextDecoration.underline,
                      decorationColor: const Color.fromARGB(200, 255, 255, 255),
                      color: Colors.white,
                      fontSize: (screenWidth * 0.01) + (screenHeight * 0.012),
                      fontWeight: FontWeight.w800),
                ),
              )
            ],
          ),

          SizedBox(height: screenHeight / 100),
          _SignUpButton(
            phoneValidating: phoneValidating,
            isRegistering: isRegistering,
            onRegister: onRegister,
            screenHeight: screenHeight,
            screenWidth: screenWidth,
            firstnameError: firstnameError,
            lastnameError: lastnameError,
            phoneError: phoneError,
            emailError: emailError,
            passwordError: passwordError,
            confirmationPasswordError: confirmationPasswordError,
          ),
          SizedBox(height: screenHeight / 15),
          SizedBox(
            width: screenWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Έχεις ήδη λογαριασμό;',
                  style: TextStyle(
                    color: const Color.fromARGB(104, 255, 255, 255),
                    fontSize: (screenWidth * 0.012) + (screenHeight * 0.016),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (!isRegistering) {
                      AutoRouter.of(context).replaceAll([const LoginRoute()]);
                    }
                  },
                  child: Text(
                    'Συνδέσου',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      decorationColor: const Color.fromARGB(157, 255, 255, 255),
                      color: Colors.white,
                      fontSize: (screenWidth * 0.012) + (screenHeight * 0.016),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: screenHeight / 20),
        ],
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
    return Padding(
      padding: EdgeInsets.only(bottom: screenHeight * 0.02),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(96, 63, 63, 63),
          border: Border.all(
            color: const Color.fromARGB(118, 88, 88, 88),
          ),
          borderRadius: BorderRadius.circular(05),
        ),
        child: TextField(
          readOnly: isRegistering,
          controller: controller,
          style: TextStyle(
            fontSize: (screenWidth * 0.0085) + (screenHeight * 0.022),
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          cursorColor: const Color.fromARGB(125, 244, 67, 54),
          decoration: InputDecoration(
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF9C0C04)),
            ),
            contentPadding: EdgeInsets.only(left: screenWidth * 0.035),
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: (screenWidth * 0.0078) + (screenHeight * 0.019),
              color: const Color.fromARGB(75, 255, 255, 255),
            ),
          ),
          inputFormatters: inputFormatters,
        ),
      ),
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
    return Padding(
      padding: EdgeInsets.only(bottom: screenHeight * 0.02),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(96, 63, 63, 63),
          border: Border.all(
            color: const Color.fromARGB(118, 88, 88, 88),
          ),
          borderRadius: BorderRadius.circular(05),
        ),
        width: screenWidth * 0.8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: TextField(
                inputFormatters: [NoEmojisTextInputFormatter()],
                readOnly: isRegistering,
                obscureText: obscureText,
                controller: controller,
                style: TextStyle(
                  fontSize: (screenWidth * 0.0085) + (screenHeight * 0.022),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                cursorColor: const Color.fromARGB(125, 244, 67, 54),
                decoration: InputDecoration(
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF9C0C04)),
                  ),
                  contentPadding: EdgeInsets.only(left: screenWidth * 0.035),
                  alignLabelWithHint: true,
                  hintText: hintText,
                  hintStyle: TextStyle(
                    fontSize: (screenWidth * 0.0078) + (screenHeight * 0.019),
                    color: const Color.fromARGB(75, 255, 255, 255),
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: toggleVisibility,
              icon: Icon(
                size: (screenWidth * 0.01) + (screenHeight * 0.025),
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF9C0C04),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignUpButton extends StatelessWidget {
  const _SignUpButton({
    required this.isRegistering,
    required this.phoneValidating,
    required this.onRegister,
    required this.screenHeight,
    required this.screenWidth,
    required this.firstnameError,
    required this.lastnameError,
    required this.phoneError,
    required this.emailError,
    required this.passwordError,
    required this.confirmationPasswordError,
  });

  final bool isRegistering;
  final bool phoneValidating;
  final double screenHeight;
  final double screenWidth;
  final VoidCallback onRegister;

  // Error states
  final bool firstnameError;
  final bool lastnameError;
  final bool phoneError;
  final bool emailError;
  final bool passwordError;
  final bool confirmationPasswordError;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: screenWidth,
      child: Column(
        children: [
          SizedBox(
            width: screenWidth * 0.8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (firstnameError || lastnameError)
                  _ErrorText(
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    text: '- Μόνο γράμματα στο ονοματεπώνυμο',
                  ),
                if (phoneError)
                  _ErrorText(
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    text: '- Δεν βρέθηκε το τηλέφωνο',
                  ),
                if (emailError)
                  _ErrorText(
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    text: '- Δεν βρέθηκε το email',
                  ),
                if (passwordError)
                  _ErrorText(
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    text:
                        '- Τουλάχιστον 4 λατινικοί χαρακτήρες\n  και 1 αριθμός στον κωδικό',
                  ),
                if (confirmationPasswordError)
                  _ErrorText(
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    text: '- Οι κωδικοί δεν ταιριάζουν',
                  ),
              ],
            ),
          ),
          SizedBox(
              height: screenHeight * 0.02), // Add space between text and button
          isRegistering && phoneValidating
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9C0C04)),
                )
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.07,
                        vertical: screenHeight * 0.028),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: Color(0xFF9C0C04)),
                    ),
                    backgroundColor: Colors.transparent,
                  ),
                  onPressed: onRegister,
                  child: Text(
                    'Εγγραφή',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: screenHeight * screenWidth * 0.000062,
                    ),
                  )),
        ],
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText({
    required this.screenWidth,
    required this.screenHeight,
    required this.text,
  });
  final double screenWidth;
  final double screenHeight;
  final String text;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: screenWidth,
      child: Text(
        text,
        style: TextStyle(
            fontSize: (screenWidth * 0.0074) + (screenHeight * 0.0138),
            color: const Color(0xFF9C0C04),
            fontWeight: FontWeight.w500),
      ),
    );
  }
}

class Header extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;

  const Header({
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

class CheckBoxWidget extends StatefulWidget {
  const CheckBoxWidget({
    super.key,
    required this.isCheckBoxPressed,
    required this.toggleCheckBox,
  });

  final bool isCheckBoxPressed;
  final Function toggleCheckBox;
  @override
  State<CheckBoxWidget> createState() => _CheckBoxWidgetState();
}

class _CheckBoxWidgetState extends State<CheckBoxWidget> {
  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 1.15,
      child: Checkbox(
        value: widget.isCheckBoxPressed,
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (!states.contains(WidgetState.selected)) {
            return const Color.fromARGB(94, 255, 255, 255);
          }
          return null;
        }),
        side: BorderSide.none,
        checkColor: const Color(0xFF9C0C04),
        activeColor: Colors.black,
        onChanged: (newValue) {
          setState(() {
            widget.toggleCheckBox();
          });
        },
      ),
    );
  }
}
