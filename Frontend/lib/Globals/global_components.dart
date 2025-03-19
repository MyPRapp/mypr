import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mypr/Globals/constants.dart';
import 'package:mypr/Providers/user_provider.dart';
import 'package:mypr/services/auth_service.dart';
import 'package:mypr/services/message_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Providers/global_state_provider.dart';
import '../routes/app_router.gr.dart';

OtpService emailOtpService = OtpService();
OtpService phoneOtpService = OtpService();

class NoEmojisTextInputFormatter extends TextInputFormatter {
  // RegExp to allow Greek and English letters, numbers, and specific symbols
  final RegExp _allowedCharacters =
      RegExp(r'^[\p{L}\p{N}\p{P}!@#$%^&*(){}]+$', unicode: true);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Allow empty or identical values (e.g., backspace, autofill)
    if (newValue.text.isEmpty || newValue.text == oldValue.text) {
      return newValue;
    }

    // Filter the text, allowing only the characters that match the RegExp
    final filteredText = newValue.text.characters.where((char) {
      return _allowedCharacters.hasMatch(char);
    }).join();

    // Calculate the new selection position, ensuring it's within bounds
    final newSelectionIndex =
        newValue.selection.baseOffset.clamp(0, filteredText.length);

    // Return the updated TextEditingValue with the filtered text and adjusted selection
    return TextEditingValue(
      text: filteredText,
      selection: TextSelection.collapsed(offset: newSelectionIndex),
    );
  }
}

class AllowSpacesNoEmojisTextInputFormatter extends TextInputFormatter {
  // RegExp to allow Greek and English letters, numbers, spaces, and specific symbols
  final RegExp _allowedCharacters =
      RegExp(r'^[\p{L}\p{N}\p{P}\s!@#$%^&*(){}]+$', unicode: true);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Allow autofill to work properly by not blocking complete input replacements
    if (newValue.text.isEmpty ||
        newValue.text == oldValue.text ||
        _allowedCharacters.hasMatch(newValue.text)) {
      return newValue;
    }

    // If the new value contains restricted characters, return the old value
    return oldValue;
  }
}

Future<void> createFilePath() async {
  final directory = await getApplicationDocumentsDirectory();
  final Directory myprDirectory = Directory('${directory.path}/mypDirectory');

  // Create the new folder if it doesn't exist
  if (await myprDirectory.exists() == false) {
    await myprDirectory.create(recursive: true);
    successPrint('Folder created: ${myprDirectory.path}');
  } else {
    successPrint('Folder ${myprDirectory.path} already exists');
  }
}

Future<String> getFilePath(String fileName) async {
  final directory = await getApplicationDocumentsDirectory();
  final Directory myprDirectory = Directory('${directory.path}/mypDirectory');

  // Create the new folder if it doesn't exist
  if (await myprDirectory.exists() == false) {
    await myprDirectory.create(recursive: true);
    successPrint('Folder created: ${myprDirectory.path}');
  }

  return '${directory.path}/mypDirectory/$fileName.json';
}

String formatName(String name) {
  // Trim any leading/trailing spaces and replace multiple spaces with a single space
  return name.trim().replaceAll(RegExp(r'\s+'), ' ').split(' ').map((word) {
    if (word.isNotEmpty) {
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    }
    return word;
  }).join(' ');
}

Future<String> getSavedPassword() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getString('savedPassword') != null) {
    return prefs.getString('savedPassword')!;
  } else {
    return '';
  }
}

Future<String> getSavedEmail() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getString('savedEmail') != null) {
    return prefs.getString('savedEmail')!;
  } else {
    return '';
  }
}

void successPrint(String text) {
  print('✅$text');
}

void warningPrint(String text) {
  print('🟡$text');
}

void errorPrint(String text) {
  print('❌$text');
}

String normalizePhoneNumber(String phoneNumber) {
  if (phoneNumber.startsWith('+30')) {
    return phoneNumber.substring(3);
  } else if (phoneNumber.startsWith('(+30)')) {
    return phoneNumber.substring(5);
  } else if (phoneNumber.startsWith('30')) {
    return phoneNumber.substring(2);
  }
  return phoneNumber;
}

/// Builds a section title.
Widget buildTitle(String title) {
  return Text(
    title,
    style: TextStyle(
      fontSize: 20.sp,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    ),
  );
}

AppBar buildAppBar(BuildContext context, String title) {
  return AppBar(
    toolbarHeight: 60.h,
    leadingWidth: 50.w,
    iconTheme: IconThemeData(
      color: Colors.white,
      size: 30.sp,
    ),
    titleTextStyle: TextStyle(
        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20.sp),
    centerTitle: false,
    backgroundColor: Colors.black,
    title: Text(
      title,
    ),
    leading: IconButton(
      icon: const Icon(
        Icons.chevron_left,
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    ),
  );
}

class BannedBanner extends StatelessWidget {
  const BannedBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 255, 187, 0),
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
      child: Text(
        'Ο λογαριασμός σου είναι αποκλεισμένος και δεν μπορείς να προβείς σε κρατήσεις προς το παρών',
        style: TextStyle(
          fontSize: 12.sp,
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class EmailConfirmationNotification extends StatelessWidget {
  final String text;

  const EmailConfirmationNotification({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 255, 187, 0),
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          TextButton(
            onPressed: () {
              sendVerificationEmail(context);
            },
            child: Text(
              'Επαναποστολή',
              style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationThickness: 2),
            ),
          ),
        ],
      ),
    );
  }
}

class BuildSignInOrRegisterButton extends StatelessWidget {
  const BuildSignInOrRegisterButton({
    super.key,
    required this.context,
  });

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          AutoRouter.of(context).replaceAll([const SignUpRoute()]);
        },
        style: ElevatedButton.styleFrom(
          elevation: 10,
          foregroundColor: const Color.fromARGB(255, 0, 0, 0),
          backgroundColor:
              const Color.fromARGB(255, 217, 217, 217), // Text color
          minimumSize: Size(25.w, 60.h), // Button size
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
            side: const BorderSide(
              width: 4,
              color: Color.fromARGB(255, 0, 0, 0), // Border color
            ),
          ),
        ),
        child: Text(
          'Εγγραφή / Σύνδεση',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

void showFloatingSnackBar(
    String message, Duration duration, BuildContext context) {
  floatingSnackBar(
      message: message,
      context: context,
      duration: duration,
      backgroundColor: const Color.fromARGB(255, 70, 6, 1),
      textStyle: TextStyle(fontSize: 14.sp, color: Colors.white));
}

// Utility function to compare two version strings
int compareVersions(String currentVersion, String minimumVersion) {
  List<String> currentParts = currentVersion.split('.'); // Split by '.'
  List<String> minimumParts = minimumVersion.split('.');

  for (int i = 0; i < 3; i++) {
    int currentPart = int.parse(currentParts[i]);
    int minimumPart = int.parse(minimumParts[i]);

    if (currentPart > minimumPart) {
      return 1; // Current version is newer
    } else if (currentPart < minimumPart) {
      return -1; // Current version is older
    }
  }
  return 0; // Versions are equal
}

Future<String> getCurrentAppVersion() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version; // Get the current version (e.g., "1.0.0")
}

Future<void> checkAppVersion(BuildContext context) async {
  String currentVersion = await getCurrentAppVersion();

  int comparison = 0;
  if (Platform.isAndroid) {
    comparison =
        await checkPlatformVersion(currentVersion, 'version_control_android');
  } else if (Platform.isIOS) {
    comparison =
        await checkPlatformVersion(currentVersion, 'version_control_ios');
  } else {
    comparison = -1;
  }

  if (comparison < 0 && context.mounted) {
    // If the current version is older than the minimum version
    showUpdateDialog(context);
    errorPrint('App must be updated');
  } else if (context.mounted) {
    context.read<GlobalStateProvider>().hasCheckedAppVersion;
    successPrint('Your app is up-to-date!');
    //TODO Fix this from showing if can t retrieve app version from backend
  }
}

void showUpdateDialog(context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color.fromARGB(255, 141, 14, 5),
      shadowColor: appRedColor,
      elevation: 30,
      title: Text('Νέα έκδοση διαθέσιμη!',
          style: TextStyle(
              fontSize: 25.sp,
              color: Colors.black,
              fontWeight: FontWeight.bold)),
      content: Text(
        'Παρακαλώ ενημέρωσε την εφαρμογή για να συνεχίσεις.',
        style: TextStyle(
            fontSize: 20.sp, color: Colors.black, fontWeight: FontWeight.w500),
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.all(10.sp), // Custom padding
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r), // Rounded corners
            ),
            elevation: 10, // Shadow depth
            // ignore: deprecated_member_use
            shadowColor: Colors.black.withOpacity(0.5), // Shadow color
            backgroundColor: Colors.black, // Default background color
          ),
          onPressed: openStore,
          child: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Colors.red, appRedColor], // Gradient for text color
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              'Ενημέρωση',
              style: TextStyle(
                fontSize: 25.sp,
                color: Colors
                    .white, // Placeholder color (overwritten by ShaderMask)

                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

// Function to open the Play Store or App Store
Future<void> openStore() async {
  String url;
  if (Platform.isAndroid) {
    // Android: Play Store URL with the app package ID
    url = 'https://play.google.com/store/apps/details?id=com.etairia.mypr';
  } else if (Platform.isIOS) {
    // iOS: Play Store URL with the app ID
    url = 'https://apps.apple.com/gr/app/mypr/id6711330363';
  } else {
    throw 'Unsupported platform';
  }

  final Uri uri = Uri.parse(url); // Create a Uri object
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri); // Use launchUrl instead of launch
  } else {
    throw 'Could not launch $url';
  }
}

class TermsAndPrivacyPolicy extends StatelessWidget {
  const TermsAndPrivacyPolicy({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            launchUrl(Uri.parse('https://mypr-app.com/terms-of-use/'),
                mode: LaunchMode.externalApplication);
          },
          child: Text(
            'Όροι χρήσης',
            style: TextStyle(
              decoration: TextDecoration.underline,
              color: Colors.grey,
              decorationColor: const Color.fromARGB(200, 255, 255, 255),
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          ' & ',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        GestureDetector(
          onTap: () {
            launchUrl(Uri.parse('https://mypr-app.com/privacy-policy/'),
                mode: LaunchMode.externalApplication);
          },
          child: Text(
            'πολιτική απορρήτου',
            style: TextStyle(
              decoration: TextDecoration.underline,
              decorationColor: const Color.fromARGB(200, 255, 255, 255),
              color: Colors.grey,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class CustomPhoneButton extends StatefulWidget {
  const CustomPhoneButton({
    super.key,
  });

  @override
  CustomPhoneButtonState createState() => CustomPhoneButtonState();
}

class CustomPhoneButtonState extends State<CustomPhoneButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Container(
        width: 130.w,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 47, 47, 47),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: TextButton(
          onPressed: () async {
            if (!phoneOtpService.canSend) {
              if (phoneOtpService.awaitMinutes == 1) {
                showFloatingSnackBar(
                    'Ξαναδοκίμασε σε 1 λεπτό', Duration(seconds: 4), context);
              } else {
                showFloatingSnackBar(
                    'Ξαναδοκίμασε σε ${phoneOtpService.awaitMinutes} λεπτά',
                    Duration(seconds: 4),
                    context);
              }
            } else {
              var isPhoneValid = await showFillPhoneDialog(context);
              if (isPhoneValid.isSuccess) {
                var phone = isPhoneValid.phone;
                if (phone.length == 10 && phone.startsWith('69')) {
                  int result = await changePhoneOnServerOnly(phone);
                  if (result == 0) {
                    if (context.mounted) {
                      context.read<UserProvider>().fetchUserDetailsFromServer();
                      context.read<GlobalStateProvider>().refreshProfilePage =
                          true;
                      Navigator.pop(context);
                      showFloatingSnackBar('Επιτυχής προσθήκη κινητού',
                          Duration(seconds: 4), context);
                    }
                  } else {
                    if (result == 2) {
                      if (context.mounted) {
                        Navigator.pop(context);
                        showFloatingSnackBar(
                            'Αυτός ο αριμός τηλεφώνου χρησιμοποιείται ήδη',
                            Duration(seconds: 4),
                            context);
                      }
                    }
                  }
                } else {
                  if (context.mounted) {
                    showFloatingSnackBar(
                        'Υπήρξε κάποιο πρόβλημα. Προσπάθησε ξανά σε λίγο',
                        Duration(seconds: 4),
                        context);
                  }
                }
              }
            }
          },
          style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              overlayColor: const Color.fromARGB(255, 0, 0, 0)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                "Προσθήκη κινητού",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.black,
                size: 15.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomEmailButton extends StatefulWidget {
  final String label;

  const CustomEmailButton({
    super.key,
    required this.label,
  });

  @override
  CustomEmailButtonState createState() => CustomEmailButtonState();
}

class CustomEmailButtonState extends State<CustomEmailButton> {
  bool isExpanded = false;
  final TextEditingController _controller = TextEditingController();

  void _toggleExpansion() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        width: isExpanded ? 400.w : 130.w,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 47, 47, 47),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: isExpanded
            ? Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Πληκτρολόγησε το νέο email',
                        hintStyle:
                            TextStyle(color: Colors.grey, fontSize: 12.sp),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10.w),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.white, size: 15.sp),
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(_controller.text)) {
                        showFloatingSnackBar(
                            "Λάθος μορφή email", Duration(seconds: 3), context);
                        _controller.clear();
                        _toggleExpansion();
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      }
                      if (_controller.text ==
                          context.read<UserProvider>().userDetails.email) {
                        showFloatingSnackBar("Το email χρησιμοποιείται ήδη",
                            Duration(seconds: 3), context);
                        _controller.clear();
                        _toggleExpansion();
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      }

                      int success = 1;
                      if (context.mounted) {
                        success =
                            await changeEmailOnServerOnly(_controller.text);
                      }
                      if (success == 0 && context.mounted) {
                        context.read<GlobalStateProvider>().hasVerifiedEmail =
                            false;
                      } else {
                        if (success == 2) {
                          if (context.mounted) {
                            showFloatingSnackBar(
                                "Το email χρησιμοποιείται ήδη ή δεν υπάρχει",
                                Duration(seconds: 3),
                                context);
                          }
                        } else {
                          if (success == 1) {
                            if (context.mounted) {
                              showFloatingSnackBar(
                                  "Υπήρξε κάποιο σφάλμα. Δοκιμάστε ξανά σε λίγο",
                                  Duration(seconds: 3),
                                  context);
                            }
                          }
                        }
                        _controller.clear();
                        _toggleExpansion();
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      }
                      if (success == 0 &&
                          context.mounted &&
                          context
                              .read<GlobalStateProvider>()
                              .hasVerifiedEmail) {
                        showFloatingSnackBar(
                            "Υπήρξε κάποιο σφάλμα. Δοκιμάστε ξανά σε λίγο",
                            Duration(seconds: 3),
                            context);
                        _controller.clear();

                        _toggleExpansion();
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      }

                      if (await resendVerificationEmail()) {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.setString('savedPassword', '');
                        if (context.mounted) {
                          context
                              .read<GlobalStateProvider>()
                              .refreshProfilePage = true;
                          showFloatingSnackBar("Στάλθηκε email επιβεβαίωσης",
                              Duration(seconds: 3), context);
                        }
                      } else {
                        if (context.mounted) {
                          showFloatingSnackBar(
                              "Υπήρξε κάποιο σφάλμα στην αποστολή του email επιβεβαίωσης",
                              Duration(seconds: 3),
                              context);
                        }
                      }
                      _controller.clear();
                      _toggleExpansion();
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              )
            : TextButton(
                onPressed: _toggleExpansion,
                style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    overlayColor: const Color.fromARGB(255, 0, 0, 0)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.black,
                      size: 15.sp,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

int generateRandom6DigitNumber() {
  Random random = Random();
  int min = 100000;
  int max = 999999;
  return min + random.nextInt(max - min + 1);
}

Future<IsPhoneValid> showFillPhoneDialog(BuildContext context) async {
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
      showFloatingSnackBar(
          'Ξαναδοκίμασε σε 1 λεπτό', Duration(seconds: 4), context);
    } else {
      showFloatingSnackBar(
          'Ξαναδοκίμασε σε ${phoneOtpService.awaitMinutes} λεπτά',
          Duration(seconds: 4),
          context);
    }
    return IsPhoneValid('', false);
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
                        style: TextStyle(color: Colors.white, fontSize: 15.sp),
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
                        style: TextStyle(color: Colors.white, fontSize: 15.sp),
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
                ElevatedButton(
                    onPressed: () async {
                      // Phone validation
                      tempPhoneNumber = normalizePhoneNumber(phoneInput);
                      phoneError = tempPhoneNumber.length != 10 ||
                          !tempPhoneNumber.startsWith('69');
                      if (phoneError == false) {
                        if (!phoneOtpService.canSend) {
                          if (phoneOtpService.awaitMinutes == 1) {
                            showFloatingSnackBar('Ξαναδοκίμασε σε 1 λεπτό',
                                const Duration(milliseconds: 4000), context);
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
                        if (context.mounted) {
                          if (phoneError == true) {
                            await Future.delayed(const Duration(seconds: 2));
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
                      style: TextStyle(color: Colors.white, fontSize: 13.sp),
                    )),
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
                            if (context.mounted) {
                              Navigator.of(context).pop(true);
                            }
                          } else {
                            if (attemptCount >= 2) {
                              showFloatingSnackBar(
                                  'Ο αριθμός κινητού δεν επιβεβαιώθηκε',
                                  Duration(seconds: 4),
                                  context);
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
                            if (context.mounted) {
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
                        style: TextStyle(color: Colors.white, fontSize: 13.sp),
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
  var result = IsPhoneValid(tempPhoneNumber, isCodeValid);
  return result;
}

class IsPhoneValid {
  final String phone;
  final bool isSuccess;
  IsPhoneValid(this.phone, this.isSuccess);
}

Future<void> emailLoop(BuildContext context) async {
  final startTime = DateTime.now();

  while (context.mounted &&
      !context.read<GlobalStateProvider>().hasVerifiedEmail) {
    // Check if 5 minutes (300 seconds) have passed since start
    final elapsedTime = DateTime.now().difference(startTime);
    if (elapsedTime.inSeconds >= 600) {
      // Exit the loop if 10 minutes have passed
      break;
    }

    // Fetch email verification status
    if (context.mounted) {
      fetchVerifiedEmailGlobalVariable(context);
    }

    // Wait for 5 seconds before the next iteration
    await Future.delayed(Duration(seconds: 5));
  }
}
