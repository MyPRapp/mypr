import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mypr/Providers/global_state_provider.dart';
import 'package:path_provider/path_provider.dart';

import '../global_components.dart';
import 'photo_manager.dart';

class ClubProvider with ChangeNotifier {
  final List<ClubInfoStruct> _clubs = [];
  final List<CatalogueInfoStruct> _catalogues = [];
  final PhotoManager _photoManager = PhotoManager();

  List<ClubInfoStruct> get allClubs => _clubs;
  List<CatalogueInfoStruct> get allCatalogues => _catalogues;

//// Syncs clubs from the server, loads from file if fetch fails
  Future<void> syncClubs() async {
    print('\x1B[33m------------SYNCING CLUBS------------');
    try {
      await fetchAndSaveClubsAndCatalogues(); // Fetch from server
    } catch (e) {
      await loadClubsFromFile();
      await loadCataloguesFromFile();
    }
    print('\x1B[32m------------SYNCED CLUBS------------');
  }
////////////////////////////////////////////////////////////////

//// Fetch From Server Functions
  Future<void> fetchAndSaveClubsAndCatalogues() async {
    print('\x1B[33mFetching clubs from server...');
    final url = 'http://${GlobalStateProvider().validatedIp}/api/clubs/print/';

    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = jsonDecode(decodedBody);

        for (var item in data) {
          final club = ClubInfoStruct.fromJson(item);
          if (club.clubID >= 0) {
            // Download and save club photo
            if (club.clubPhoto.isNotEmpty) {
              String localPath = await _photoManager.downloadAndSavePhoto(
                  club.clubPhoto, 'club_${club.clubID}_photo');

              club.localPhotoPath =
                  localPath; // Store local path in the club object
            } else {
              print('\x1B[31mClub photo URL is empty');
            }
            await fetchCatalogues(club); // Fetch catalogues for the club
            addOrUpdateClub(club); // Save club details
          }
        }

//// Save fetched clubs and catalogues locally for offline use
        await saveClubsToFile();
        await saveCataloguesToFile();
      } else {
        print(
            '\x1B[31mError fetching clubs from server, loading from local storage');
        throw Exception('Failed to load clubs: ${response.reasonPhrase}');
      }
    } catch (e) {
      print(
          '\x1B[31mError fetching clubs from server, loading from local storage: $e');
      throw Exception('Failed to load clubs');
    }
  }

  Future<void> fetchCatalogues(ClubInfoStruct club) async {
    if (club.clubID <= 0) {
      print('\x1B[31mFetchCatalogues: Invalid club ID');
      return;
    }

    print('\x1B[33mFetching catalogues for ${club.clubName} from server...');
    final url =
        'http://${GlobalStateProvider().validatedIp}/api/clubs/${club.clubID}/catalogue';
    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        for (var item in data) {
          final catalogue = CatalogueInfoStruct.fromJson(item);
          addOrUpdateCatalogue(catalogue);

          if (catalogue.serviceType == 'Regular') {
            club.clubMinPrice =
                (double.tryParse(catalogue.price)?.toInt() ?? 0);
            club.clubMaxPersons = catalogue.maxPersons;
            addOrUpdateClub(club);
          }
        }
      } else {
        throw Exception('Failed to load catalogues: ${response.reasonPhrase}');
      }
    } catch (e) {
      print(
          '\x1B[31mError fetching catalogues, loading from local storage: $e');
    }
  }

  Future<void> fetchClub(int clubID) async {
    if (clubID <= 0) {
      print('\x1B[31mFetchClub: Invalid club ID');
      return;
    }

    print('\x1B[33mFetching club with ID $clubID from server');
    final url = 'http://${GlobalStateProvider().validatedIp}/api/clubs/print/';
    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = jsonDecode(decodedBody);

//// Search for the club with the given clubID
        final clubData = data.firstWhere(
          (item) => item['clubID'] == clubID,
          orElse: () => null,
        );

        if (clubData != null) {
          final club = ClubInfoStruct.fromJson(clubData);

          addOrUpdateClub(club);
          await saveClubsToFile();
          print('\x1B[32mClub with ID $clubID fetched and updated.');
        } else {
          print('\x1B[31mClub with ID $clubID not found');
        }
      } else {
        throw Exception('Failed to load clubs: ${response.reasonPhrase}');
      }
    } catch (e) {
      print(
          '\x1B[31mError fetching club from server, loading from local storage: $e');
    }
  }
////////////////////////////////////////////////////////////////

//// Saving To File Functions
  Future<void> saveClubsToFile() async {
    String filePath = await getFilePath('clubs');
    File file = File(filePath);

    // Save club data as JSON in local storage
    String jsonClubs = jsonEncode(_clubs.map((club) => club.toJson()).toList());
    await file.writeAsString(jsonClubs);
    print('\x1B[32mClubs saved to $filePath');
  }

  Future<void> saveCataloguesToFile() async {
    String filePath = await getFilePath('catalogues');
    File file = File(filePath);

    // Save catalogue data as JSON in local storage
    String jsonCatalogues =
        jsonEncode(_catalogues.map((catalogue) => catalogue.toJson()).toList());
    await file.writeAsString(jsonCatalogues);
    print('\x1B[32mCatalogues saved to $filePath');
  }
////////////////////////////////////////////////////////////////

//// Load From File Functions (Replaces SharedPreferences)
  Future<void> loadClubsFromFile() async {
    String filePath = await getFilePath('clubs');
    File file = File(filePath);

    if (await file.exists()) {
      String jsonClubs = await file.readAsString();
      List<dynamic> clubsList = jsonDecode(jsonClubs);

      _clubs.clear();
      _clubs.addAll(
          clubsList.map((json) => ClubInfoStruct.fromJson(json)).toList());

      final directory = await getApplicationDocumentsDirectory();
      final Directory clubPhotosDirectory =
          Directory('${directory.path}/mypDirectory/club_photos');

      if (await clubPhotosDirectory.exists()) {
        for (var i in _clubs) {
          i.localPhotoPath =
              '${directory.path}/mypDirectory/club_photos/club_${i.clubID}_photo.jpg';
        }
      } else {
        print('\x1B[31mClub photos directory doesn\'t exist');
      }

      notifyListeners();
      print('\x1B[32mClubs loaded from $filePath');
    } else {
      print('\x1B[31mClubs file does not exist');
    }
  }

  Future<void> loadCataloguesFromFile() async {
    String filePath = await getFilePath('catalogues');
    File file = File(filePath);

    if (await file.exists()) {
      String jsonCatalogues = await file.readAsString();
      List<dynamic> cataloguesList = jsonDecode(jsonCatalogues);

      _catalogues.clear();
      _catalogues.addAll(cataloguesList
          .map((json) => CatalogueInfoStruct.fromJson(json))
          .toList());
      notifyListeners();
      print('\x1B[32mCatalogues loaded from $filePath');
    } else {
      print('\x1B[31mCatalogues file does not exist');
    }
  }
////////////////////////////////////////////////////////////////

//// Add Functions
  void addOrUpdateClub(ClubInfoStruct club) {
    if (club.clubID <= 0) {
      print('\x1B[31mAddOrUpdateClub: Invalid clubID: ${club.clubID}');
      return;
    }
    try {
//// Try to find if the club already exists in the list by its clubID
      int index = _clubs.indexWhere((c) => c.clubID == club.clubID);

      if (index != -1) {
//// Club exists, update the existing entry
        _clubs[index] = club;
        print('\x1B[32m \'${club.clubName}\' is up to date.');
      } else {
//// Club does not exist, add it to the list
        _clubs.add(club);
        print('\x1B[32mClub \'${club.clubName}\' added.');
      }
      notifyListeners();
    } catch (e) {
//// Catch any unexpected errors
      print('\x1B[31mError in addOrUpdateClub for clubID ${club.clubID}: $e');
    }
  }

  void addOrUpdateCatalogue(CatalogueInfoStruct catalogue) {
    if (catalogue.clubID <= 0) {
      print(
          '\x1B[31mAddOrUpdateCatalogue: Invalid clubID: ${catalogue.clubID}');
      return;
    }
    try {
      int index = -1;
//// Try to find if the catalogue for the specific clubID and serviceType already exists
      index = _catalogues.indexWhere((c) =>
          c.clubID == catalogue.clubID &&
          c.serviceType == catalogue.serviceType);

      if (index > 0) {
//// Catalogue exists, update the existing entry
        _catalogues[index] = catalogue;
        print(
            '\x1B[32m${catalogue.serviceType} catalogues for clubID: ${catalogue.clubID} are up to date.');
      } else {
//// Catalogue does not exist, add it to the list
        _catalogues.add(catalogue);
        print(
            '\x1B[32m${catalogue.serviceType} catalogues for clubID: ${catalogue.clubID} added.');
      }
    } catch (e) {
//// Catch any unexpected errors during the operation
      print(
          '\x1B[31mError in addOrUpdateCatalogue for clubID ${catalogue.clubID}: $e');
    }
  }

//// Get catalogues functions
  //Method to initialize catalogues based on club ID and update the provided CatalogueInfoStruct variables
  List<CatalogueInfoStruct> getAllCataloguesForClubWithID(int clubID) {
    ClubInfoStruct club = getClubByID(clubID);

//// Initialize and update the CatalogueInfoStruct variables
    CatalogueInfoStruct regularCatalogue = getCatalogue(club, 'Regular');
    CatalogueInfoStruct specialCatalogue = getCatalogue(club, 'Special');
    CatalogueInfoStruct premiumCatalogue = getCatalogue(club, 'Premium');

    return [regularCatalogue, specialCatalogue, premiumCatalogue];
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
////////////////////////////////////////////////////////////////

//// UTILITY / HELPER FUNCTIONS
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
////////////////////////////////////////////////////////////////

//// PRINT FUNCTIONS FOR DEBUGGING
  void printAllClubs() {
    for (var club in _clubs) {
      print(
          '{"clubID:"${club.clubID},"clubName:"${club.clubName},"clubMinPrice:"${club.clubMinPrice},"clubMaxPersons:"${club.clubMaxPersons},"clubPhone:"${club.clubPhone},"clubLocation:"${club.clubLocation},"clubRating:"${club.clubRating},"clubAvailability:"${club.clubAvailability},"clubPhone:"${club.clubPhone},"clubLocation:"${club.clubLocation},"clubRating:"${club.clubRating},"clubAvailability:"${club.clubAvailability},"clubPhoto:"${club.clubPhoto},"localPhotoPath:"${club.localPhotoPath},}');
    }
  }

  void printAllClubIDsAndNames() {
    for (var club in _clubs) {
      print('Club ID: ${club.clubID}, Club Name: ${club.clubName}');
    }
  }

  void printClub(ClubInfoStruct club) {
    print(
        '{"clubID:"${club.clubID},"clubName:"${club.clubName},"clubMinPrice:"${club.clubMinPrice},"clubMaxPersons:"${club.clubMaxPersons},"clubPhone:"${club.clubPhone},"clubLocation:"${club.clubLocation},"clubRating:"${club.clubRating},"clubAvailability:"${club.clubAvailability},"clubPhone:"${club.clubPhone},"clubLocation:"${club.clubLocation},"clubRating:"${club.clubRating},"clubAvailability:"${club.clubAvailability},"clubPhoto:"${club.clubPhoto},"localPhotoPath:"${club.localPhotoPath},}');
  }

  void printClubWithID(int id) {
    for (var club in _clubs) {
      if (club.clubID == id) {
        print(
            '{"clubID:"${club.clubID},"clubName:"${club.clubName},"clubMinPrice:"${club.clubMinPrice},"clubMaxPersons:"${club.clubMaxPersons},"clubPhone:"${club.clubPhone},"clubLocation:"${club.clubLocation},"clubRating:"${club.clubRating},"clubAvailability:"${club.clubAvailability},"clubPhone:"${club.clubPhone},"clubLocation:"${club.clubLocation},"clubRating:"${club.clubRating},"clubAvailability:"${club.clubAvailability},"clubPhoto:"${club.clubPhoto},"localPhotoPath:"${club.localPhotoPath},}');
        return;
      }
    }
    print('\x1B[31mClubID not found!');
  }

  void printClubWithName(String clubName) {
    for (var club in _clubs) {
      if (club.clubName == clubName) {
        print(
            '{"clubID:"${club.clubID},"clubName:"${club.clubName},"clubMinPrice:"${club.clubMinPrice},"clubMaxPersons:"${club.clubMaxPersons},"clubPhone:"${club.clubPhone},"clubLocation:"${club.clubLocation},"clubRating:"${club.clubRating},"clubAvailability:"${club.clubAvailability},"clubPhone:"${club.clubPhone},"clubLocation:"${club.clubLocation},"clubRating:"${club.clubRating},"clubAvailability:"${club.clubAvailability},"clubPhoto:"${club.clubPhoto},"localPhotoPath:"${club.localPhotoPath},}');
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
////////////////////////////////////////////////////////////////
}
