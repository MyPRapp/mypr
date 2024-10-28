import 'dart:convert';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:mypr/Globals/constants.dart';
import 'package:mypr/services/auth_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Providers/global_state_provider.dart';
import '../routes/app_router.gr.dart';

String apiUrl = 'http://${GlobalStateProvider().validatedIp}/api';

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

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color.fromARGB(197, 40, 40, 40),
      body: Center(
        child: SpinKitRing(
          color: Color(0xFF9C0C04),
          size: 50.0,
        ),
      ),
    );
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

void printReservationInfo(List<dynamic> reservationInfo) {
  print('\x1B[37mReservation Info:');
  print('UserID: ${reservationInfo[0]}');
  print('ReservationName: ${reservationInfo[1]}');
  print('ClubName: ${reservationInfo[2]}');
  print('Persons: ${reservationInfo[3]}');
  print('Price: ${reservationInfo[4]}');
  print('Regular: ${reservationInfo[5]}');
  print('Special: ${reservationInfo[6]}');
  print('Premium: ${reservationInfo[7]}');
  print('Date: ${reservationInfo[8]}');
  print('Comment: ${reservationInfo[9]}');
  print('Discount(%): ${reservationInfo[10]}');
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

class EmailConfirmationNotification extends StatelessWidget {
  final VoidCallback onResendEmail;
  final String text;

  const EmailConfirmationNotification(
      {super.key, required this.onResendEmail, required this.text});

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
          GestureDetector(
            onTap: onResendEmail,
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

Future<void> fetchVerifiedEmailGlobalVariable(BuildContext context) async {
  var response = await http.get(
    Uri.parse('$apiUrl/user-auth-status/'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${await getAccessToken()}',
    },
  ).timeout(const Duration(seconds: 10));

  if (response.statusCode == 200) {
    successPrint(response.body);
    String jsonString = response.body;
    Map<String, dynamic> jsonData = jsonDecode(jsonString); // Decode JSON

    bool isVerified = jsonData['is_verified']; // Extract the boolean value
    if (context.mounted) {
      context.read<GlobalStateProvider>().hasVerifiedEmail = isVerified;
      return;
    }
    errorPrint('Not mounted');
  }
  errorPrint('${response.statusCode}');
  errorPrint(response.body);
  if (context.mounted) {
    context.read<GlobalStateProvider>().hasVerifiedEmail = false;
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

String minimumAndroidVersion =
    '1.0.0'; //TODO Remove these from code and get the minimum versions from server
String minimumIOSVersion = '1.0.0';
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
    comparison = compareVersions(currentVersion, minimumAndroidVersion);
  } else {
    if (Platform.isIOS) {
      comparison = compareVersions(currentVersion, minimumIOSVersion);
    } else {
      errorPrint('$comparison');
      comparison = -1;
    }
  }
  if (comparison < 0 && context.mounted) {
    // If the current version is older than the minimum version
    showUpdateDialog(context);
    errorPrint('App must be updated');
  } else {
    successPrint('Your app is up-to-date!');
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
      title: Text('Ενημέρωση διαθέσιμη!',
          style: TextStyle(
              fontSize: 25.sp,
              color: Colors.black,
              fontFamily: 'CALIBRI',
              fontWeight: FontWeight.bold)),
      content: Text(
        'Παρακαλώ ενημέρωσε την εφαρμογή για να συνεχίσεις.',
        style: TextStyle(
            fontSize: 20.sp,
            color: Colors.black,
            fontFamily: 'CALIBRI',
            fontWeight: FontWeight.w500),
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.all(10.sp), // Custom padding
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r), // Rounded corners
            ),
            elevation: 10, // Shadow depth
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
                fontFamily: 'CALIBRI',
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
    url =
        'https://play.google.com/store/apps/details?id=com.example.your_app_id';
  } else if (Platform.isIOS) {
    //TODO Change urls
    // iOS: App Store URL with the app ID
    url = 'https://apps.apple.com/app/id1234567890';
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
