import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mypr/Globals/constants.dart';
import 'package:mypr/Globals/global_components.dart';
import 'package:mypr/Providers/global_state_provider.dart';
import 'package:mypr/Providers/user_provider.dart';
import 'package:mypr/routes/app_router.gr.dart';
import 'package:provider/provider.dart';

@RoutePage()
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  bool _isObscure = true;
  bool _isLoginPressed = false;

  @override
  void initState() {
    super.initState();

    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    _autofillCredentials();
  }

  Future<void> _login() async {
    FocusManager.instance.primaryFocus?.unfocus();

    //Check if something is missing
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      showFloatingSnackBar('Παρακαλώ συμπλήρωσε όλα τα πεδία',
          const Duration(milliseconds: 4000), context);

      return;
    }

    warningPrint('------------LOGGING IN------------');

    setState(() {
      _isLoginPressed = true;
    });

    //Attempting to login
    final int loginResultCode = await context.read<UserProvider>().login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

    if (loginResultCode == 0) {
      if (mounted) {
        await context.read<GlobalStateProvider>().setHasLoggedIn(true);
        if (!mounted) {
          return;
        }
        context.router.replaceAll([const BottomNavBarRoute()]);
        successPrint('------------LOGGED IN------------');
      }
    } else {
      _handleLoginFailure(loginResultCode);
      errorPrint('------------LOGIN FAILED------------');
    }

    setState(() {
      _isLoginPressed = false;
    });
  }

  void _handleLoginFailure(int loginResultCode) {
    final String message = loginResultCode == 1
        ? 'Λάθος στοιχεία εισόδου'
        : 'Προέκυψε κάποιο σφάλμα. Παρακαλώ ξανα δοκίμασε αργότερα';

    showFloatingSnackBar(message, const Duration(milliseconds: 4000), context);
  }

//TODO Check if we need credentials to be saved after sign out
  void _autofillCredentials() async {
    _emailController.text = await getSavedEmail();
    _passwordController.text = await getSavedPassword();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          backgroundColor: Colors.black,
          resizeToAvoidBottomInset: false,
          body: LoginBody(
            isLoginPressed: _isLoginPressed,
            emailController: _emailController,
            passwordController: _passwordController,
            isObscure: _isObscure,
            onLogin: _login,
            onTogglePasswordVisibility: _togglePasswordVisibility,
          ),
        ),
      ),
    );
  }
}

class LoginBody extends StatelessWidget {
  final bool isLoginPressed;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isObscure;
  final VoidCallback onLogin;
  final VoidCallback onTogglePasswordVisibility;

  const LoginBody({
    super.key,
    required this.isLoginPressed,
    required this.emailController,
    required this.passwordController,
    required this.isObscure,
    required this.onLogin,
    required this.onTogglePasswordVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Color.fromARGB(255, 68, 3, 3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              SizedBox(height: ScreenUtil().statusBarHeight + 10.h),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  if (!isLoginPressed) {
                    AutoRouter.of(context)
                        .replaceAll([const BottomNavBarRoute()]);
                  }
                },
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 10.w),
                    child: Container(
                      padding: EdgeInsets.all(5.sp),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color.fromARGB(255, 105, 105, 105)),
                          borderRadius: BorderRadius.circular(5.r)),
                      child: Text('Παράλειψη',
                          style: TextStyle(
                              color: const Color.fromARGB(255, 133, 132, 132),
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp)),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 50.h),
              const LoginLogo(
                text: '',
                color: Colors.white,
              ),
              SizedBox(height: 80.h),
              LoginTextField(
                  controller: emailController,
                  hintText: 'Email/Τηλέφωνο(+30)',
                  isLoginPressed: isLoginPressed,
                  isObscure: isObscure,
                  onTogglePasswordVisibility: onTogglePasswordVisibility,
                  showIcon: false),
              SizedBox(height: 20.h),
              LoginTextField(
                controller: passwordController,
                hintText: 'Κωδικός',
                isLoginPressed: isLoginPressed,
                isObscure: isObscure,
                onTogglePasswordVisibility: onTogglePasswordVisibility,
                showIcon: true,
              ),
              SizedBox(height: 50.h),
              LoginFooter(
                isLoginPressed: isLoginPressed,
                onLogin: onLogin,
              ),
            ],
          ),
          ForgotPasswordAndSignUp(
            isLoginPressed: isLoginPressed,
          ),
        ],
      ),
    );
  }
}

class LoginLogo extends StatelessWidget {
  final String text;
  final Color color;
  const LoginLogo({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          text,
          style: TextStyle(
              color: color, fontSize: 18.sp, fontWeight: FontWeight.w800),
        ),
        SizedBox(
          height: 80.h,
          child: const Image(
            alignment: Alignment.center,
            image: AssetImage(
                'assets/otherPhotos/Logo_v2.2-removebg(cropped).png'),
            fit: BoxFit.scaleDown,
          ),
        ),
      ],
    );
  }
}

class LoginTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isObscure;
  final bool isLoginPressed;
  final bool showIcon;
  final VoidCallback onTogglePasswordVisibility;

  const LoginTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.isLoginPressed,
    required this.onTogglePasswordVisibility,
    required this.showIcon,
    required this.isObscure,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtil().screenWidth - 80.w,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: const Color.fromARGB(133, 84, 84, 84)),
      child: TextField(
        readOnly: isLoginPressed,
        controller: controller,
        obscureText: showIcon && isObscure,
        cursorColor: const Color.fromARGB(125, 244, 67, 54),
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color.fromARGB(132, 200, 200, 200),
            ),
            border: InputBorder.none,
            suffixIcon: showIcon
                ? IconButton(
                    onPressed: onTogglePasswordVisibility,
                    icon: Icon(
                      size: 20.sp,
                      isObscure ? Icons.visibility_off : Icons.visibility,
                      color: appRedColor,
                    ),
                  )
                : null),
      ),
    );
  }
}

class ForgotPasswordAndSignUp extends StatelessWidget {
  final bool isLoginPressed;

  const ForgotPasswordAndSignUp({
    super.key,
    required this.isLoginPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Πρώτη φορά εδώ;',
              style: TextStyle(
                color: const Color.fromARGB(104, 255, 255, 255),
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton(
              onPressed: () {
                if (!isLoginPressed) {
                  AutoRouter.of(context).replaceAll([const SignUpRoute()]);
                }
              },
              child: Text(
                'Κάνε εγγραφή',
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
        /*
       SizedBox(
          child: Text(
            textAlign: TextAlign.center,
            'ή',
            style: TextStyle(
              color: const Color.fromARGB(104, 255, 255, 255),
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ), 
        */
        /*  SizedBox(
          height: 15.h,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Ξέχασες τον κωδικό;',
              style: TextStyle(
                color: const Color.fromARGB(104, 255, 255, 255),
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton(
              onPressed: () {
                if (!isLoginPressed) {
                  AutoRouter.of(context).push(const ContactUsRoute());
                }
              },
              child: Text(
                'Στείλε μήνυμα',
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
        ), */
        /* 
        TextButton(
          onPressed: () {
            if (!isLoginPressed) {
              showFloatingSnackBar(
               'Στάλθηκε email για επαναφορά κωδικού',
                const Duration(milliseconds: 4000), context);
            }
          },
          child: Text(
            'Επαναφορά κωδικού',
            style: TextStyle(
              decoration: TextDecoration.underline,
              decorationThickness: 1.sp,
              decorationColor: const Color.fromARGB(157, 255, 255, 255),
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        */
        SizedBox(height: 60.h)
      ],
    );
  }
}

class LoginFooter extends StatelessWidget {
  final bool isLoginPressed;
  final VoidCallback onLogin;

  const LoginFooter({
    super.key,
    required this.isLoginPressed,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          minimumSize: Size(38.w, 38.h),
          backgroundColor: isLoginPressed ? Colors.transparent : appRedColor,
        ),
        onPressed: onLogin,
        child: isLoginPressed
            ? Transform.scale(
                scale: 0.7.sp,
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(appRedColor),
                ),
              )
            : Icon(
                Icons.arrow_forward,
                color: Colors.black,
                size: 25.sp,
              ));
  }
}
