import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../global_components.dart';

class ClubLoader {
  ClubLoader(this._clubs, this._catalogues, this._likedClubIDs);

  final List<ClubInfoStruct> _clubs;
  final List<CatalogueInfoStruct> _catalogues;
  final List<int> _likedClubIDs;

  Future<String> _getFilePath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final Directory myprDirectory = Directory('${directory.path}/mypDirectory');

    // Create the new folder if it doesn't exist
    if (await myprDirectory.exists() == false) {
      await myprDirectory.create(recursive: true);
      print('\x1B[32mFolder created: ${myprDirectory.path}');
    }

    return '${directory.path}/mypDirectory/$fileName.json';
  }

  Future<void> loadClubsFromFile() async {
    String filePath = await _getFilePath('clubs');
    File file = File(filePath);

    if (await file.exists()) {
      String jsonClubs = await file.readAsString();
      List<dynamic> clubsList = jsonDecode(jsonClubs);

      _clubs.clear();
      _clubs.addAll(
          clubsList.map((json) => ClubInfoStruct.fromJson(json)).toList());

      print('\x1B[32mClubs loaded from $filePath');
    } else {
      print('\x1B[31mClubs file does not exist');
    }
  }

  Future<void> loadCataloguesFromFile() async {
    String filePath = await _getFilePath('catalogues');
    File file = File(filePath);

    if (await file.exists()) {
      String jsonCatalogues = await file.readAsString();
      List<dynamic> cataloguesList = jsonDecode(jsonCatalogues);

      _catalogues.clear();
      _catalogues.addAll(cataloguesList
          .map((json) => CatalogueInfoStruct.fromJson(json))
          .toList());

      print('\x1B[32mCatalogues loaded from $filePath');
    } else {
      print('\x1B[31mCatalogues file does not exist');
    }
  }

  Future<Uint8List?> loadClubPhotoFromFile(int clubID) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/mypDirectory/club_photo_$clubID.png';

    File file = File(filePath);

    if (await file.exists()) {
      return await file.readAsBytes();
    } else {
      print('\x1B[31mPhoto for club ID $clubID not found');
      return null;
    }
  }

  Future<void> loadLikedClubsFromPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? likedClubIDs = prefs.getStringList('likedClubs');

    _likedClubIDs.clear();
    if (likedClubIDs != null) {
      _likedClubIDs.addAll(likedClubIDs.map((id) => int.parse(id)));
      print('\x1B[32mLiked clubs loaded from preferences.');
    } else {
      print('\x1B[32mNo liked clubs found in preferences.');
    }
  }
}
