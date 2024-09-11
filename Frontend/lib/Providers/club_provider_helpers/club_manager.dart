import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../global_components.dart';

class ClubManager with ChangeNotifier {
  final List<ClubInfoStruct> _clubs;
  final List<CatalogueInfoStruct> _catalogues;
  final List<int> _likedClubIDs;
  final VoidCallback _notifyListeners;

  ClubManager(
      this._clubs, this._catalogues, this._likedClubIDs, this._notifyListeners);

  // GETTERS
  List<ClubInfoStruct> get allClubs => _clubs;
  List<CatalogueInfoStruct> get allCatalogues => _catalogues;
  List<ClubInfoStruct> get allLikedClubs =>
      _clubs.where((club) => _likedClubIDs.contains(club.clubID)).toList();

  // CLUB MANAGEMENT
  void addOrUpdateClub(ClubInfoStruct club) {
    if (club.clubID <= 0) {
      print('AddOrUpdateClub: Invalid clubID: ${club.clubID}');
      return;
    }

    try {
      // Try to find if the club already exists in the list by its clubID
      int index = _clubs.indexWhere((c) => c.clubID == club.clubID);

      if (index != -1) {
        // Club exists, update the existing entry
        _clubs[index] = club;
        print('Club with clubID ${club.clubID} updated.');
      } else {
        // Club does not exist, add it to the list
        _clubs.add(club);
        print('New club with clubID ${club.clubID} added.');
      }

      _notifyListeners(); // Notify listeners that the club data has changed
    } catch (e) {
      // Catch any unexpected errors
      print('Error in addOrUpdateClub for clubID ${club.clubID}: $e');
    }
  }

  void removeClubWithClubCatalogues(int clubID) {
    if (clubID <= 0) {
      print('RemoveClubWithClubCatalogues: Invalid clubID:: $clubID');
      return;
    }
    _clubs.removeWhere((club) => club.clubID == clubID);
    _catalogues.removeWhere((catalogue) => catalogue.clubID == clubID);
    _notifyListeners();
  }

  // CATALOGUE MANAGEMENT

  // Method to initialize catalogues based on club ID and update the provided CatalogueInfoStruct variables
  List<CatalogueInfoStruct> getAllCatalogues(int clubID) {
    ClubInfoStruct club = getClubByID(clubID);

    // Initialize and update the CatalogueInfoStruct variables
    CatalogueInfoStruct regularCatalogue = getCatalogue(club, 'Regular');
    CatalogueInfoStruct specialCatalogue = getCatalogue(club, 'Special');
    CatalogueInfoStruct premiumCatalogue = getCatalogue(club, 'Premium');

    return [regularCatalogue, specialCatalogue, premiumCatalogue];
  }

  void addOrUpdateCatalogue(CatalogueInfoStruct catalogue) {
    if (catalogue.clubID <= 0) {
      print('AddOrUpdateCatalogue: Invalid clubID: ${catalogue.clubID}');
      return;
    }

    try {
      // Try to find if the catalogue for the specific clubID and serviceType already exists
      int index = _catalogues.indexWhere((c) =>
          c.clubID == catalogue.clubID &&
          c.serviceType == catalogue.serviceType);

      if (index != -1) {
        // Catalogue exists, update the existing entry
        _catalogues[index] = catalogue;
        print(
            'Catalogue for clubID ${catalogue.clubID} and serviceType ${catalogue.serviceType} updated.');
      } else {
        // Catalogue does not exist, add it to the list
        _catalogues.add(catalogue);
        print(
            'New catalogue for clubID ${catalogue.clubID} and serviceType ${catalogue.serviceType} added.');
      }

      _notifyListeners(); // Notify listeners that the catalogues data has changed
    } catch (e) {
      // Catch any unexpected errors during the operation
      print('Error in addOrUpdateCatalogue for clubID ${catalogue.clubID}: $e');
    }
  }

  CatalogueInfoStruct getCatalogue(ClubInfoStruct club, String serviceType) {
    var catalogueList = _catalogues
        .where((catalogue) =>
            catalogue.clubID == club.clubID &&
            catalogue.serviceType == serviceType)
        .toList();

    if (catalogueList.isNotEmpty) {
      return catalogueList[0];
    }
    return _catalogues[0];
  }

  // LIKED CLUBS MANAGEMENT
  void toggleLike(int clubID) {
    if (_likedClubIDs.contains(clubID)) {
      _likedClubIDs.remove(clubID);
    } else {
      _likedClubIDs.add(clubID);
    }
    _notifyListeners();
  }

  bool isLiked(int clubID) {
    return _likedClubIDs.contains(clubID);
  }

  Future<void> deleteAllLiked() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('likedClubs');
      _likedClubIDs.clear();
      notifyListeners();
      print('Liked clubs cleared from SharedPreferences.');
    } catch (e) {
      print('Error clearing liked clubs: $e');
    }
    _notifyListeners();
  }

  // UTILITY / HELPER FUNCTIONS
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

  // PRINT FUNCTIONS FOR DEBUGGING
  void printAllClubs() {
    for (var club in _clubs) {
      print(
          '{"clubID:"${club.clubID},"clubName:"${club.clubName},"clubMinPrice:"${club.clubMinPrice},"clubMaxPersons:"${club.clubMaxPersons},"clubPhone:"${club.clubPhone},"clubLocation:"${club.clubLocation},"clubRating:"${club.clubRating},"clubAvailability:"${club.clubAvailability},"clubPhone:"${club.clubPhone},"clubLocation:"${club.clubLocation},"clubRating:"${club.clubRating},"clubAvailability:"${club.clubAvailability},"clubPhoto:"${club.clubPhoto}}');
    }
  }

  void printAllClubIDsAndNames() {
    for (var club in _clubs) {
      print('Club ID: ${club.clubID}, Club Name: ${club.clubName}');
    }
  }

  void printClub(ClubInfoStruct club) {
    print(
        '{"clubID:"${club.clubID},"clubName:"${club.clubName},"clubMinPrice:"${club.clubMinPrice},"clubMaxPersons:"${club.clubMaxPersons},"clubPhone:"${club.clubPhone},"clubLocation:"${club.clubLocation},"clubRating:"${club.clubRating},"clubAvailability:"${club.clubAvailability},"clubPhone:"${club.clubPhone},"clubLocation:"${club.clubLocation},"clubRating:"${club.clubRating},"clubAvailability:"${club.clubAvailability},"clubPhoto:"${club.clubPhoto}}');
  }

  void printClubWithID(int id) {
    for (var club in _clubs) {
      if (club.clubID == id) {
        print(
            '{"clubID:"${club.clubID},"clubName:"${club.clubName},"clubMinPrice:"${club.clubMinPrice},"clubMaxPersons:"${club.clubMaxPersons},"clubPhone:"${club.clubPhone},"clubLocation:"${club.clubLocation},"clubRating:"${club.clubRating},"clubAvailability:"${club.clubAvailability},"clubPhone:"${club.clubPhone},"clubLocation:"${club.clubLocation},"clubRating:"${club.clubRating},"clubAvailability:"${club.clubAvailability},"clubPhoto:"${club.clubPhoto}}');
        return;
      }
    }
    print('ClubID not found!');
  }

  void printClubWithName(String clubName) {
    for (var club in _clubs) {
      if (club.clubName == clubName) {
        print(
            '{"clubID:"${club.clubID},"clubName:"${club.clubName},"clubMinPrice:"${club.clubMinPrice},"clubMaxPersons:"${club.clubMaxPersons},"clubPhone:"${club.clubPhone},"clubLocation:"${club.clubLocation},"clubRating:"${club.clubRating},"clubAvailability:"${club.clubAvailability},"clubPhone:"${club.clubPhone},"clubLocation:"${club.clubLocation},"clubRating:"${club.clubRating},"clubAvailability:"${club.clubAvailability},"clubPhoto:"${club.clubPhoto}}');
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
}
