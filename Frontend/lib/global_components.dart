import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mypr/Providers/global_state_provider.dart';
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
      );
    } catch (e) {
      print('Error parsing ClubInfoStruct: $e');
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
      'clubPhoto': clubPhoto
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
    required this.userID,
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
      print('Error parsing UserInfoStruct: $e');
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
      print('Error parsing CatalogueInfoStruct: $e');
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
      print('Error parsing BookingInfoStruct: $e');
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

class BottomNavBarVisibility extends ChangeNotifier {
  bool _isVisible = true;

  bool get isVisible => _isVisible;

  void show() {
    _isVisible = true;
    notifyListeners();
  }

  void hide() {
    _isVisible = false;
    notifyListeners();
  }
}

class NoEmojisTextInputFormatter extends TextInputFormatter {
  // RegExp to allow Greek and English letters, numbers, and specific symbols
  final RegExp _allowedCharacters =
      RegExp(r'^[\p{L}\p{N}\p{P}!@#$%^&*(){}]+$', unicode: true);

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

String formatName(String name) {
  // Trim any leading/trailing spaces and replace multiple spaces with a single space
  return name.trim().replaceAll(RegExp(r'\s+'), ' ').split(' ').map((word) {
    if (word.isNotEmpty) {
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    }
    return word;
  }).join(' ');
}

Future<String> imageToBase64(String imageUrl) async {
  try {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      return base64Encode(bytes);
    } else {
      throw Exception('Failed to load image: ${response.statusCode}');
    }
  } catch (e, stackTrace) {
    print('Error in imageToBase64: $e');
    print('StackTrace: $stackTrace'); // Log the stack trace
    return ''; // Consider returning a default image or error code
  }
}

Future<ImageProvider?> loadUserPhoto(String photoPath) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? base64Photo = prefs.getString('user_photo');
    if (base64Photo != null) {
      final Uint8List bytes = base64Decode(base64Photo);
      return MemoryImage(bytes);
    }

    // Attempt to load from network
    return NetworkImage(
        'http://${GlobalStateProvider().validatedIp}:8000/$photoPath');
  } catch (e) {
    // Return null to indicate an error
    return null;
  }
}

/// Loads an image from a network URL, and if an error occurs, falls back to SharedPreferences.
Future<ImageProvider> loadClubPhoto(int clubID, String photoUrl) async {
  try {
    // Attempt to load the image from the network URL
    final response = await http.get(Uri.parse(photoUrl));

    if (response.statusCode == 200) {
      // If the network request is successful, return the network image
      return NetworkImage(photoUrl);
    } else {
      // If the response is not successful, throw an error to trigger the fallback
      throw Exception('Failed to load image from network');
    }
  } catch (e) {
    debugPrint('Error loading network image for club ID $clubID: $e');

    // Fallback: Try to load the image from SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final base64Image = prefs.getString('club_image_$clubID');

      if (base64Image != null) {
        // Decode and return the image from memory (from SharedPreferences)
        final Uint8List bytes = base64Decode(base64Image);
        return MemoryImage(bytes);
      } else {
        // If no image is found in SharedPreferences, return a default image
        return const AssetImage('assets/images/default_club_image.png');
      }
    } catch (prefsError) {
      // Log any error that occurs during the fallback and return a default image
      debugPrint(
          'Error loading fallback image from SharedPreferences: $prefsError');
      return const AssetImage('assets/images/default_club_image.png');
    }
  }
}

TextStyle textStyle1() {
  return const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}

TextStyle textStyle2() {
  return const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Color(0xFF9C0C04),
  );
}

void printReservationInfo(List<dynamic> reservationInfo) {
  print('Reservation Info:');
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
