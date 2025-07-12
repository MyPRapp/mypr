import 'global_components.dart';

class Club {
  int clubID;
  String clubName;
  int clubMinPrice;
  int clubMaxPersons;
  int clubPriority;
  String clubPhone;
  String clubLocation;
  double clubRating;
  String clubAvailableDays;
  String clubPhoto;
  String localPhotoPath = '';
  String clubNotAvailable;
  String clubInfo; //Use '\n' to split the alerts

  Club({
    required this.clubID,
    this.clubName = '',
    this.clubMinPrice = -1,
    this.clubMaxPersons = -1,
    this.clubPhone = '',
    this.clubLocation = '',
    this.clubRating = -1,
    this.clubAvailableDays = '',
    this.clubPhoto = '',
    this.clubNotAvailable = '',
    this.clubPriority = -1,
    this.clubInfo = '',
  });

  factory Club.fromJson(Map<String, dynamic> json) {
    try {
      return Club(
          clubID: json['id'] ?? -1,
          clubName: json['club_name'] ?? '',
          clubMinPrice: json['min_price'] ?? -1,
          clubMaxPersons: json['max_persons'] ?? -1,
          clubPhone: json['phone'] ?? '',
          clubLocation: json['location'] ?? '',
          clubRating: json['rating'] != null
              ? double.tryParse(json['rating'].toString()) ?? -1
              : -1,
          clubAvailableDays: json['availability'] ?? '',
          clubPhoto: json['photo'] ?? '',
          clubNotAvailable: json['not_available'] ?? '',
          clubPriority: json['priority'] ?? -1,
          clubInfo: json['club_info'] ?? '');
    } catch (e) {
      errorPrint('Error parsing Club: $e');
      return Club(clubID: -1); // Return a default object with clubID -1
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
      'availability': clubAvailableDays,
      'photo': clubPhoto,
      'not_available': clubNotAvailable,
      'localPhotoPath': localPhotoPath,
      'priority': clubPriority,
      'clubInfo': clubInfo,
    };
  }
}

class User {
  int userID, points;
  String username, firstName, lastName, email, phone;
  bool isBanned;

  User({
    required this.userID,
    this.username = '',
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.phone = '',
    this.points = -1,
    this.isBanned = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      return User(
        userID: json['id'] ?? -1,
        username: json['username'] ?? '',
        firstName: json['first_name'] ?? '',
        lastName: json['last_name'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        points: json['points'] ?? -1,
        isBanned: json['is_banned'] ?? false,
      );
    } catch (e) {
      errorPrint('Error parsing User: $e');
      return User(userID: -1); // Return a default object with userID -1
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
      'is_banned': isBanned,
    };
  }
}

class Catalogue {
  int clubID;
  String serviceType;
  String price;
  int maxPersons;

  Catalogue({
    required this.clubID,
    required this.serviceType,
    required this.price,
    required this.maxPersons,
  });

  factory Catalogue.fromJson(Map<String, dynamic> json) {
    try {
      return Catalogue(
        clubID: json['club'] ?? -1,
        serviceType: json['service_type'] ?? '',
        price: json['price'] ?? '',
        maxPersons: json['max_person'] ?? -1,
      );
    } catch (e) {
      errorPrint('Error parsing Catalogue: $e');
      return Catalogue(
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

class Booking {
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

  Booking({
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

  factory Booking.fromJson(Map<String, dynamic> json) {
    try {
      return Booking(
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
      errorPrint('Error parsing Booking: $e');
      return Booking(
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

class Reservation {
  int userID;
  String reservationName;
  String clubName;
  int numberOfPersons;
  double totalPrice;
  int regularBottles;
  int specialBottles;
  int premiumBottles;
  String reservationDate;
  String comment;
  int discountPercentage;

  Reservation({
    this.userID = -1,
    this.reservationName = '',
    this.clubName = '',
    this.numberOfPersons = 1,
    this.totalPrice = 0.0,
    this.regularBottles = 0,
    this.specialBottles = 0,
    this.premiumBottles = 0,
    this.reservationDate = '',
    this.comment = '',
    this.discountPercentage = 0,
  });
}
