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

  ClubInfoStruct(
      {required this.clubID,
      this.clubName = '',
      this.clubMinPrice = -1,
      this.clubMaxPersons = -1,
      this.clubPhone = '',
      this.clubLocation = '',
      this.clubRating = -1,
      this.clubAvailability = '',
      this.clubIsLiked = false});

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
    };
  }
}

class ClubProvider with ChangeNotifier {
  final List<ClubInfoStruct> _clubs = [];

  List<ClubInfoStruct> get allClubs => _clubs;

  List<ClubInfoStruct> get likedClubs =>
      _clubs.where((club) => club.clubIsLiked).toList();

  Future<void> loadLikedClubs() async {
    final prefs = await SharedPreferences.getInstance();
    for (var club in _clubs) {
      club.clubIsLiked = prefs.getBool(club.clubName) ?? false;
    }
    notifyListeners();
  }

  bool isLiked(String clubName) {
    for (var club in _clubs) {
      if (club.clubName == clubName) {
        return club.clubIsLiked;
      }
    }
    return false;
  }

  Future<void> toggleLike(String clubName) async {
    final prefs = await SharedPreferences.getInstance();
    for (var club in _clubs) {
      if (club.clubName == clubName) {
        club.clubIsLiked = !club.clubIsLiked;
        await prefs.setBool(club.clubName, club.clubIsLiked);
        printClubWithName(clubName);
      }
    }
    notifyListeners();
  }

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
    notifyListeners();
  }

  String getClubAvailability(String clubName) {
    return _clubs
        .firstWhere((club) => club.clubName == clubName)
        .clubAvailability;
  }

  int getClubIDByName(String clubName) {
    return _clubs.firstWhere((club) => club.clubName == clubName).clubID;
  }

  void printAllClubIDsAndNames() {
    for (var club in _clubs) {
      print('Club ID: ${club.clubID}, Club Name: ${club.clubName}');
    }
  }

  void printClubWithID(int id) {
    for (var club in _clubs) {
      if (club.clubID == id) {
        print(
            '{"clubID:"${club.clubID},"clubName:"${club.clubName},"clubMinPrice:"${club.clubMinPrice},"clubMaxPersons:"${club.clubMaxPersons},"clubPhone:"${club.clubPhone},"clubLocation:"${club.clubLocation},"clubRating:"${club.clubRating},"clubAvailability:"${club.clubAvailability},"clubIsLiked:"${club.clubIsLiked}}');
        return;
      }
    }
    print('ClubID not found!');
  }

  void printClubWithName(String clubName) {
    for (var club in _clubs) {
      if (club.clubName == clubName) {
        print(
            '{"clubID:"${club.clubID},"clubName:"${club.clubName},"clubMinPrice:"${club.clubMinPrice},"clubMaxPersons:"${club.clubMaxPersons},"clubPhone:"${club.clubPhone},"clubLocation:"${club.clubLocation},"clubRating:"${club.clubRating},"clubAvailability:"${club.clubAvailability},"clubIsLiked:"${club.clubIsLiked}}');
        return;
      }
    }
    print('ClubName not found!');
  }

  void printAllClubs() {
    for (var club in _clubs) {
      print(
          '{"clubID:"${club.clubID},"clubName:"${club.clubName},"clubMinPrice:"${club.clubMinPrice},"clubMaxPersons:"${club.clubMaxPersons},"clubPhone:"${club.clubPhone},"clubLocation:"${club.clubLocation},"clubRating:"${club.clubRating},"clubAvailability:"${club.clubAvailability},"clubIsLiked:"${club.clubIsLiked}}');
    }
  }

  //PUSH SP LIST TO _CLUBS
  Future<void> loadClubsFromPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.clear();
    List<String> storedClubs = prefs.getStringList('clubs') ?? [];
    if (storedClubs.isNotEmpty) {
      for (String clubJson in storedClubs) {
        ClubInfoStruct club = ClubInfoStruct.fromJson(jsonDecode(clubJson));
        addOrUpdateClub(club);
      }
    }
    notifyListeners();
  }

  Future<void> fetchClubsAndCatalogues() async {
    const url =
        'http://127.0.0.1:8000/api/clubs/print/'; // Replace with your API URL

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        List<String> storedClubs = prefs.getStringList('clubs') ?? [];

        for (var item in data) {
          final club = ClubInfoStruct.fromJson(item);

          // Check if the club exists in SharedPreferences
          if (club.clubID > 0) {
            if (storedClubs.any(
                (storedClub) => jsonDecode(storedClub)['id'] == club.clubID)) {
            } else {
              storedClubs.add(jsonEncode(club.toJson()));
              addOrUpdateClub(club);
            }
          }
        }
        printAllClubIDsAndNames();
        // Save updated club list to SharedPreferences
        await prefs.setStringList('clubs', storedClubs);
        // Fetch and update catalogues
        await _fetchAndSaveCatalogues();
      } else {
        throw Exception('Failed to load clubs: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching clubs: $e');
    }
  }

  Future<void> _fetchAndSaveCatalogues() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> storedClubs = prefs.getStringList('clubs') ?? [];

    for (int i = 0; i < storedClubs.length; i++) {
      ClubInfoStruct club = ClubInfoStruct.fromJson(jsonDecode(storedClubs[i]));
      await fetchCatalogues(club);
      storedClubs[i] = jsonEncode(club.toJson());
      addOrUpdateClub(club);
    }
    printAllClubs();
    await prefs.setStringList('clubs', storedClubs);
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
          final catalogue = data.firstWhere(
            (item) =>
                item['club'] == club.clubID &&
                item['service_type'] == 'Regular',
            orElse: () => null,
          );

          if (catalogue != null) {
            club.clubMinPrice = (double.parse(catalogue['price'])).toInt();
            club.clubMaxPersons = catalogue['max_person'];
          } else {
            print(
                'No matching catalogue found for club ID ${club.clubID} with service type Regular');
          }
        }
      } else {
        throw Exception('Failed to load catalogues: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error fetching catalogues: $e');
    }
  }
}

class UserProvider with ChangeNotifier {
  Map<String, dynamic>? _userDetails;

  Map<String, dynamic>? get userDetails => _userDetails;

  UserProvider() {
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDetailsString = prefs.getString('user_details');

    if (userDetailsString != null) {
      _userDetails = jsonDecode(userDetailsString);
      notifyListeners();
    }
  }

  Future<void> fetchUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token != null) {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/user/print'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        _userDetails = jsonDecode(response.body);
        await prefs.setString('user_details', jsonEncode(_userDetails));
        notifyListeners();
      } else {
        throw Exception('Failed to load user details');
      }
    } else {
      throw Exception('No access token found');
    }
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
