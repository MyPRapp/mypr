import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mypr/Globals/classes.dart';
import 'package:mypr/Globals/constants.dart';
import 'package:mypr/Globals/global_components.dart';
import 'package:mypr/Providers/global_state_provider.dart';
import 'package:mypr/services/auth_service.dart';
import 'package:provider/provider.dart';

class OtpService {
  bool canSend = true;
  int awaitMinutes = 1;
  Timer? timer;

  Future<bool> sendOtp(
      String phoneNumber, int otpCode, BuildContext context) async {
    try {
      final response = await http
          .post(
            Uri.parse('$apiUrl/send-otp/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'phone_number': '+30$phoneNumber',
              'otp': otpCode,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 && context.mounted) {
        showFloatingSnackBar(
            'Στάλθηκε κωδικός με SMS', Duration(seconds: 3), context);

        startTimer();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  void startTimer() {
    if (timer != null && timer!.isActive) return;

    canSend = false;
    timer = Timer(Duration(minutes: awaitMinutes), () {
      awaitMinutes++;
      canSend = true;
    });
  }
}

Future<void> sendVerificationEmail(BuildContext context) async {
  if (emailOtpService.canSend) {
    emailOtpService.startTimer();

    var response = await http.post(
      Uri.parse('$apiUrl/email-resend/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getAccessToken()}',
      },
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      if (context.mounted) {
        showFloatingSnackBar('Στάλθηκε email επιβεβαίωσης',
            const Duration(milliseconds: 4000), context);
      }
      successPrint(response.body);
      if (context.mounted) {
        emailLoop(context);
      }
    } else {
      if (context.mounted) {
        showFloatingSnackBar('Υπήρξε κάποιο σφάλμα. Ξαναδοκίμασε σε λίγο',
            const Duration(milliseconds: 4000), context);
      }
      errorPrint('${response.statusCode}');
      errorPrint(response.body);
    }
  } else {
    if (emailOtpService.awaitMinutes == 1) {
      showFloatingSnackBar('Ξαναδοκίμασε σε 1 λεπτό',
          const Duration(milliseconds: 4000), context);
    } else {
      showFloatingSnackBar(
          'Ξαναδοκίμασε σε ${emailOtpService.awaitMinutes} λεπτά',
          const Duration(milliseconds: 4000),
          context);
    }
  }
}

Future<void> sendCancellationEmail(
    BuildContext context, String clubName, BookingInfoStruct booking) async {
  FocusManager.instance.primaryFocus?.unfocus();

  try {
    final response = await http
        .post(Uri.parse('$apiUrl/send-email/'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'subject': 'ΑΚΥΡΩΣΗ ΚΡΑΤΗΣΗΣ',
              'sender_email': 'info@mypr-app.com',
              'message':
                  'Ακυρώθηκε η κράτηση με bookingID: ${booking.bookingID} από τον χρήστη με ID: ${booking.userID}\nΜαγαζί: $clubName\nΌνομα κράτησης: ${booking.bookingName}\nΗμερομηνία κράτησης: ${booking.date}\nΚατηγορία: ${booking.fourbitString}\nΆτομα: ${booking.persons}\nΤιμή: ${booking.price}\n'
            }))
        .timeout(const Duration(seconds: 8), onTimeout: () {
      errorPrint('Error on email sending: Timeout exception');
      return http.Response('Error: Timeout', 408);
    });

    if (response.statusCode == 200) {
      if (context.mounted) {
        context.read<GlobalStateProvider>().mustSendCancellationEmail = '';
      }
      successPrint('Email sent successfully');
    } else {
      if (context.mounted) {
        context.read<GlobalStateProvider>().mustSendCancellationEmail =
            '$clubName || ${booking.bookingID}';
      }
      errorPrint('Error on email sending: ${response.body}');
    }
  } catch (e) {
    errorPrint('$e');
  }
}

Future<bool> sendEmail(
    String subject, String senderEmail, String message) async {
  final response = await http
      .post(
    Uri.parse('$apiUrl/send-email/'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'subject': subject,
      'sender_email': senderEmail,
      'message': message,
    }),
  )
      .timeout(const Duration(seconds: 8), onTimeout: () {
    errorPrint('Error on email sending: Timeout exception');
    return http.Response('Error: Timeout', 408);
  });

  if (response.statusCode == 200) {
    successPrint('Email sent successfully');
    return true;
  }
  errorPrint('Error on email sending: ${response.body}');
  return false;
}

Future<bool> resendVerificationEmail() async {
  final response = await http.post(
    Uri.parse('$apiUrl/email-resend/'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${await getAccessToken()}',
    },
  ).timeout(const Duration(seconds: 15));
  if (response.statusCode == 200) {
    successPrint(response.body);
    return true;
  }
  errorPrint('${response.statusCode}');
  errorPrint(response.body);
  return false;
}
