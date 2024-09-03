import 'package:flutter/material.dart';

class ReservationProvider with ChangeNotifier {
  List<dynamic> reservationInfo = [
    -1, // User ID
    '', // Reservation Name
    '', // Club Name
    1, // Number of Persons
    0.0, // Total Price
    0, // Number of Regular Bottles (Απλή)
    0, // Number of Special Bottles
    0, // Number of Premium Bottles
    '', // Reservation Date
    '', // Comment
    0, // Discount Percentage
  ];

  int _maxPersons = 1; // Initialize with a default value of 1

  // Getter for maxPersons
  int get maxPersons => _maxPersons;

  // Setter for maxPersons with notification to listeners
  void setMaxPersons(int value) {
    if (value > 0) {
      _maxPersons = value;
    } else {
      _maxPersons = 1; // Ensure the minimum value is 1
    }
    notifyListeners();
  }

  // Get information from the reservationInfo list
  dynamic getInfo(int index) {
    return reservationInfo[index];
  }

  // Set information in the reservationInfo list and notify listeners
  void setInfo(int index, dynamic value) {
    reservationInfo[index] = value;
    notifyListeners();
  }

  // Update information in the reservationInfo list and notify listeners
  void updateInfo(int index, dynamic value) {
    reservationInfo[index] = value;
    notifyListeners();
  }

  // Reset the reservation info to default values
  void resetInfo() {
    reservationInfo = [
      -1, // User ID
      '', // Reservation Name
      '', // Club Name
      1, // Number of Persons
      0.0, // Total Price
      0, // Number of Regular Bottles (Απλή)
      0, // Number of Special Bottles
      0, // Number of Premium Bottles
      '', // Reservation Date
      '', // Comment
      0, // Discount Percentage
    ];
    _maxPersons = 1; // Reset maxPersons to its default value
    notifyListeners();
  }
}
