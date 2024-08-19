import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mypr/OtherPages/global_state.dart';
import 'package:mypr/routes/app_router.gr.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';

class NoEmojisTextInputFormatter extends TextInputFormatter {
  // RegExp to allow Greek and English letters, numbers, and specific symbols without emojis
  final RegExp _allowedCharacters =
      RegExp(r'[\p{L}\p{N}\p{P}\p{Zs}!@#$%^&*(){}]+', unicode: true);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Allow the text to be completely deleted (empty string)
    if (newValue.text.isEmpty || _allowedCharacters.hasMatch(newValue.text)) {
      return newValue;
    }
    // If the new value contains restricted characters, return the old value
    return oldValue;
  }
}

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

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      String firstName = _firstNameController.text.trim();
      String lastName = _lastNameController.text.trim();
      String username = "$firstName$lastName";
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();
      String phone = _phoneController.text.trim();

      bool registerSuccess = await _authService.register(
        username,
        password,
        firstName,
        lastName,
        email,
        phone,
      );

      if (!mounted) return;

      if (registerSuccess) {
        _login();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 4),
            content: Text('Υπήρξε κάποιο πρόβλημα κατά την εγγραφή'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Παρακαλώ συμπληρώστε όλα τα πεδία'),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  void _navigateToEmailLoginPage() {
    if (mounted) {
      context.router.replaceAll([const LoginRoute()]);
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
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: SizedBox(
            width: screenWidth,
            height: screenHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 70,
                  width: screenWidth,
                  child: const Image(
                    image: AssetImage('assets/otherPhotos/IMG_0041.jpg'),
                    fit: BoxFit.cover,
                    alignment: Alignment(0, -0.3),
                  ),
                ),
                const SizedBox(
                  height: 150,
                  child: Image(
                    image: AssetImage(
                      'assets/otherPhotos/Screenshot 2024-07-28 021714-Photoroom.png',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: SizedBox(
                    width: screenWidth - 60,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 40,
                          child: Text(
                            'Δημιουργία λογαριασμού',
                            style: TextStyle(
                              color: Color(0xFF9c0c04),
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: SizedBox(
                            height: screenHeight / 16,
                            width: screenWidth - 60,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  height: screenHeight / 16,
                                  width: (screenWidth - 60) / 2 - 10,
                                  child: TextFormField(
                                    controller: _firstNameController,
                                    style: const TextStyle(
                                      fontSize: 23,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: 'Όνομα',
                                      hintStyle: TextStyle(
                                        color: Color.fromARGB(132, 156, 12, 4),
                                      ),
                                      border: InputBorder.none,
                                      errorStyle: TextStyle(
                                        color: Color(0xFF9C0C04),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    inputFormatters: [
                                      NoEmojisTextInputFormatter(),
                                    ],
                                    validator: (value) {
                                      if (value == null ||
                                          value.isEmpty ||
                                          !RegExp(r'^[\p{L}]+$', unicode: true)
                                              .hasMatch(value)) {
                                        return 'Μόνο γράμματα επιτρέπονται';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  width: 20,
                                  child: VerticalDivider(
                                    color: Color.fromARGB(204, 156, 12, 4),
                                    thickness: 7,
                                  ),
                                ),
                                SizedBox(
                                  height: screenHeight / 16,
                                  width: (screenWidth - 60) / 2 - 10,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: TextFormField(
                                      controller: _lastNameController,
                                      style: const TextStyle(
                                        fontSize: 23,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      decoration: const InputDecoration(
                                        hintText: 'Επίθετο',
                                        hintStyle: TextStyle(
                                          color:
                                              Color.fromARGB(132, 156, 12, 4),
                                        ),
                                        border: InputBorder.none,
                                        errorStyle: TextStyle(
                                          color: Color(0xFF9C0C04),
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      inputFormatters: [
                                        NoEmojisTextInputFormatter(),
                                      ],
                                      validator: (value) {
                                        if (value == null ||
                                            value.isEmpty ||
                                            !RegExp(r'^[\p{L}]+$',
                                                    unicode: true)
                                                .hasMatch(value)) {
                                          return 'Μόνο γράμματα επιτρέπονται';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: screenWidth - 60,
                          child: const Divider(
                            height: 5,
                            color: Color.fromARGB(204, 156, 12, 4),
                            thickness: 7,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: SizedBox(
                            height: screenHeight / 16,
                            width: screenWidth - 60,
                            child: TextFormField(
                              controller: _phoneController,
                              style: const TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Τηλέφωνο(+30)',
                                hintStyle: TextStyle(
                                  color: Color.fromARGB(132, 156, 12, 4),
                                ),
                                border: InputBorder.none,
                                errorStyle: TextStyle(
                                  color: Color(0xFF9C0C04),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                NoEmojisTextInputFormatter(),
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(15),
                              ],
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.length < 7 ||
                                    value.length > 15) {
                                  return 'Εισαγάγετε έγκυρο αριθμό';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          width: screenWidth - 60,
                          child: const Divider(
                            height: 5,
                            color: Color.fromARGB(204, 156, 12, 4),
                            thickness: 7,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: SizedBox(
                            height: screenHeight / 16,
                            width: screenWidth - 60,
                            child: TextFormField(
                              controller: _emailController,
                              style: const TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Email',
                                hintStyle: TextStyle(
                                  color: Color.fromARGB(132, 156, 12, 4),
                                ),
                                border: InputBorder.none,
                                errorStyle: TextStyle(
                                  color: Color(0xFF9C0C04),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              inputFormatters: [
                                NoEmojisTextInputFormatter(),
                              ],
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                        .hasMatch(value)) {
                                  return 'Εισαγάγετε έγκυρο email';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          width: screenWidth - 60,
                          child: const Divider(
                            height: 5,
                            color: Color.fromARGB(204, 156, 12, 4),
                            thickness: 7,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: SizedBox(
                            height: screenHeight / 16,
                            width: screenWidth - 60,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: (screenWidth - 60) - 40,
                                  height: screenHeight / 16,
                                  child: TextFormField(
                                    obscureText: _obscureText,
                                    controller: _passwordController,
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
                                      errorStyle: TextStyle(
                                        color: Color(0xFF9C0C04),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    inputFormatters: [
                                      NoEmojisTextInputFormatter(),
                                      LengthLimitingTextInputFormatter(
                                          20), // Optional: limit password length
                                    ],
                                    validator: (value) {
                                      if (value == null ||
                                          value.isEmpty ||
                                          value.length < 6 ||
                                          !RegExp(r'^[a-zA-Z0-9]+$')
                                              .hasMatch(value) ||
                                          !RegExp(r'[0-9]').hasMatch(value)) {
                                        return 'Τουλάχιστον 6 χαρακτήρες(μόνο λατινικοί) και 1 αριθμός';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 40,
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
                        ),
                        SizedBox(
                          width: screenWidth - 60,
                          child: const Divider(
                            height: 5,
                            color: Color.fromARGB(204, 156, 12, 4),
                            thickness: 7,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: SizedBox(
                            height: screenHeight / 16,
                            width: screenWidth - 60,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: (screenWidth - 60) - 40,
                                  height: screenHeight / 16,
                                  child: TextFormField(
                                    obscureText: _obscureText2,
                                    controller: _confirmPasswordController,
                                    style: const TextStyle(
                                      fontSize: 23,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: 'Επιβεβαίωση κωδικού',
                                      hintStyle: TextStyle(
                                        color: Color.fromARGB(132, 156, 12, 4),
                                      ),
                                      border: InputBorder.none,
                                      errorStyle: TextStyle(
                                        color: Color(0xFF9C0C04),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    inputFormatters: [
                                      NoEmojisTextInputFormatter(),
                                    ],
                                    validator: (value) {
                                      if (value != _passwordController.text) {
                                        return 'Οι κωδικοί δεν ταιριάζουν';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 40,
                                  child: IconButton(
                                    onPressed: _togglePasswordVisibility2,
                                    icon: Icon(
                                      _obscureText2
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: const Color(0xFF9C0C04),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 70,
                          width: screenWidth - 60,
                          child: Row(
                            children: [
                              const Text(
                                'Έχεις ήδη λογαριασμό; ',
                                style: TextStyle(
                                  color: Color(0xFF9C0C04),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: _navigateToEmailLoginPage,
                                child: const Text(
                                  'Συνδέσου',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: Color(0xFF9C0C04)),
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                    onPressed: () {
                      _register();
                    },
                    child: const Text(
                      'Εγγραφή',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
