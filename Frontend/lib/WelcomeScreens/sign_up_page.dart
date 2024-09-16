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
  bool _phoneValidating = false;

  // Error state variables
  bool firstnameError = false;
  bool lastnameError = false;
  bool phoneError = false;
  bool emailError = false;
  bool passwordError = false;
  bool confirmationPasswordError = false;

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
          !RegExp(r'^(?=(.*[a-zA-Z]){6,})(?=.*[0-9]).+$').hasMatch(password);

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
      _showSnackBar('Επιτυχής εγγραφή!');
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
        _phoneValidating = false;
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

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final double screenWidth = MediaQuery.sizeOf(context).width;

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
          SizedBox(
            width: screenWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Έχεις ήδη λογαριασμό; ',
                  style: TextStyle(
                    color: const Color(0xFF9C0C04),
                    fontSize: (screenWidth * 0.012) + (screenHeight * 0.016),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      if (!isRegistering) {
                        AutoRouter.of(context).replaceAll([const LoginRoute()]);
                      }
                    },
                    child: Text(
                      'Συνδέσου',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize:
                            (screenWidth * 0.012) + (screenHeight * 0.016),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
          SizedBox(height: screenHeight / 100),
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
    return SizedBox(
      height: screenHeight * 0.08,
      width: screenWidth * 0.8,
      child: Column(
        children: [
          Flexible(
            flex: 10,
            child: TextField(
              readOnly: isRegistering,
              controller: controller,
              style: TextStyle(
                fontSize: (screenWidth * 0.01) + (screenHeight * 0.025),
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
          Flexible(
            flex: 1,
            child: _Divider(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
            ),
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
    return SizedBox(
      height: screenHeight * 0.14,
      width: screenWidth * 0.8,
      child: Column(
        children: [
          SizedBox(
            height: screenHeight * 0.08,
            width: screenWidth * 0.8,
            child: Column(
              children: [
                Flexible(
                  flex: 10,
                  child: _PasswordField(
                    controller: passwordController,
                    hintText: 'Κωδικός',
                    obscureText: obscureText,
                    toggleVisibility: togglePasswordVisibility,
                    isRegistering: isRegistering,
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: _Divider(
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: screenHeight * 0.06,
            width: screenWidth * 0.8,
            child: _PasswordField(
              controller: confirmPasswordController,
              hintText: 'Επιβεβαίωση κωδικού',
              obscureText: obscureText2,
              toggleVisibility: togglePasswordVisibility2,
              isRegistering: isRegistering,
              screenWidth: screenWidth,
              screenHeight: screenHeight,
            ),
          ),
        ],
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
    return SizedBox(
      width: screenWidth * 0.8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SizedBox(
              height: screenHeight * 0.07,
              child: TextField(
                inputFormatters: [NoEmojisTextInputFormatter()],
                readOnly: isRegistering,
                obscureText: obscureText,
                controller: controller,
                style: TextStyle(
                  fontSize: (screenWidth * 0.01) + (screenHeight * 0.025),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: firstnameError ||
                lastnameError ||
                phoneError ||
                emailError ||
                passwordError ||
                confirmationPasswordError
            ? MainAxisAlignment.start
            : MainAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (firstnameError || lastnameError)
                _ErrorText(
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  text: '🔻 Μόνο γράμματα στο ονοματεπώνυμο',
                ),
              if (phoneError)
                _ErrorText(
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  text: '🔻 Μη έγκυρος αριθμός τηλεφώνου',
                ),
              if (emailError)
                _ErrorText(
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  text: '🔻 Μη έγκυρο email',
                ),
              if (passwordError)
                _ErrorText(
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  text:
                      '🔻 Ο κωδικός πρέπει να αποτλείται από:\n6+ λατινικούς χαρακτήρες και 1 αριθμό',
                ),
              if (confirmationPasswordError)
                _ErrorText(
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  text: '🔻 Οι κωδικοί δεν ταιριάζουν',
                ),
            ],
          ),
          SizedBox(
              width: screenWidth * 0.007), // Add space between text and button
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
                  child: const Icon(
                    Icons.keyboard_arrow_right,
                    color: Colors.red,
                  ),
                ),
        ],
      ),
    );
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
      height: (text ==
              '🔻 Ο κωδικός πρέπει να αποτλείται από:\n6+ λατινικούς χαρακτήρες και 1 αριθμό')
          ? screenHeight * 0.027 * 2
          : screenHeight * 0.027,
      child: Text(
        text,
        style: TextStyle(
            fontSize: (screenWidth * 0.008) + (screenHeight * 0.015),
            color: const Color(0xFF9C0C04),
            fontWeight: FontWeight.w700),
      ),
    );
  }
}
