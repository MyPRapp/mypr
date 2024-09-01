import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class ClubInfoStruct {
  int clubID;
  String clubName;
  int clubMinPrice;
  int clubMaxPersons;
  String clubPhone;
  String clubLocation;
  double clubRating;
  String clubAvailability;
  bool clubIsLiked;
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
    this.clubIsLiked = false,
    this.clubPhoto = '',
  });

  factory ClubInfoStruct.fromJson(Map<String, dynamic> json) {
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
  String password;
  String firstName;
  String lastName;
  String email;
  String phone;
  String photo; // This will now hold the base64 string instead of a URL

  UserInfoStruct({
    required this.userID,
    this.username = '',
    this.password = '',
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.phone = '',
    this.points = -1,
    this.photo = '', // Initialize as an empty string
  });

  factory UserInfoStruct.fromJson(Map<String, dynamic> json) {
    return UserInfoStruct(
        userID: json['id'] ?? -1,
        username: json['username'] ?? '',
        password: json['password'] ?? '',
        firstName: json['first_name'] ?? '',
        lastName: json['last_name'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        points: json['points'] ?? -1,
        photo: json['photo'] ?? ''); // Photo might be a base64 string
  }

  Map<String, dynamic> toJson() {
    return {
      'id': userID,
      'username': username,
      'password': password,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'points': points,
      'photo': photo, // Store the base64 string
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
    return CatalogueInfoStruct(
      clubID: json['club'] ?? -1,
      serviceType: json['service_type'] ?? '',
      price: json['price'] ?? '',
      maxPersons: json['max_person'] ?? -1,
    );
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
    return BookingInfoStruct(
      bookingID: json['bookingID'],
      userID: json['userID'],
      clubID: json['clubID'],
      bookingName: json['bookingName'],
      date: DateTime.parse(json['date']),
      persons: json['persons'],
      fourbitString: json['fourbitString'],
      price: json['price'],
      comments: json['comments'],
      status: json['status'],
    );
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
  // Trim leading and trailing spaces
  String trimmedName = name.trim();

  // Replace multiple spaces between words with a single space
  String formattedName = trimmedName.replaceAll(RegExp(r'\s+'), ' ');

  return formattedName;
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
  } catch (e) {
    print('Error in imageToBase64: $e');
    // Return a placeholder or an empty string in case of error
    return '';
  }
}

Future<bool> isConnectedToNetwork() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  // ignore: unrelated_type_equality_checks
  return connectivityResult != ConnectivityResult.none;
}
