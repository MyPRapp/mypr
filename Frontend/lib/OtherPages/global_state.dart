import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GlobalState with ChangeNotifier {
  bool _dataLoaded = false;

  bool get dataLoaded => _dataLoaded;

  void setDataLoaded(bool value) {
    _dataLoaded = value;
    notifyListeners();
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

  ClubInfoStruct copyWith({
    int? clubID,
    String? clubName,
    int? clubMinPrice,
    int? clubMaxPersons,
    String? clubPhone,
    String? clubLocation,
    double? clubRating,
    String? clubAvailability,
    bool? clubIsLiked,
    String? clubPhoto,
  }) {
    return ClubInfoStruct(
      clubID: clubID ?? this.clubID,
      clubName: clubName ?? this.clubName,
      clubMinPrice: clubMinPrice ?? this.clubMinPrice,
      clubMaxPersons: clubMaxPersons ?? this.clubMaxPersons,
      clubPhone: clubPhone ?? this.clubPhone,
      clubLocation: clubLocation ?? this.clubLocation,
      clubRating: clubRating ?? this.clubRating,
      clubAvailability: clubAvailability ?? this.clubAvailability,
      clubIsLiked: clubIsLiked ?? this.clubIsLiked,
      clubPhoto: clubPhoto ?? this.clubPhoto,
    );
  }
}

class CatalogueInfoStruct {
  int clubID;
  String serviceType;
  String price;
  int maxPerson;

  CatalogueInfoStruct({
    required this.clubID,
    required this.serviceType,
    required this.price,
    required this.maxPerson,
  });

  factory CatalogueInfoStruct.fromJson(Map<String, dynamic> json) {
    return CatalogueInfoStruct(
      clubID: json['club'] ?? -1,
      serviceType: json['service_type'] ?? '',
      price: json['price'] ?? '',
      maxPerson: json['max_person'] ?? -1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'club': clubID,
      'service_type': serviceType,
      'price': price,
      'max_person': maxPerson,
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
    const url =
        'http://127.0.0.1:8000/api/clubs/print/'; // Replace with your API URL
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

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
  //MANAGE CLUBS LIST <END>

  //MANAGE CATALOGUES LIST
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
        'http://127.0.0.1:8000/api/clubs/${club.clubID}/catalogue'; // Replace with your API URL

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
              club.clubMaxPersons = catalogue.maxPerson;
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

  //MANAGE CATALOGUES LIST <END>

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
    for (var club in _clubs) {
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
          '{"clubID:"${catalogue.clubID},"clubName:${getClubNameByID(catalogue.clubID)}","serviceType:"${catalogue.serviceType},"price:"${catalogue.price},"maxPerson:"${catalogue.maxPerson}}');
    }
  }

  void printCatalogue(CatalogueInfoStruct catalogue) {
    print(
        '{"clubID:"${catalogue.clubID},"clubName:${getClubNameByID(catalogue.clubID)}","serviceType:"${catalogue.serviceType},"price:"${catalogue.price},"maxPerson:"${catalogue.maxPerson}}');
  }
////OTHER HELPFUL FUNCTIONS <END>
}

class UserInfoStruct {
  int userID;
  String username;
  String password;
  String firstName;
  String lastName;
  String email;
  String phone;

  UserInfoStruct({
    required this.userID,
    this.username = '',
    this.password = '',
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.phone = '',
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
    );
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
        Uri.parse('http://127.0.0.1:8000/api/user/print'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        _userDetails = UserInfoStruct.fromJson(jsonDecode(response.body));
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
