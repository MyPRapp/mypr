import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
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
  ClubProvider() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadClubsFromPreferences();
    await _loadCataloguesFromPreferences();
    await _loadLikedClubsFromPreferences();
  }

  final List<ClubInfoStruct> _clubs = [];
  final List<CatalogueInfoStruct> _catalogues = [];
  final List<int> _likedClubIDs = []; // List to hold liked club IDs
  // LIST GETTERS
  List<ClubInfoStruct> get allClubs => _clubs;
  List<CatalogueInfoStruct> get allCatalogues => _catalogues;
  List<ClubInfoStruct> get likedClubs =>
      _clubs.where((club) => _likedClubIDs.contains(club.clubID)).toList();

  // Save clubs to shared preferences
  Future<void> _saveClubsToPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String clubsJson =
        jsonEncode(_clubs.map((club) => club.toJson()).toList());
    await prefs.setString('clubs', clubsJson);
  }

  // Save catalogues to shared preferences
  Future<void> _saveCataloguesToPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String cataloguesJson =
        jsonEncode(_catalogues.map((catalogue) => catalogue.toJson()).toList());
    await prefs.setString('catalogues', cataloguesJson);
  }

  // Save liked clubs to shared preferences
  Future<void> _saveLikedClubsToPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'likedClubs', _likedClubIDs.map((id) => id.toString()).toList());
  }

  // Save image to shared preferences
  Future<void> saveImageToPreferences(String key, String base64Image) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, base64Image);
  }

  // Load image from shared preferences
  Future<Image> loadImageFromPreferences(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final base64Image = prefs.getString(key);

    if (base64Image != null) {
      final Uint8List bytes = base64Decode(base64Image);
      return Image.memory(bytes);
    } else {
      throw Exception('No image found in preferences');
    }
  }

  // Load clubs from shared preferences
  Future<void> _loadClubsFromPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? clubsJson = prefs.getString('clubs');
    final String? cataloguesJson = prefs.getString('catalogues');

    if (clubsJson != null && cataloguesJson != null) {
      final List<dynamic> clubsList = jsonDecode(clubsJson);
      final List<dynamic> cataloguesList = jsonDecode(cataloguesJson);

      _clubs.clear();
      _catalogues.clear();

      for (var catalogue in cataloguesList) {
        _catalogues.add(CatalogueInfoStruct.fromJson(catalogue));
      }

      for (var club in clubsList) {
        ClubInfoStruct clubStruct = ClubInfoStruct.fromJson(club);

        // Update clubMinPrice and clubMaxPersons using the catalogues
        final regularCatalogue = _catalogues.firstWhere(
          (catalogue) =>
              catalogue.clubID == clubStruct.clubID &&
              catalogue.serviceType == 'Regular',
          orElse: () => CatalogueInfoStruct(
            clubID: clubStruct.clubID,
            serviceType: 'Regular',
            price: '0',
            maxPersons: 0,
          ),
        );

        clubStruct.clubMinPrice = double.parse(regularCatalogue.price).toInt();
        clubStruct.clubMaxPersons = regularCatalogue.maxPersons;

        _clubs.add(clubStruct);
      }
      notifyListeners();
    }
  }

  // Load catalogues from shared preferences
  Future<void> _loadCataloguesFromPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? cataloguesJson = prefs.getString('catalogues');
    if (cataloguesJson != null) {
      final List<dynamic> cataloguesList = jsonDecode(cataloguesJson);
      _catalogues.clear();
      for (var catalogue in cataloguesList) {
        _catalogues.add(CatalogueInfoStruct.fromJson(catalogue));
      }
      notifyListeners();
    }
  }

  // Load liked clubs from shared preferences
  Future<void> _loadLikedClubsFromPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? likedClubsStringList = prefs.getStringList('likedClubs');

    if (likedClubsStringList != null) {
      _likedClubIDs.clear();
      _likedClubIDs.addAll(likedClubsStringList.map((id) => int.parse(id)));
      notifyListeners();
    }
  }

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

          // if (await isConnectedToNetwork()) {
          if (club.clubID >= 0) {
            // Download the image, convert it to base64, and save to preferences
            final base64Image = await imageToBase64(club.clubPhoto);
            await saveImageToPreferences(
                'club_image_${club.clubID}', base64Image);

            addOrUpdateClub(club);
          }
          // } else {
          //   print('No network connection');
          // }
        }

        // Save clubs to shared preferences
        await _saveClubsToPreferences();

        // Fetch and update catalogues
        await _fetchAndSaveCatalogues();

        // Save catalogues to shared preferences
        await _saveCataloguesToPreferences();
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
  // Function to toggle like status of a club
  void toggleLike(int clubID) {
    if (_likedClubIDs.contains(clubID)) {
      _likedClubIDs.remove(clubID);
    } else {
      _likedClubIDs.add(clubID);
    }

    _saveLikedClubsToPreferences(); // Save the updated liked clubs to preferences
    notifyListeners();
  }

  // Ensure the isLiked function checks the list of liked club IDs
  bool isLiked(int clubID) {
    return _likedClubIDs.contains(clubID);
  }

  // Method to delete all liked clubs
  Future<void> deleteAllLiked() async {
    _likedClubIDs.clear(); // Clear the liked clubs list
    await _saveLikedClubsToPreferences(); // Update preferences
    notifyListeners(); // Notify listeners to update the UI
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
    return Booking(
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

class UserProvider with ChangeNotifier {
  UserInfoStruct? _userDetails;

  UserInfoStruct? get userDetails => _userDetails;

  // Save user details including the photo to shared preferences
  Future<void> saveUserDetailsToPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_userDetails != null) {
      // Save user details
      await prefs.setString('user_details', jsonEncode(_userDetails!.toJson()));

      // Fetch and save the user's photo as a base64 string if it exists
      if (_userDetails!.photo.isNotEmpty) {
        String base64Photo = await imageToBase64(
            'http://$validatedIp:8000/${_userDetails!.photo}');
        if (base64Photo.isNotEmpty) {
          await prefs.setString('user_photo', base64Photo);
        } else {
          print('User photo could not be saved as base64');
        }
      }
    }
  }

  // Load user details including the photo from shared preferences
  Future<void> loadUserDetailsFromPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDetailsString = prefs.getString('user_details');
    String? userPhotoBase64 = prefs.getString('user_photo');

    if (userDetailsString != null) {
      _userDetails = UserInfoStruct.fromJson(jsonDecode(userDetailsString));

      // If a photo is saved, convert it back from base64 and assign it to the user details
      if (userPhotoBase64 != null && _userDetails != null) {
        final Uint8List bytes = base64Decode(userPhotoBase64);
        _userDetails!.photo =
            base64Encode(bytes); // Save photo as a base64 string
      }

      notifyListeners();
    }
  }

  // Fetch user details from the server and save them to shared preferences
  Future<void> fetchUserDetailsFromServer() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token != null) {
      final response = await http.get(
        Uri.parse('http://$validatedIp:8000/api/user/print'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);

        _userDetails = UserInfoStruct.fromJson(jsonDecode(decodedBody));

        // Save user details and photo to shared preferences
        await saveUserDetailsToPreferences();

        notifyListeners();
      } else {
        throw Exception('Failed to load user details');
      }
    } else {
      throw Exception('No access token found');
    }
  }

  // Sync user details by loading from preferences and fetching from the server
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
