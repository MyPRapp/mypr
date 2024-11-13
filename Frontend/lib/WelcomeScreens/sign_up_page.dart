import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mypr/Providers/global_state_provider.dart';
import 'package:mypr/Providers/liked_clubs_provider.dart';
import 'package:mypr/routes/app_router.gr.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Globals/global_components.dart';
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
  final AuthService _authService = AuthService();

  String phoneNumber = '';

  bool _obscureText = true;
  bool _obscureText2 = true;
  bool _isRegistering = false;

  // Error state variables
  bool firstnameError = false;
  bool lastnameError = false;
  bool emailError = false;
  bool passwordError = false;
  bool confirmationPasswordError = false;
  bool _isCheckBoxPressed = false;

  Future<void> _register() async {
    // Reset error states
    firstnameError = false;
    lastnameError = false;
    emailError = false;
    passwordError = false;
    confirmationPasswordError = false;
    phoneNumber = "";

    String firstName = _firstNameController.text.trim();
    String lastName = _lastNameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    setState(() {
      // Name and surname validation
      firstnameError = firstName.isEmpty ||
          !RegExp(r'^[\p{L}]+$', unicode: true).hasMatch(firstName);
      lastnameError = lastName.isEmpty ||
          !RegExp(r'^[\p{L}]+$', unicode: true).hasMatch(lastName);

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
        emailError ||
        passwordError ||
        confirmationPasswordError) {
      return;
    }

    if (_isCheckBoxPressed == false) {
      FocusManager.instance.primaryFocus?.unfocus();
      if (mounted) {
        showFloatingSnackBar('Δεν έχεις συμφωνήσει με τους όρους χρήσης',
            const Duration(milliseconds: 4000), context);
      }
      return;
    }

    setState(() {
      _firstNameController.text = _firstNameController.text[0].toUpperCase() +
          _firstNameController.text.substring(1);
      _lastNameController.text = _lastNameController.text[0].toUpperCase() +
          _lastNameController.text.substring(1);
    });

    if (!await _showFillPhoneDialog()) {
      return;
    }

    setState(() {
      _isRegistering = true;
    });

    String username = "$firstName$lastName";
    int points = 400;

    int registerSuccess = await _authService.register(
      username,
      password,
      firstName,
      lastName,
      email,
      phoneNumber,
      points,
    );

    errorPrint(phoneNumber);

    if (registerSuccess == 1) {
      _showSnackBar('Επιτυχής εγγραφή');
      await _clearPreferences();
      await _login();
    } else {
      setState(() {
        _isRegistering = false;
        phoneNumber = '';
      });
      if (registerSuccess == 0) {
        _showSnackBar(
            'Υπήρξε κάποιο σφάλμα κατά την εγγραφή. Παρακαλώ προσπάθησε ξανά σε λίγο');
      }
      if (registerSuccess == 2) {
        _showSnackBar('Το email χρησιμοποιείται ήδη');
      }
      if (registerSuccess == 3) {
        _showSnackBar('Ο αριθμός κινητού χρησιμοποιείται ήδη');
      }
      if (registerSuccess == 4) {
        _showSnackBar('Το email και ο αριθμός κινητού χρησιμοποιούνται ήδη');
      }
    }
  }

  Future<void> _login() async {
    if (_emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      successPrint('------------LOGGING IN------------');
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
          context.read<GlobalStateProvider>().justRegistered = true;
          FocusManager.instance.primaryFocus?.unfocus();
          await Future.delayed(Duration(seconds: 1));

          if (mounted) {
            context.router.replaceAll([const BottomNavBarRoute()]);
          }
        }
        successPrint('------------LOGGED IN------------');
      } else {
        _showSnackBar('Λάθος στοιχεία εισόδου');
        errorPrint('------------LOGIN FAILED------------');
        setState(() {
          _isRegistering = false;
        });
      }
    } else {
      FocusManager.instance.primaryFocus?.unfocus();
      showFloatingSnackBar('Παρακαλώ συμπλήρωσε όλα τα πεδία',
          const Duration(milliseconds: 4000), context);
    }
  }

  Future<bool> _showFillPhoneDialog() async {
    bool phoneError = false;
    String phoneInput = '';
    bool isCodeValid = false;
    bool showError = false;
    int attemptCount = 0;
    String codeInput = '';
    bool initialPage = true;
    int otpCode = generateRandom6DigitNumber();
    String tempPhoneNumber = '';

    if (!phoneOtpService.canSend && initialPage == false) {
      if (phoneOtpService.awaitMinutes == 1) {
        _showSnackBar('Ξαναδοκίμασε σε 1 λεπτό');
      } else {
        _showSnackBar('Ξαναδοκίμασε σε ${phoneOtpService.awaitMinutes} λεπτά');
      }
      return false;
    }

    PageController pageController = PageController();

    await showDialog(
      barrierDismissible: false,
      barrierColor: const Color.fromARGB(150, 0, 0, 0),
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color.fromARGB(255, 28, 28, 28),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 17.sp),
                    onPressed: () {
                      if (initialPage) {
                        Navigator.pop(context);
                      } else {
                        attemptCount = 0;
                        pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut);
                        initialPage = true;
                      }
                    },
                  ),
                  SizedBox(width: 20.w),
                  Text(
                    'Επιβεβαίωση Κινητού',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 16.sp),
                  ),
                ],
              ),
              content: SizedBox(
                width: ScreenUtil().screenWidth - 30.w,
                height: 100.h,
                child: PageView(
                  controller: pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    // First page for phone number input
                    Column(
                      children: [
                        TextField(
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          keyboardType: TextInputType.number,
                          maxLength: 10,
                          style:
                              TextStyle(color: Colors.white, fontSize: 15.sp),
                          decoration: InputDecoration(
                            hintText: ' Συμπλήρωσε το κινητό σου',
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 12.sp),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF9C0C04)),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                          ),
                          onChanged: (value) {
                            phoneInput = value;
                          },
                        ),
                        if (phoneError)
                          Text(
                            "Μη έγκυρος αριθμός τηλεφώνου",
                            style: TextStyle(
                                color: const Color.fromARGB(255, 211, 32, 20),
                                fontSize: 14.sp),
                          ),
                      ],
                    ),
                    // Second page for OTP input
                    Column(
                      children: [
                        TextField(
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          style:
                              TextStyle(color: Colors.white, fontSize: 15.sp),
                          decoration: InputDecoration(
                            hintText: ' Εισάγετε τον 6-ψήφιο κωδικό',
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 12.sp),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF9C0C04)),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                          ),
                          onChanged: (value) {
                            codeInput = value;
                          },
                        ),
                        if (showError)
                          Padding(
                            padding: EdgeInsets.only(top: 10.h),
                            child: Text(
                              'Λάθος κωδικός',
                              style: TextStyle(
                                  color: const Color.fromARGB(255, 211, 32, 20),
                                  fontSize: 14.sp),
                            ),
                          )
                        else
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Κινητό: $phoneInput',
                              style: TextStyle(
                                  color: const Color.fromARGB(255, 80, 80, 80),
                                  fontSize: 14.sp),
                            ),
                          )
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                if (initialPage)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 140.w,
                        child: TextButton(
                            onPressed: () async {
                              isCodeValid = true;
                              Navigator.of(context).pop(true);
                            },
                            child: Text(
                              "Ολοκλήρωση αργότερα",
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.grey,
                                decorationThickness: 1,
                                color: Colors.grey,
                                fontSize: 12.sp,
                              ),
                            )),
                      ),
                      ElevatedButton(
                          onPressed: () async {
                            // Phone validation
                            tempPhoneNumber = normalizePhoneNumber(phoneInput);
                            phoneError = tempPhoneNumber.length != 10 ||
                                !tempPhoneNumber.startsWith('69');

                            if (phoneError == false) {
                              if (!phoneOtpService.canSend) {
                                if (phoneOtpService.awaitMinutes == 1) {
                                  showFloatingSnackBar(
                                      'Ξαναδοκίμασε σε 1 λεπτό',
                                      const Duration(milliseconds: 4000),
                                      context);
                                } else {
                                  showFloatingSnackBar(
                                      'Ξαναδοκίμασε σε ${phoneOtpService.awaitMinutes} λεπτά',
                                      const Duration(milliseconds: 4000),
                                      context);
                                }
                              } else {
                                otpCode = generateRandom6DigitNumber();
                                phoneOtpService.sendOtp(
                                    tempPhoneNumber, otpCode, context);
                                phoneOtpService
                                    .startTimer(); // Start the timer to handle resending OTP
                                setState(() {
                                  initialPage = false;
                                });
                                await pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            } else {
                              setState(() {
                                phoneError = true;
                              });
                              if (mounted) {
                                if (phoneError == true) {
                                  await Future.delayed(
                                      const Duration(seconds: 2));
                                  if (phoneError == true) {
                                    setState(() {
                                      phoneError = false;
                                    });
                                  }
                                }
                              }
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.all<Color>(Colors.black),
                          ),
                          child: Text(
                            "Συνέχεια",
                            style:
                                TextStyle(color: Colors.white, fontSize: 13.sp),
                          )),
                    ],
                  ),
                if (!initialPage)
                  Column(
                    children: [
                      TextButton(
                        onPressed: () async {
                          if (codeInput.length == 6) {
                            if (codeInput == otpCode.toString()) {
                              isCodeValid = true;
                              setState(() {
                                showError = false;
                              });
                              phoneNumber = tempPhoneNumber;
                              if (context.mounted) {
                                Navigator.of(context).pop(true);
                              }
                            } else {
                              if (attemptCount >= 2) {
                                _showSnackBar(
                                    'Ο αριθμός κινητού δεν επιβεβαιώθηκε');
                                setState(() {
                                  showError = false;
                                });
                                isCodeValid = false;
                                if (context.mounted) {
                                  Navigator.of(context).pop(true);
                                }
                              }
                              setState(() {
                                showError = true;
                              });
                              attemptCount++;
                              if (mounted) {
                                if (showError == true) {
                                  await Future.delayed(
                                      const Duration(milliseconds: 1350));
                                  if (showError == true) {
                                    setState(() {
                                      showError = false;
                                    });
                                  }
                                }
                              }
                              isCodeValid = false;
                              return;
                            }
                          }
                        },
                        child: Text(
                          'Επιβεβαίωση',
                          style: TextStyle(
                              color: const Color(0xFF9C0C04), fontSize: 13.sp),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          if (phoneOtpService.canSend) {
                            phoneOtpService.sendOtp(
                                tempPhoneNumber, otpCode, context);
                            phoneOtpService.startTimer();
                          } else {
                            if (phoneOtpService.awaitMinutes == 1) {
                              showFloatingSnackBar('Ξαναδοκίμασε σε 1 λεπτό',
                                  const Duration(milliseconds: 4000), context);
                            } else {
                              showFloatingSnackBar(
                                  'Ξαναδοκίμασε σε ${phoneOtpService.awaitMinutes} λεπτά',
                                  const Duration(milliseconds: 4000),
                                  context);
                            }
                          }
                        },
                        child: Text(
                          'Επαναποστολή κωδικού',
                          style:
                              TextStyle(color: Colors.white, fontSize: 13.sp),
                        ),
                      ),
                    ],
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
      await context.read<LikedClubsProvider>().deleteAllLiked();
    }

    await prefs.remove('savedEmail');
    await prefs.remove('savedPassword');
    await prefs.remove('user_details');
    await prefs.remove('bookings');
  }

  void _showSnackBar(String message) {
    FocusManager.instance.primaryFocus?.unfocus();
    showFloatingSnackBar(message, const Duration(seconds: 3), context);
  }

  void _toggleCheckBox() {
    setState(() {
      _isCheckBoxPressed = !_isCheckBoxPressed;
    });
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
                  const Header(),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      if (!_isRegistering) {
                        AutoRouter.of(context)
                            .replaceAll([const BottomNavBarRoute()]);
                      }
                    },
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.only(
                            right: 10.w,
                            top: ScreenUtil().statusBarHeight + 10.h),
                        child: Container(
                          padding: EdgeInsets.all(5.sp),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color:
                                      const Color.fromARGB(255, 105, 105, 105)),
                              borderRadius: BorderRadius.circular(5.r)),
                          child: Text('Παράλειψη',
                              style: TextStyle(
                                  color:
                                      const Color.fromARGB(255, 133, 132, 132),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.sp)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const LoginLogo(
                text: 'Καλωσόρισες στην',
                color: Color(0xFF9C0C04),
              ),
              SizedBox(height: 40.h),
              _SignUpForm(
                firstNameController: _firstNameController,
                lastNameController: _lastNameController,
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

  @override
  void dispose() {
    super.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
  }
}

class _SignUpForm extends StatelessWidget {
  const _SignUpForm({
    required this.firstNameController,
    required this.lastNameController,
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
    required this.firstnameError,
    required this.lastnameError,
    required this.emailError,
    required this.passwordError,
    required this.confirmationPasswordError,
    required this.isCheckBoxPressed,
    required this.toggleCheckBox,
  });

  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
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
  final bool firstnameError;
  final bool lastnameError;
  final bool emailError;
  final bool passwordError;
  final bool confirmationPasswordError;
  final bool isCheckBoxPressed;
  final Function toggleCheckBox;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // First and last name fields
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: screenHeight - 220.h),
          child: Column(
            children: [
              _TextFieldWidget(
                obscureText: false,
                toggleVisibility: togglePasswordVisibility,
                showIcon: false,
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                controller: firstNameController,
                hintText: 'Όνομα',
                isRegistering: isRegistering,
                inputFormatters: [NoEmojisTextInputFormatter()],
              ),

              _TextFieldWidget(
                obscureText: false,
                toggleVisibility: togglePasswordVisibility,
                showIcon: false,
                controller: lastNameController,
                hintText: 'Επώνυμο',
                isRegistering: isRegistering,
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                inputFormatters: [NoEmojisTextInputFormatter()],
              ),
              /*
              // Phone field
              _TextFieldWidget(
                obscureText: false,
                toggleVisibility: togglePasswordVisibility,
                showIcon: false,
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                controller: phoneController,
                hintText: 'Τηλέφωνο(+30)',
                isRegistering: isRegistering,
                inputFormatters: [
                  NoEmojisTextInputFormatter(),
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
              ),
              */
              // Email field
              _TextFieldWidget(
                obscureText: false,
                toggleVisibility: togglePasswordVisibility,
                showIcon: false,
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                controller: emailController,
                hintText: 'Email',
                isRegistering: isRegistering,
                inputFormatters: [NoEmojisTextInputFormatter()],
              ),

              // Password fields
              _TextFieldWidget(
                controller: passwordController,
                hintText: 'Κωδικός',
                showIcon: true,
                obscureText: obscureText,
                toggleVisibility: togglePasswordVisibility,
                isRegistering: isRegistering,
                screenWidth: screenWidth,
                screenHeight: screenHeight,
              ),
              _TextFieldWidget(
                controller: confirmPasswordController,
                hintText: 'Επιβεβαίωση κωδικού',
                showIcon: true,
                obscureText: obscureText2,
                toggleVisibility: togglePasswordVisibility2,
                isRegistering: isRegistering,
                screenWidth: screenWidth,
                screenHeight: screenHeight,
              ),
              SizedBox(
                height: 10.h,
              ),
              CheckBoxWidget(
                isCheckBoxPressed: isCheckBoxPressed,
                toggleCheckBox: toggleCheckBox,
                isRegistering: isRegistering,
              ),
              SizedBox(height: 10.h),
              ErrorTexts(
                firstnameError: firstnameError,
                lastnameError: lastnameError,
                emailError: emailError,
                passwordError: passwordError,
                confirmationPasswordError: confirmationPasswordError,
              ),
              SizedBox(height: 20.h),
              _SignUpButton(
                isRegistering: isRegistering,
                onRegister: onRegister,
                screenHeight: screenHeight,
                screenWidth: screenWidth,
                firstnameError: firstnameError,
                lastnameError: lastnameError,
                emailError: emailError,
                passwordError: passwordError,
                confirmationPasswordError: confirmationPasswordError,
              ),
            ],
          ),
        ),
        SizedBox(height: 40.h),
        SizedBox(
          width: screenWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Έχεις ήδη λογαριασμό;',
                style: TextStyle(
                  color: const Color.fromARGB(104, 255, 255, 255),
                  fontSize: 16.sp,
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
                    decorationThickness: 1.sp,
                    decorationColor: const Color.fromARGB(200, 255, 255, 255),
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 60.h)
      ],
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
    required this.obscureText,
    required this.toggleVisibility,
    required this.showIcon,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String hintText;
  final double screenHeight;
  final bool showIcon;
  final double screenWidth;
  final bool isRegistering;
  final bool obscureText;
  final VoidCallback toggleVisibility;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: 15.h, left: screenWidth * 0.15, right: screenWidth * 0.15),
      child: Container(
        padding: EdgeInsets.only(top: showIcon ? 7.h : 0),
        decoration: BoxDecoration(
          color: const Color.fromARGB(96, 63, 63, 63),
          border: Border.all(
            color: const Color.fromARGB(118, 88, 88, 88),
          ),
          borderRadius: BorderRadius.circular(5.r),
        ),
        child: TextField(
          keyboardType:
              hintText == 'Τηλέφωνο(+30)' ? TextInputType.number : null,
          obscureText: obscureText,
          readOnly: isRegistering,
          controller: controller,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          cursorColor: const Color.fromARGB(125, 244, 67, 54),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(10.sp),
            suffixIcon: showIcon
                ? Padding(
                    padding: EdgeInsets.only(right: 5.sp),
                    child: IconButton(
                      onPressed: toggleVisibility,
                      icon: Icon(
                        size: 17.sp,
                        obscureText ? Icons.visibility_off : Icons.visibility,
                        color: const Color(0xFF9C0C04),
                      ),
                    ),
                  )
                : null,
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF9C0C04)),
            ),
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 15.sp,
              color: const Color.fromARGB(75, 255, 255, 255),
            ),
          ),
          inputFormatters: inputFormatters,
        ),
      ),
    );
  }
}

class _SignUpButton extends StatelessWidget {
  const _SignUpButton({
    required this.isRegistering,
    required this.onRegister,
    required this.screenHeight,
    required this.screenWidth,
    required this.firstnameError,
    required this.lastnameError,
    required this.emailError,
    required this.passwordError,
    required this.confirmationPasswordError,
  });

  final bool isRegistering;
  final double screenHeight;
  final double screenWidth;
  final VoidCallback onRegister;

  // Error states
  final bool firstnameError;
  final bool lastnameError;
  final bool emailError;
  final bool passwordError;
  final bool confirmationPasswordError;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        isRegistering
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9C0C04)),
              )
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding:
                      EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.r),
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
                    fontSize: 15.sp,
                  ),
                )),
      ],
    );
  }
}

class ErrorTexts extends StatelessWidget {
  const ErrorTexts({
    super.key,
    required this.firstnameError,
    required this.lastnameError,
    required this.emailError,
    required this.passwordError,
    required this.confirmationPasswordError,
  });

  // Error states
  final bool firstnameError;
  final bool lastnameError;
  final bool emailError;
  final bool passwordError;
  final bool confirmationPasswordError;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ScreenUtil().screenWidth * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (firstnameError || lastnameError)
            const _ErrorText(
              text: '- Μόνο γράμματα στο ονοματεπώνυμο',
            ),
          if (emailError)
            const _ErrorText(
              text: '- Δεν βρέθηκε το email',
            ),
          if (passwordError)
            const _ErrorText(
              text:
                  '- Τουλάχιστον 4 λατινικοί χαρακτήρες\n  και 1 αριθμός στον κωδικό',
            ),
          if (confirmationPasswordError)
            const _ErrorText(
              text: '- Οι κωδικοί δεν ταιριάζουν',
            ),
        ],
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText({
    required this.text,
  });
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          fontSize: 13.sp,
          color: const Color(0xFF9C0C04),
          fontWeight: FontWeight.w500),
    );
  }
}

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70.h,
      width: double.infinity,
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
    required this.isRegistering,
  });

  final bool isCheckBoxPressed;
  final Function toggleCheckBox;
  final bool isRegistering;

  @override
  State<CheckBoxWidget> createState() => _CheckBoxWidgetState();
}

class _CheckBoxWidgetState extends State<CheckBoxWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: ScreenUtil().screenWidth * 0.15),
        Transform.scale(
          scale: 1.sp,
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
              if (!widget.isRegistering) {
                setState(() {
                  widget.toggleCheckBox();
                });
              }
            },
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              widget.toggleCheckBox();
            });
          },
          child: Text(
            ' Συμφωνώ με τους ',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13.sp),
          ),
        ),
        GestureDetector(
          onTap: () {
            launchUrl(Uri.parse('https://mypr-app.com/terms-of-use/'),
                mode: LaunchMode.externalApplication);
          },
          child: Text(
            'όρους χρήσης',
            style: TextStyle(
                decoration: TextDecoration.underline,
                decorationColor: const Color.fromARGB(200, 255, 255, 255),
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13.sp),
          ),
        )
      ],
    );
  }
}
