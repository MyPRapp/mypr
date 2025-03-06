import 'package:flutter/material.dart';
import 'package:mypr/Globals/classes.dart';

// class ReservationProvider with ChangeNotifier {
//   List<dynamic> _reservationInfo = [
//     -1, // User ID
//     '', // Reservation Name
//     '', // Club Name
//     1, // Number of Persons
//     0.0, // Total Price
//     0, // Number of Regular Bottles (Απλή)
//     0, // Number of Special Bottles
//     0, // Number of Premium Bottles
//     '', // Reservation Date
//     '', // Comment
//     0, // Discount Percentage
//   ];

//   int _maxPersons = 1; // Initialize with a default value of 1

//   // Getter for maxPersons
//   int get maxPersons => _maxPersons;
//   List<dynamic> get reservationInfo => _reservationInfo;

//   // Setter for maxPersons with notification to listeners
//   void setMaxPersons(int value) {
//     if (value > 0) {
//       _maxPersons = value;
//     } else {
//       _maxPersons = 1; // Ensure the minimum value is 1
//     }

//     notifyListeners();
//   }

//   // Get information from the reservationInfo list
//   dynamic getInfo(int index) {
//     return _reservationInfo[index];
//   }

//   // Set information in the reservationInfo list and notify listeners
//   void setInfo(int index, dynamic value) {
//     _reservationInfo[index] = value;

//     notifyListeners();
//   }

//   // Reset the reservation info to default values
//   void resetInfo() {
//     _reservationInfo = [
//       -1, // User ID
//       '', // Reservation Name
//       '', // Club Name
//       1, // Number of Persons
//       0.0, // Total Price
//       0, // Number of Regular Bottles (Απλή)
//       0, // Number of Special Bottles
//       0, // Number of Premium Bottles
//       '', // Reservation Date
//       '', // Comment
//       0, // Discount Percentage
//     ];
//     _maxPersons = 1; // Reset maxPersons to its default value

//     notifyListeners();
//   }
// }

class ReservationProvider with ChangeNotifier {
  Reservation _reservation = Reservation();
  int _maxPersons = 1;

  Reservation get reservation => _reservation;
  int get maxPersons => _maxPersons;

  void setMaxPersons(int value) {
    _maxPersons = value > 0 ? value : 1;
    notifyListeners();
  }

  void resetReservation() {
    _reservation = Reservation();
    _maxPersons = 1;
    notifyListeners();
  }

// ✅ Flexible update function to modify one or multiple fields
  void updateReservation({
    int? userID,
    String? reservationName,
    String? clubName,
    int? numPersons,
    double? totalPrice,
    int? numRegularBottles,
    int? numSpecialBottles,
    int? numPremiumBottles,
    String? reservationDate,
    String? comment,
    int? discountPercentage,
  }) {
    if (userID != null) _reservation.userID = userID;
    if (reservationName != null) _reservation.reservationName = reservationName;
    if (clubName != null) _reservation.clubName = clubName;
    if (numPersons != null) _reservation.numberOfPersons = numPersons;
    if (totalPrice != null) _reservation.totalPrice = totalPrice;
    if (numRegularBottles != null) {
      _reservation.regularBottles = numRegularBottles;
    }
    if (numSpecialBottles != null) {
      _reservation.specialBottles = numSpecialBottles;
    }
    if (numPremiumBottles != null) {
      _reservation.premiumBottles = numPremiumBottles;
    }
    if (reservationDate != null) _reservation.reservationDate = reservationDate;
    if (comment != null) _reservation.comment = comment;
    if (discountPercentage != null) {
      _reservation.discountPercentage = discountPercentage;
    }

    notifyListeners(); // Notify the UI about the changes
  }
}
