import 'package:flutter/material.dart';

import '../../global_components.dart';

class ClubManager with ChangeNotifier {
  ClubManager(this._clubs, this._catalogues);

  final List<ClubInfoStruct> _clubs;
  final List<CatalogueInfoStruct> _catalogues;

  // CLUB MANAGEMENT
  void addOrUpdateClub(ClubInfoStruct club) {
    if (club.clubID <= 0) {
      print('\x1B[31mAddOrUpdateClub: Invalid clubID: ${club.clubID}');
      return;
    }
    try {
      // Try to find if the club already exists in the list by its clubID
      int index = _clubs.indexWhere((c) => c.clubID == club.clubID);

      if (index != -1) {
        // Club exists, update the existing entry
        _clubs[index] = club;
        print('\x1B[32m \'${club.clubName}\' is up to date.');
      } else {
        // Club does not exist, add it to the list
        _clubs.add(club);
        print('\x1B[32mClub \'${club.clubName}\' added.');
      }
      notifyListeners();
    } catch (e) {
      // Catch any unexpected errors
      print('\x1B[31mError in addOrUpdateClub for clubID ${club.clubID}: $e');
    }
  }

  void removeClubWithClubCatalogues(int clubID) {
    if (clubID <= 0) {
      print('\x1B[31mRemoveClubWithClubCatalogues: Invalid clubID:: $clubID');
      return;
    }
    _clubs.removeWhere((club) => club.clubID == clubID);
    _catalogues.removeWhere((catalogue) => catalogue.clubID == clubID);
    notifyListeners();
  }

  // CATALOGUE MANAGEMENT

  // Method to initialize catalogues based on club ID and update the provided CatalogueInfoStruct variables
  List<CatalogueInfoStruct> getAllCataloguesForClubWithID(int clubID) {
    ClubInfoStruct club = getClubByID(clubID);

    // Initialize and update the CatalogueInfoStruct variables
    CatalogueInfoStruct regularCatalogue = getCatalogue(club, 'Regular');
    CatalogueInfoStruct specialCatalogue = getCatalogue(club, 'Special');
    CatalogueInfoStruct premiumCatalogue = getCatalogue(club, 'Premium');

    return [regularCatalogue, specialCatalogue, premiumCatalogue];
  }

  void addOrUpdateCatalogue(CatalogueInfoStruct catalogue) {
    if (catalogue.clubID <= 0) {
      print(
          '\x1B[31mAddOrUpdateCatalogue: Invalid clubID: ${catalogue.clubID}');
      return;
    }
    try {
      int index = -1;
      // Try to find if the catalogue for the specific clubID and serviceType already exists
      index = _catalogues.indexWhere((c) =>
          c.clubID == catalogue.clubID &&
          c.serviceType == catalogue.serviceType);

      if (index > 0) {
        // Catalogue exists, update the existing entry
        _catalogues[index] = catalogue;
        print(
            '\x1B[32m${catalogue.serviceType} catalogues for clubID: ${catalogue.clubID} are up to date.');
      } else {
        // Catalogue does not exist, add it to the list
        _catalogues.add(catalogue);
        print(
            '\x1B[32m${catalogue.serviceType} catalogues for clubID: ${catalogue.clubID} added.');
      }
    } catch (e) {
      // Catch any unexpected errors during the operation
      print(
          '\x1B[31mError in addOrUpdateCatalogue for clubID ${catalogue.clubID}: $e');
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
    print('\x1B[31mClubID not found!');
  }

  void printClubWithName(String clubName) {
    for (var club in _clubs) {
      if (club.clubName == clubName) {
        print(
            '{"clubID:"${club.clubID},"clubName:"${club.clubName},"clubMinPrice:"${club.clubMinPrice},"clubMaxPersons:"${club.clubMaxPersons},"clubPhone:"${club.clubPhone},"clubLocation:"${club.clubLocation},"clubRating:"${club.clubRating},"clubAvailability:"${club.clubAvailability},"clubPhone:"${club.clubPhone},"clubLocation:"${club.clubLocation},"clubRating:"${club.clubRating},"clubAvailability:"${club.clubAvailability},"clubPhoto:"${club.clubPhoto}}');
        return;
      }
    }
    print('\x1B[31mClubName not found!');
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
