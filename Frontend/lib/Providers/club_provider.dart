import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mypr/Globals/constants.dart';

import '../Globals/classes.dart';
import '../Globals/global_components.dart';
import '../services/file_service.dart';
import 'photo_manager.dart';

class ClubProvider with ChangeNotifier {
  final List<Club> _clubs = [];
  final List<Catalogue> _catalogues = [];

  List<Club> get allClubs => _clubs;
  List<Catalogue> get allCatalogues => _catalogues;

  final List<Club> _tempClubs = [];
  final List<Catalogue> _tempCatalogues = [];

  List<Future<void>> fetchCatalogueTasks = [];

  Future<void> fetchCataloguesList() async {
    final url = '$apiUrl/catalogue/create/';
    final response =
        await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final List<dynamic> data = jsonDecode(decodedBody);
      for (var item in data) {
        print(item);
      }
    } else {
      print(response.statusCode);
      print(response.body);
    }
  }

// ╔══════════════════════════════════════════════╗
// ║              FETCH FROM SERVER               ║
// ╚══════════════════════════════════════════════╝
  Future<void> fetchAndSaveClubsAndCatalogues() async {
    // fetchCataloguesList();

    try {
      final url = '$apiUrl/clubs/print/';
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));

      // If there's no error proceed
      if (response.statusCode == 200) {
        _tempClubs.clear();
        _tempCatalogues.clear();
        final decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = jsonDecode(decodedBody);

        for (var item in data) {
          final club = Club.fromJson(item);
          if (club.clubID < 0) {
            errorPrint("ClubID is incorrect");
            continue;
          }

          if (club.clubPriority == -2) {
            // Skip clubs with priority -2 (hidden clubs)
            continue;
          }

          // Store local path in the club object
          club.localPhotoPath = await PhotoManager.instance
              .downloadAndSaveClubPhoto(
                  club.clubPhoto, 'club_${club.clubID}_photo');

          // Save club details
          _tempClubs.add(club);

          // Fetch catalogues for the club by
          // adding the jobs/tasks in a list and running later
          fetchCatalogueTasks.add(fetchCatalogues(club));
        }

        await Future.wait(fetchCatalogueTasks); // Run in parallel

        await deleteUnusedClubs();
        await addTempClubsToMainClubs();
        await sortClubsByPriority(_clubs);

        // Save fetched clubs and catalogues locally for offline use
        await Future.wait([saveClubsToFile(), saveCataloguesToFile()]);
      } else {
        errorPrint(
            'Error fetching clubs from server, loading from local storage');
        errorPrint('Failed to load clubs: ${response.reasonPhrase}');
      }
    } catch (e) {
      // print(
      //     '❌Error fetching clubs from server, loading from local storage: $e');
      errorPrint('Failed to load clubs: $e');
    }
  }

  Future<void> fetchCatalogues(Club club) async {
    if (club.clubID <= 0) {
      errorPrint('FetchCatalogues: Invalid club ID');
      return;
    }

    try {
      final url = '$apiUrl/clubs/${club.clubID}/catalogue';
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        for (var item in data) {
          final catalogue = Catalogue.fromJson(item);
          _tempCatalogues.add(catalogue);

          if (catalogue.serviceType == 'Regular') {
            addMinPriceAndMaxPersonsToClub(club, catalogue);
          }
        }
      } else {
        throw Exception('Failed to load catalogues: ${response.reasonPhrase}');
      }
    } catch (e) {
      errorPrint('Error fetching catalogues, loading from local storage: $e');
    }
  }

  Future<void> addMinPriceAndMaxPersonsToClub(
      Club club, Catalogue catalogue) async {
    club.clubMinPrice = (double.tryParse(catalogue.price)?.toInt() ?? 0);
    club.clubMaxPersons = catalogue.maxPersons;
    int index = _tempClubs.indexWhere((c) => c.clubID == club.clubID);

    if (index != -1) {
      // Club exists, update the existing entry
      _tempClubs[index] = club;
    } else {
      // Club does not exist, add it to the list
      index = _clubs.indexWhere((c) => c.clubID == club.clubID);
      if (index == -1) {
        _tempClubs.add(club);
        errorPrint("Club ${club.clubName} wasn't found");
      } else {
        addOrUpdateClub(club);
      }
    }
  }

  Future<void> deleteUnusedClubs() async {
    await deleteUnusedClubsAndCatalogues();
    await deleteUnusedClubPhotos();
  }

  Future<void> deleteUnusedClubsAndCatalogues() async {
    // Store clubs to remove in a temporary list
    List<Club> clubsToRemove = [];

    // Collect clubs that need to be removed
    for (var club in _clubs) {
      bool clubFound = false;
      for (var tempClub in _tempClubs) {
        if (tempClub.clubID == club.clubID) {
          clubFound = true;
          break;
        }
      }
      if (!clubFound) {
        clubsToRemove.add(club); // Add to the list of clubs to be removed
        errorPrint("We remove ${club.clubName}");
      }
    }
    // Remove clubs after iteration
    _clubs.removeWhere((club) => clubsToRemove.contains(club));
    deleteUnusedCatalogues(clubsToRemove);
  }

  Future<void> deleteUnusedCatalogues(List<Club> clubsToRemove) async {
    List<Catalogue> cataloguesToRemove = [];

    for (var catalogue in _catalogues) {
      bool catalogueFound = false;

      for (var club in clubsToRemove) {
        if (catalogue.clubID == club.clubID) {
          catalogueFound = true;
          break;
        }
      }

      if (catalogueFound) {
        cataloguesToRemove
            .add(catalogue); // Add to the list of catalogues to be removed
        errorPrint("We remove ${catalogue.serviceType} catalogue");
      }
    }

    _catalogues
        .removeWhere((catalogue) => cataloguesToRemove.contains(catalogue));
  }

  Future<void> deleteUnusedClubPhotos() async {
    try {
      // Get the app's cache directory to find the folder where club photos are stored
      final clubPhotosPath = await FileHelper.getClubPhotosDirectory();
      final Directory clubPhotosDirectory = Directory(clubPhotosPath);

      if (await clubPhotosDirectory.exists()) {
        List<FileSystemEntity> files = clubPhotosDirectory.listSync();

        // Get the list of club IDs from the _clubs list
        List<int> existingClubIDs = _clubs.map((club) => club.clubID).toList();

        // Iterate over the files and delete those whose clubID is not in the _clubs list
        for (FileSystemEntity file in files) {
          if (file is File) {
            // Extract the clubID from the file name (assumes format: club_$clubID_photo.jpg)
            final RegExp exp = RegExp(r'club_(\d+)_photo\.jpg$');
            final Match? match = exp.firstMatch(file.path);

            if (match != null) {
              int clubID = int.parse(match.group(1)!);
              if (!existingClubIDs.contains(clubID)) {
                await file.delete();
              }
            }
          }
        }
        successPrint('Deleted unused club photos');
      } else {
        errorPrint('Directory does not exist: ${clubPhotosDirectory.path}');
      }
    } catch (e) {
      errorPrint('Error deleting unused club photos: $e');
    }
  }

  Future<void> addTempClubsToMainClubs() async {
    for (var club in _tempClubs) {
      addOrUpdateClub(club);
    }
    for (var catalogue in _tempCatalogues) {
      addOrUpdateCatalogue(catalogue);
    }
  }

  Future<void> sortClubsByPriority(List<Club> clubList) async {
    clubList.sort((a, b) {
      if (a.clubPriority == -1) return 1; // Place -1 last
      if (b.clubPriority == -1) return -1; // Place -1 last

      // Otherwise, sort in ascending order
      return a.clubPriority.compareTo(b.clubPriority);
    });
  }

  Future<void> fetchClub(int clubID) async {
    if (clubID <= 0) {
      errorPrint('FetchClub: Invalid club ID');
      return;
    }

    warningPrint('Fetching club with ID $clubID from server');
    final url = '$apiUrl/clubs/print/';
    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = jsonDecode(decodedBody);
        if (data.isEmpty) {
          errorPrint('No data received from the server.');
          return;
        }
        //// Search for the club with the given clubID
        Club club;
        for (var item in data) {
          club = Club.fromJson(item);

          if (club.clubID == clubID) {
            addOrUpdateClub(club);
            await saveClubsToFile();
            successPrint('Club with ID $clubID fetched and updated.');
            break;
          }
        }
      } else {
        throw Exception('Failed to load clubs: ${response.reasonPhrase}');
      }
    } catch (e) {
      errorPrint(
          'Error fetching club from server, loading from local storage: $e');
    }
  }
// ─────────────────────────────────────────────────────────────────────────────

// ╔══════════════════════════════════════════════╗
// ║                SAVE TO FILE                  ║
// ╚══════════════════════════════════════════════╝
  Future<void> saveClubsToFile() async {
    String filePath = await FileHelper.getFilePath('clubs');
    File file = File(filePath);

    // Save club data as JSON in local storage
    String jsonClubs = jsonEncode(_clubs.map((club) => club.toJson()).toList());
    await file.writeAsString(jsonClubs);
    successPrint('Clubs saved to file');
  }

  Future<void> saveCataloguesToFile() async {
    String filePath = await FileHelper.getFilePath('catalogues');
    File file = File(filePath);

    // Save catalogue data as JSON in local storage
    String jsonCatalogues =
        jsonEncode(_catalogues.map((catalogue) => catalogue.toJson()).toList());
    await file.writeAsString(jsonCatalogues);
    successPrint('Catalogues saved to file');
  }
// ─────────────────────────────────────────────────────────────────────────────

// ╔══════════════════════════════════════════════╗
// ║               LOAD FROM FILE                 ║
// ╚══════════════════════════════════════════════╝
  Future<void> loadClubsFromFile() async {
    String filePath = await FileHelper.getFilePath('clubs');
    File file = File(filePath);

    if (await file.exists()) {
      String jsonClubs = await file.readAsString();
      List<dynamic> clubsList = jsonDecode(jsonClubs);

      _clubs.clear();
      _clubs.addAll(clubsList.map((json) => Club.fromJson(json)).toList());

      final clubPhotosPath = await FileHelper.getClubPhotosDirectory();

      for (var club in _clubs) {
        club.localPhotoPath = '$clubPhotosPath/club_${club.clubID}_photo.jpg';
      }

      notifyListeners();
      successPrint('Clubs loaded from file');
    } else {
      errorPrint('Clubs file does not exist');
    }
  }

  Future<void> loadCataloguesFromFile() async {
    String filePath = await FileHelper.getFilePath('catalogues');
    File file = File(filePath);

    if (await file.exists()) {
      String jsonCatalogues = await file.readAsString();
      List<dynamic> cataloguesList = jsonDecode(jsonCatalogues);

      _catalogues.clear();
      _catalogues.addAll(
          cataloguesList.map((json) => Catalogue.fromJson(json)).toList());

      notifyListeners();
      successPrint('Catalogues loaded from file');
    } else {
      errorPrint('Catalogues file does not exist');
    }
  }
// ─────────────────────────────────────────────────────────────────────────────

// ╔══════════════════════════════════════════════╗
// ║               ADD OR UPDATE                  ║
// ╚══════════════════════════════════════════════╝
  void addOrUpdateClub(Club club) {
    if (club.clubID <= 0) {
      errorPrint('AddOrUpdateClub: Invalid clubID: ${club.clubID}');
      return;
    }
    try {
      // Try to find if the club already exists in the list by its clubID
      int index = _clubs.indexWhere((c) => c.clubID == club.clubID);

      if (index != -1) {
        // Club exists, update the existing entry
        _clubs[index] = club;
      } else {
        // Club does not exist, add it to the list
        _clubs.add(club);
      }
      notifyListeners();
    } catch (e) {
      errorPrint('Error in addOrUpdateClub for clubID ${club.clubName}: $e');
    }
  }

  void addOrUpdateCatalogue(Catalogue catalogue) {
    if (catalogue.clubID <= 0) {
      errorPrint('AddOrUpdateCatalogue: Invalid clubID: ${catalogue.clubID}');
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
        // print(
        //     '✅${catalogue.serviceType} catalogues for clubID: ${catalogue.clubID} are up to date.');
      } else {
        // Catalogue does not exist, add it to the list
        _catalogues.add(catalogue);
        // print(
        //     '✅${catalogue.serviceType} catalogues for clubID: ${catalogue.clubID} added.');
      }
    } catch (e) {
      //  print(   '❌Error in addOrUpdateCatalogue for clubID ${catalogue.clubID}: $e');
    }
  }
// ─────────────────────────────────────────────────────────────────────────────

// ╔══════════════════════════════════════════════╗
// ║                    GET                       ║
// ╚══════════════════════════════════════════════╝
  List<Catalogue> getAllCataloguesForClubWithID(int clubID) {
    Club club = getClubByID(clubID);

//// Initialize and update the Catalogue variables
    Catalogue regularCatalogue = getCatalogue(club, 'Regular');
    Catalogue specialCatalogue = getCatalogue(club, 'Special');
    Catalogue premiumCatalogue = getCatalogue(club, 'Premium');

    return [regularCatalogue, specialCatalogue, premiumCatalogue];
  }

  Catalogue getCatalogue(Club club, String serviceType) {
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

  String getclubAvailableDays(String clubName) {
    return _clubs
        .firstWhere((club) => club.clubName == clubName)
        .clubAvailableDays;
  }

  Club getClubByID(int clubID) {
    return _clubs.firstWhere((club) => club.clubID == clubID);
  }

  Club getClubByName(String clubName) {
    return _clubs.firstWhere((club) => club.clubName == clubName);
  }

  int getClubIDByName(String clubName) {
    return _clubs.firstWhere((club) => club.clubName == clubName).clubID;
  }

  String getClubNameByID(int clubID) {
    return _clubs.firstWhere((club) => club.clubID == clubID).clubName;
  }

  List<Catalogue> getCataloguesByClubID(int clubID) {
    List<Catalogue> tempCatalogues = [];

    for (int i = 0; i < _catalogues.length; i++) {
      if (_catalogues[i].clubID == clubID) {
        tempCatalogues.add(_catalogues[i]);
      }
    }
    return tempCatalogues;
  }
// ─────────────────────────────────────────────────────────────────────────────

// ╔══════════════════════════════════════════════╗
// ║              PRINT(FOR DEBUGGING)            ║
// ╚══════════════════════════════════════════════╝
  void printAllClubs() {
    for (var club in _clubs) {
      print(
          '{"clubID:"${club.clubID},"clubName:"${club.clubName},"clubMinPrice:"${club.clubMinPrice},"clubMaxPersons:"${club.clubMaxPersons},"clubPhone:"${club.clubPhone},"clubLocation:"${club.clubLocation},"clubRating:"${club.clubRating},"clubAvailableDays:"${club.clubAvailableDays},"clubPhone:"${club.clubPhone},"clubLocation:"${club.clubLocation},"clubRating:"${club.clubRating},"clubAvailableDays:"${club.clubAvailableDays},"clubPhoto:"${club.clubPhoto},"localPhotoPath:"${club.localPhotoPath},}');
    }
  }

  void printAllClubIDsAndNames() {
    for (var club in _clubs) {
      print('Club ID: ${club.clubID}, Club Name: ${club.clubName}');
    }
  }

  void printClub(Club club) {
    print(
        '{"clubID:"${club.clubID},"clubName:"${club.clubName},"clubMinPrice:"${club.clubMinPrice},"clubMaxPersons:"${club.clubMaxPersons},"clubPhone:"${club.clubPhone},"clubLocation:"${club.clubLocation},"clubRating:"${club.clubRating},"clubAvailableDays:"${club.clubAvailableDays},"clubPhone:"${club.clubPhone},"clubLocation:"${club.clubLocation},"clubRating:"${club.clubRating},"clubAvailableDays:"${club.clubAvailableDays},"clubPhoto:"${club.clubPhoto},"localPhotoPath:"${club.localPhotoPath},}');
  }

  void printClubWithID(int id) {
    for (var club in _clubs) {
      if (club.clubID == id) {
        print(
            '{"clubID:"${club.clubID},"clubName:"${club.clubName},"clubMinPrice:"${club.clubMinPrice},"clubMaxPersons:"${club.clubMaxPersons},"clubPhone:"${club.clubPhone},"clubLocation:"${club.clubLocation},"clubRating:"${club.clubRating},"clubAvailableDays:"${club.clubAvailableDays},"clubPhone:"${club.clubPhone},"clubLocation:"${club.clubLocation},"clubRating:"${club.clubRating},"clubAvailableDays:"${club.clubAvailableDays},"clubPhoto:"${club.clubPhoto},"localPhotoPath:"${club.localPhotoPath},}');
        return;
      }
    }
    errorPrint('ClubID not found!');
  }

  void printClubWithName(String clubName) {
    for (var club in _clubs) {
      if (club.clubName == clubName) {
        print(
            '{"clubID:"${club.clubID},"clubName:"${club.clubName},"clubMinPrice:"${club.clubMinPrice},"clubMaxPersons:"${club.clubMaxPersons},"clubPhone:"${club.clubPhone},"clubLocation:"${club.clubLocation},"clubRating:"${club.clubRating},"clubAvailableDays:"${club.clubAvailableDays},"clubPhone:"${club.clubPhone},"clubLocation:"${club.clubLocation},"clubRating:"${club.clubRating},"clubAvailableDays:"${club.clubAvailableDays},"clubPhoto:"${club.clubPhoto},"localPhotoPath:"${club.localPhotoPath},}');
        return;
      }
    }
    errorPrint('ClubName not found!');
  }

  void printAllCatalogues() {
    for (var catalogue in _catalogues) {
      print(
          '{"clubID:"${catalogue.clubID},"clubName:${getClubNameByID(catalogue.clubID)}","serviceType:"${catalogue.serviceType},"price:"${catalogue.price},"maxPersons:"${catalogue.maxPersons}}');
    }
  }

  void printCatalogue(Catalogue catalogue) {
    print(
        '{"clubID:"${catalogue.clubID},"clubName:${getClubNameByID(catalogue.clubID)}","serviceType:"${catalogue.serviceType},"price:"${catalogue.price},"maxPersons:"${catalogue.maxPersons}}');
  }
// ─────────────────────────────────────────────────────────────────────────────
}
