import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../global_components.dart';
import 'global_state_provider.dart';

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
        'http://${GlobalStateProvider().validatedIp}:8000/api/clubs/print/'; // Replace with your API URL
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

    String url =
        'http://${GlobalStateProvider().validatedIp}:8000/api/clubs/${club.clubID}/catalogue'; // Replace with your API URL

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
