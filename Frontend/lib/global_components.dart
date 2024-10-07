import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClubInfoStruct {
  int clubID;
  String clubName;
  int clubMinPrice;
  int clubMaxPersons;
  String clubPhone;
  String clubLocation;
  double clubRating;
  String clubAvailability;
  String clubPhoto;
  String localPhotoPath = ''; // Local file path to the downloaded photo
  String clubNotAvailable;

  ClubInfoStruct({
    required this.clubID,
    this.clubName = '',
    this.clubMinPrice = -1,
    this.clubMaxPersons = -1,
    this.clubPhone = '',
    this.clubLocation = '',
    this.clubRating = -1,
    this.clubAvailability = '',
    this.clubPhoto = '',
    this.clubNotAvailable = '',
  });

  factory ClubInfoStruct.fromJson(Map<String, dynamic> json) {
    try {
      return ClubInfoStruct(
          clubID: json['id'] ?? -1,
          clubName: json['club_name'] ?? '',
          clubMinPrice: json['min_price'] ?? -1,
          clubMaxPersons: json['max_persons'] ?? -1,
          clubPhone: json['phone'] ?? '',
          clubLocation: json['location'] ?? '',
          clubRating: json['rating'] != null
              ? double.tryParse(json['rating'].toString()) ?? -1
              : -1,
          clubAvailability: json['availability'] ?? '',
          clubPhoto: json['photo'] ?? '',
          clubNotAvailable: json['not_available'] ?? '');
    } catch (e) {
      print('\x1B[31mError parsing ClubInfoStruct: $e');
      return ClubInfoStruct(
          clubID: -1); // Return a default object with clubID -1
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': clubID,
      'club_name': clubName,
      'min_price': clubMinPrice,
      'max_persons': clubMaxPersons,
      'phone': clubPhone,
      'location': clubLocation,
      'rating': clubRating,
      'availability': clubAvailability,
      'photo': clubPhoto,
      'not_available': clubNotAvailable,
      'localPhotoPath': localPhotoPath,
    };
  }
}

class UserInfoStruct {
  int userID, points;
  String username;
  String firstName;
  String lastName;
  String email;
  String phone;
  String photo; // This will now hold the base64 string instead of a URL

  UserInfoStruct({
    this.userID = -1,
    this.username = '',
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.phone = '',
    this.points = -1,
    this.photo = '', // Initialize as an empty string
  });

  factory UserInfoStruct.fromJson(Map<String, dynamic> json) {
    try {
      return UserInfoStruct(
        userID: json['id'] ?? -1,
        username: json['username'] ?? '',
        firstName: json['first_name'] ?? '',
        lastName: json['last_name'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        points: json['points'] ?? -1,
        photo: json['photo'] ?? '',
      );
    } catch (e) {
      print('\x1B[31mError parsing UserInfoStruct: $e');
      return UserInfoStruct(
          userID: -1); // Return a default object with userID -1
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': userID,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'points': points,
      'photo': photo,
    };
  }
}

class CatalogueInfoStruct {
  int clubID;
  String serviceType;
  String price;
  int maxPersons;

  CatalogueInfoStruct({
    required this.clubID,
    required this.serviceType,
    required this.price,
    required this.maxPersons,
  });

  factory CatalogueInfoStruct.fromJson(Map<String, dynamic> json) {
    try {
      return CatalogueInfoStruct(
        clubID: json['club'] ?? -1,
        serviceType: json['service_type'] ?? '',
        price: json['price'] ?? '',
        maxPersons: json['max_person'] ?? -1,
      );
    } catch (e) {
      print('\x1B[31mError parsing CatalogueInfoStruct: $e');
      return CatalogueInfoStruct(
          clubID: -1,
          serviceType: '',
          price: '0',
          maxPersons: 0); // Return default object
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'club': clubID,
      'service_type': serviceType,
      'price': price,
      'max_person': maxPersons,
    };
  }
}

class BookingInfoStruct {
  final int bookingID;
  final int userID;
  final int clubID;
  final String bookingName;
  final DateTime date;
  final int persons;
  final String fourbitString;
  final double price;
  final String comments;
  final int status;

  BookingInfoStruct({
    required this.bookingID,
    required this.userID,
    required this.clubID,
    required this.bookingName,
    required this.date,
    required this.persons,
    required this.fourbitString,
    required this.price,
    required this.comments,
    required this.status,
  });

  factory BookingInfoStruct.fromJson(Map<String, dynamic> json) {
    try {
      return BookingInfoStruct(
        bookingID: json['bookingID'] ?? -1,
        userID: json['userID'] ?? -1,
        clubID: json['clubID'] ?? -1,
        bookingName: json['bookingName'] ?? '',
        date: DateTime.tryParse(json['date']) ?? DateTime.now(),
        persons: json['persons'] ?? 0,
        fourbitString: json['fourbitString'] ?? '',
        price: json['price'] != null
            ? double.tryParse(json['price'].toString()) ?? 0
            : 0,
        comments: json['comments'] ?? '',
        status: json['status'] ?? 0,
      );
    } catch (e) {
      print('\x1B[31mError parsing BookingInfoStruct: $e');
      return BookingInfoStruct(
        bookingID: -1,
        userID: -1,
        clubID: -1,
        bookingName: '',
        date: DateTime.now(),
        persons: 0,
        fourbitString: '',
        price: 0,
        comments: '',
        status: 0,
      ); // Return a default object with bookingID -1
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingID': bookingID,
      'userID': userID,
      'clubID': clubID,
      'bookingName': bookingName,
      'date': date.toIso8601String(),
      'persons': persons,
      'fourbitString': fourbitString,
      'price': price,
      'comments': comments,
      'status': status,
    };
  }
}

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
    print('\x1B[32mFolder created: ${myprDirectory.path}');
  } else {
    print('\x1B[32mFolder ${myprDirectory.path} already exists');
  }
}

Future<String> getFilePath(String fileName) async {
  final directory = await getApplicationDocumentsDirectory();
  final Directory myprDirectory = Directory('${directory.path}/mypDirectory');

  // Create the new folder if it doesn't exist
  if (await myprDirectory.exists() == false) {
    await myprDirectory.create(recursive: true);
    print('\x1B[32mFolder created: ${myprDirectory.path}');
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
