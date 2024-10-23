import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    centerTitle: false,
    backgroundColor: Colors.black,
    title: Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
    leading: IconButton(
      icon: const Icon(
        Icons.chevron_left,
        color: Colors.white,
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
