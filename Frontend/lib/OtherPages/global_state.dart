import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

String validatedIp = '192.168.1.9';

class GlobalState with ChangeNotifier {
  bool _dataLoaded = false;

  bool get dataLoaded => _dataLoaded;

  void setDataLoaded(bool value) {
    _dataLoaded = value;
    notifyListeners();
    print('Connecting to server at: http://$validatedIp:8000/');
  }
}

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

class ClubProvider with ChangeNotifier {
  final List<ClubInfoStruct> _clubs = [];
  final List<CatalogueInfoStruct> _catalogues = [];

////LIST GETTERS
  List<ClubInfoStruct> get allClubs => _clubs;
  List<CatalogueInfoStruct> get allCatalogues => _catalogues;
  List<ClubInfoStruct> get likedClubs =>
      _clubs.where((club) => club.clubIsLiked).toList();
////LIST GETTERS <END>

////MAIN FUNCTION FOR CLUBS' AND CATALOGUES' LISTS FETCHING
  Future<void> fetchClubsAndCatalogues() async {
    var url =
        'http://$validatedIp:8000/api/clubs/print/'; // Replace with your API URL
    try {
      final response = await http.get(Uri.parse(url));
      final decodedBody = utf8.decode(response.bodyBytes);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(decodedBody);

        for (var item in data) {
          final club = ClubInfoStruct.fromJson(item);

          if (club.clubID >= 0) {
            addOrUpdateClub(club);
          }
        }

        // Fetch and update catalogues
        await _fetchAndSaveCatalogues();
      } else {
        throw Exception('Failed to load clubs: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching clubs: $e');
    }
  }

////MAIN FUNCTION FOR CLUBS' AND CATALOGUES' LISTS FETCHING <END>

////MANAGE CLUBS LIST
  void addOrUpdateClub(ClubInfoStruct club) {
    if (club.clubID <= 0) {
      return;
    }

    int index = _clubs.indexWhere((c) => c.clubID == club.clubID);
    if (index != -1) {
      _clubs[index] = club;
    } else {
      _clubs.add(club);
    }
    notifyListeners();
  }

  void removeClub(int clubID) {
    _clubs.removeWhere((club) => club.clubID == clubID);
    _catalogues.removeWhere((catalogue) => catalogue.clubID == clubID);
    notifyListeners();
  }
////MANAGE CLUBS LIST <END>

////MANAGE CATALOGUES LIST
  void addOrUpdateCatalogue(CatalogueInfoStruct catalogue) {
    if (catalogue.clubID <= 0) {
      return;
    }

    int index = _catalogues.indexWhere((c) =>
        c.clubID == catalogue.clubID && c.serviceType == catalogue.serviceType);
    if (index != -1) {
      _catalogues[index] = catalogue;
    } else {
      _catalogues.add(catalogue);
    }
    notifyListeners();
  }

  CatalogueInfoStruct getCatalogue(List<CatalogueInfoStruct> catalogues,
      ClubInfoStruct club, String serviceType) {
    var catalogueList = catalogues
        .where((catalogue) =>
            catalogue.clubID == club.clubID &&
            catalogue.serviceType == serviceType)
        .toList();

    if (catalogueList.isNotEmpty) {
      return catalogueList[0];
    }
    return catalogues[0];
  }

  Future<void> _fetchAndSaveCatalogues() async {
    for (var club in _clubs) {
      // Fetch catalogues and update the club's minPrice and maxPersons if necessary
      await fetchCatalogues(club);
    }
    notifyListeners();
  }

  Future<void> fetchCatalogues(ClubInfoStruct club) async {
    if (club.clubID <= 0) {
      print('fetchCatalogues: Invalid club ID');
      return;
    }

    final url =
        'http://$validatedIp:8000/api/clubs/${club.clubID}/catalogue'; // Replace with your API URL

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        if (data.isNotEmpty) {
          for (var item in data) {
            final catalogue = CatalogueInfoStruct.fromJson(item);
            addOrUpdateCatalogue(catalogue);

            // Update the club's minPrice and maxPersons for the 'Regular' service type
            if (catalogue.serviceType == 'Regular') {
              club.clubMinPrice = double.parse(catalogue.price).toInt();
              club.clubMaxPersons = catalogue.maxPersons;
              addOrUpdateClub(club);
            }
          }
        }
      } else {
        throw Exception('Failed to load catalogues: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error fetching catalogues: $e');
    }
  }

////MANAGE CATALOGUES LIST <END>

////MANAGE LIKED CLUBS
  void toggleLike(String clubName) {
    for (var club in _clubs) {
      if (club.clubName == clubName) {
        club.clubIsLiked = !club.clubIsLiked;
        notifyListeners();
        return;
      }
    }
  }

  bool isLiked(String clubName) {
    for (var club in likedClubs) {
      if (club.clubName == clubName) {
        return club.clubIsLiked;
      }
    }
    return false;
  }

  void deleteAllLiked() {
    for (var club in _clubs) {
      if (club.clubIsLiked) {
        club.clubIsLiked = false;
      }
    }
    notifyListeners();
  }
////MANAGE LIKED CLUBS <END>

////OTHER HELPFUL FUNCTIONS
  String getClubAvailability(String clubName) {
    return _clubs
        .firstWhere((club) => club.clubName == clubName)
        .clubAvailability;
  }

  ClubInfoStruct getClubByID(int clubID) {
    return _clubs.firstWhere((club) => club.clubID == clubID);
  }

  ClubInfoStruct getClubByName(String clubName) {
    return _clubs.firstWhere((club) => club.clubName == clubName);
  }

  int getClubIDByName(String clubName) {
    return _clubs.firstWhere((club) => club.clubName == clubName).clubID;
  }

  String getClubNameByID(int clubID) {
    return _clubs.firstWhere((club) => club.clubID == clubID).clubName;
  }

  List<CatalogueInfoStruct> getCataloguesByClubID(int clubID) {
    return _catalogues
        .where((catalogue) => catalogue.clubID == clubID)
        .toList();
  }

  void printAllClubs() {
    for (var club in _clubs) {
      print(
          '{"clubID:"${club.clubID},"clubName:"${club.clubName},"clubMinPrice:"${club.clubMinPrice},"clubMaxPersons:"${club.clubMaxPersons},"clubPhone:"${club.clubPhone},"clubLocation:"${club.clubLocation},"clubRating:"${club.clubRating},"clubAvailability:"${club.clubAvailability},"clubIsLiked:"${club.clubIsLiked},"clubPhone:"${club.clubPhone},"clubLocation:"${club.clubLocation},"clubRating:"${club.clubRating},"clubAvailability:"${club.clubAvailability},"clubPhoto:"${club.clubPhoto}}');
    }
  }

  void printAllClubIDsAndNames() {
    for (var club in _clubs) {
      print('Club ID: ${club.clubID}, Club Name: ${club.clubName}');
    }
  }

  void printClub(ClubInfoStruct club) {
    print(
        '{"clubID:"${club.clubID},"clubName:"${club.clubName},"clubMinPrice:"${club.clubMinPrice},"clubMaxPersons:"${club.clubMaxPersons},"clubPhone:"${club.clubPhone},"clubLocation:"${club.clubLocation},"clubRating:"${club.clubRating},"clubAvailability:"${club.clubAvailability},"clubIsLiked:"${club.clubIsLiked},"clubPhone:"${club.clubPhone},"clubLocation:"${club.clubLocation},"clubRating:"${club.clubRating},"clubAvailability:"${club.clubAvailability},"clubPhoto:"${club.clubPhoto}}');
  }

  void printClubWithID(int id) {
    for (var club in _clubs) {
      if (club.clubID == id) {
        print(
            '{"clubID:"${club.clubID},"clubName:"${club.clubName},"clubMinPrice:"${club.clubMinPrice},"clubMaxPersons:"${club.clubMaxPersons},"clubPhone:"${club.clubPhone},"clubLocation:"${club.clubLocation},"clubRating:"${club.clubRating},"clubAvailability:"${club.clubAvailability},"clubIsLiked:"${club.clubIsLiked},"clubPhone:"${club.clubPhone},"clubLocation:"${club.clubLocation},"clubRating:"${club.clubRating},"clubAvailability:"${club.clubAvailability},"clubPhoto:"${club.clubPhoto}}');
        return;
      }
    }
    print('ClubID not found!');
  }

  void printClubWithName(String clubName) {
    for (var club in _clubs) {
      if (club.clubName == clubName) {
        print(
            '{"clubID:"${club.clubID},"clubName:"${club.clubName},"clubMinPrice:"${club.clubMinPrice},"clubMaxPersons:"${club.clubMaxPersons},"clubPhone:"${club.clubPhone},"clubLocation:"${club.clubLocation},"clubRating:"${club.clubRating},"clubAvailability:"${club.clubAvailability},"clubIsLiked:"${club.clubIsLiked},"clubPhone:"${club.clubPhone},"clubLocation:"${club.clubLocation},"clubRating:"${club.clubRating},"clubAvailability:"${club.clubAvailability},"clubPhoto:"${club.clubPhoto}}');
        return;
      }
    }
    print('ClubName not found!');
  }

  void printAllCatalogues() {
    for (var catalogue in _catalogues) {
      print(
          '{"clubID:"${catalogue.clubID},"clubName:${getClubNameByID(catalogue.clubID)}","serviceType:"${catalogue.serviceType},"price:"${catalogue.price},"maxPersons:"${catalogue.maxPersons}}');
    }
  }

  void printCatalogue(CatalogueInfoStruct catalogue) {
    print(
        '{"clubID:"${catalogue.clubID},"clubName:${getClubNameByID(catalogue.clubID)}","serviceType:"${catalogue.serviceType},"price:"${catalogue.price},"maxPersons:"${catalogue.maxPersons}}');
  }
////OTHER HELPFUL FUNCTIONS <END>
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

  Booking({
    required this.bookingID,
    required this.userID,
    required this.clubID,
    required this.bookingName,
    required this.date,
    required this.persons,
    required this.fourbitString,
    required this.price,
  });
}

class UserInfoStruct {
  int userID, points;
  String username;
  String password;
  String firstName;
  String lastName;
  String email;
  String phone;
  String photo;

  UserInfoStruct({
    required this.userID,
    this.username = '',
    this.password = '',
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.phone = '',
    this.points = -1,
    this.photo = '',
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
        photo: json['photo'] ?? '');
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
      'photo': photo,
    };
  }
}

class UserProvider with ChangeNotifier {
  UserInfoStruct? _userDetails;

  UserInfoStruct? get userDetails => _userDetails;

  Future<void> loadUserDetailsFromPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDetailsString = prefs.getString('user_details');

    if (userDetailsString != null) {
      _userDetails = UserInfoStruct.fromJson(jsonDecode(userDetailsString));
      notifyListeners();
    }
  }

  Future<void> saveUserDetailsToPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_userDetails != null) {
      await prefs.setString('user_details', jsonEncode(_userDetails!.toJson()));
    }
  }

  Future<void> fetchUserDetailsFromServer() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token != null) {
      final response = await http.get(
        Uri.parse('http://$validatedIp:8000/api/user/print'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        // Decode the response body using UTF-8 to handle different alphabets correctly
        final decodedBody = utf8.decode(response.bodyBytes);
        print(decodedBody); // Now this should print correctly

        // Parse the JSON from the correctly decoded string
        _userDetails = UserInfoStruct.fromJson(jsonDecode(decodedBody));
        await saveUserDetailsToPreferences();
        notifyListeners();
      } else {
        throw Exception('Failed to load user details');
      }
    } else {
      throw Exception('No access token found');
    }
  }

  Future<void> syncUserDetails() async {
    await loadUserDetailsFromPreferences();
    await fetchUserDetailsFromServer();
    notifyListeners();
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
